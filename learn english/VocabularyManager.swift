//
//  VocabularyManager.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import Foundation

// MARK: - Vocabulary Manager
/// 词汇管理核心类 - 统一管理静态文件和API翻译
class VocabularyManager {
    static let shared = VocabularyManager()

    // 当前词汇源
    private var currentSource: VocabularySource?

    // 当前加载的单词列表
    private var words: [Word] = []

    // 已显示单词的索引集合（避免重复）
    private var shownIndices: Set<Int> = []

    // 缓存管理器
    private let cacheManager = CacheManager.shared

    // 翻译服务工厂
    private let translationFactory = TranslationServiceFactory.shared

    private init() {
        loadCurrentSource()
    }

    // MARK: - Public Methods

    /// 获取所有可用的词汇源
    func getAvailableSources() -> [VocabularySource] {
        var sources = VocabularySource.predefinedSources

        // 更新下载状态
        let downloadedIds = UserDefaults.standard.downloadedSources
        for i in 0..<sources.count {
            sources[i].isDownloaded = downloadedIds.contains(sources[i].identifier)
        }

        return sources
    }

    /// 设置当前词汇源
    func setCurrentSource(_ source: VocabularySource) async throws {
        guard source.isDownloaded else {
            throw NSError(
                domain: "VocabularyManager", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "词汇源未下载"])
        }

        self.currentSource = source
        UserDefaults.standard.selectedSource = source.identifier

        // 加载单词
        try await loadWords(from: source)
    }

    /// 获取下一个随机单词
    func getNextWord() async throws -> Word {
        // 如果是离线词汇源
        if let source = currentSource, source.type == .staticFile {
            return try getRandomWordFromFile()
        }

        // 如果是API源或没有设置源，返回默认错误
        throw NSError(
            domain: "VocabularyManager", code: 2,
            userInfo: [NSLocalizedDescriptionKey: "未设置词汇源"])
    }

    /// 通过API翻译单词
    func translateWord(_ word: String) async throws -> Word {
        // 先检查缓存
        if let cachedWord = cacheManager.getCachedWord(for: word) {
            print("✅ 从缓存获取: \(word)")
            return cachedWord
        }

        // 通过API翻译
        let translatedWord = try await translationFactory.translate(word: word)

        // 缓存结果
        cacheManager.cacheWord(translatedWord)

        return translatedWord
    }

    /// 批量翻译单词
    func translateWords(_ words: [String]) async throws -> [Word] {
        var results: [Word] = []
        var wordsToTranslate: [String] = []

        // 检查缓存
        for word in words {
            if let cached = cacheManager.getCachedWord(for: word) {
                results.append(cached)
            } else {
                wordsToTranslate.append(word)
            }
        }

        // 翻译未缓存的单词
        if !wordsToTranslate.isEmpty {
            let translated = try await translationFactory.translateBatch(words: wordsToTranslate)
            results.append(contentsOf: translated)

            // 缓存翻译结果
            cacheManager.cacheWords(translated)
        }

        return results
    }

    /// 导入自定义单词列表（纯单词列表，需要API翻译）
    func importCustomWords(_ wordList: [String]) async throws -> [Word] {
        print("📥 开始导入 \(wordList.count) 个单词...")

        let words = try await translateWords(wordList)

        // 保存到自定义词汇源
        let customSource = VocabularySource(
            name: "自定义词汇",
            identifier: "custom_\(Date().timeIntervalSince1970)",
            type: .custom,
            isDownloaded: true
        )

        try saveCustomWords(words, to: customSource)

        print("✅ 导入完成: \(words.count) 个单词")
        return words
    }

    /// 获取当前词汇源信息
    func getCurrentSourceInfo() -> (source: VocabularySource?, wordCount: Int) {
        return (currentSource, words.count)
    }

    /// 重置显示记录（重新开始循环）
    func resetProgress() {
        shownIndices.removeAll()
        saveProgress()
        print("🔄 重置学习进度")
    }

    // MARK: - Private Methods

    private func loadCurrentSource() {
        guard let identifier = UserDefaults.standard.selectedSource else {
            return
        }

        let sources = getAvailableSources()
        if let source = sources.first(where: { $0.identifier == identifier && $0.isDownloaded }) {
            Task {
                try? await loadWords(from: source)
            }
        }
    }

    private func loadWords(from source: VocabularySource) async throws {
        print("📖 加载词汇源: \(source.name)")

        switch source.type {
        case .staticFile:
            words = try JSONParser.parseVocabularyDirectory(at: source.localPath)
        case .custom:
            words = try JSONParser.parseVocabularyFile(at: source.jsonFilePath)
        case .api:
            words = []  // API模式不预加载
        }

        // 加载之前的进度
        loadProgress(for: source.identifier)

        print("✅ 成功加载 \(words.count) 个单词")
    }

    private func getRandomWordFromFile() throws -> Word {
        guard !words.isEmpty else {
            throw NSError(
                domain: "VocabularyManager", code: 3,
                userInfo: [NSLocalizedDescriptionKey: "词汇列表为空"])
        }

        // 如果所有单词都已显示过，重置
        if shownIndices.count >= words.count {
            print("🔄 所有单词已显示，重新开始")
            resetProgress()
        }

        // 随机选择一个未显示的单词
        var randomIndex: Int
        repeat {
            randomIndex = Int.random(in: 0..<words.count)
        } while shownIndices.contains(randomIndex)

        shownIndices.insert(randomIndex)
        saveProgress()  // 保存进度

        return words[randomIndex]
    }

    private func saveCustomWords(_ words: [Word], to source: VocabularySource) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        let data = try encoder.encode(words)
        try FileManager.default.createDirectory(
            at: source.localPath, withIntermediateDirectories: true)
        try data.write(to: source.jsonFilePath)

        UserDefaults.standard.addDownloadedSource(source.identifier)
    }

    // MARK: - Persistence

    private func saveProgress() {
        guard let sourceId = currentSource?.identifier else { return }
        let key = "vocab_progress_\(sourceId)"
        let array = Array(shownIndices)
        UserDefaults.standard.set(array, forKey: key)
    }

    private func loadProgress(for sourceId: String) {
        let key = "vocab_progress_\(sourceId)"
        if let savedIndices = UserDefaults.standard.array(forKey: key) as? [Int] {
            shownIndices = Set(savedIndices)
            print("💾 已恢复学习进度: \(shownIndices.count) 个单词")
        } else {
            shownIndices.removeAll()
        }
    }
}
