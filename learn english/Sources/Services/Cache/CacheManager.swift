//
//  CacheManager.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import Foundation

// MARK: - Cache Entry
private struct CacheEntry: Codable {
    let word: Word
    let timestamp: Date

    var isExpired: Bool {
        let daysSinceCreation =
            Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day ?? 0
        return daysSinceCreation >= AppConstants.cacheExpirationDays
    }
}

// MARK: - Cache Manager
/// 缓存管理器 - LRU缓存策略
class CacheManager {
    static let shared = CacheManager()

    // 内存缓存
    private var memoryCache: [String: CacheEntry] = [:]
    private var accessOrder: [String] = []  // LRU访问顺序

    // 磁盘缓存路径
    private let diskCacheURL: URL

    private init() {
        self.diskCacheURL = FileManager.cacheDirectory.appendingPathComponent("words_cache.json")
        loadCacheFromDisk()
    }

    // MARK: - Public Methods

    /// 获取缓存的单词
    func getCachedWord(for headWord: String) -> Word? {
        let key = headWord.lowercased()

        guard let entry = memoryCache[key], !entry.isExpired else {
            // 缓存不存在或已过期
            memoryCache.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
            return nil
        }

        // 更新访问顺序（LRU）
        updateAccessOrder(for: key)

        return entry.word
    }

    /// 缓存单词
    func cacheWord(_ word: Word) {
        let key = word.headWord.lowercased()
        let entry = CacheEntry(word: word, timestamp: Date())

        memoryCache[key] = entry
        updateAccessOrder(for: key)

        // 检查缓存大小，移除最旧的条目
        if memoryCache.count > AppConstants.maxCacheSize {
            evictLRU()
        }

        // 异步保存到磁盘
        Task {
            await saveCacheToDisk()
        }
    }

    /// 批量缓存单词
    func cacheWords(_ words: [Word]) {
        for word in words {
            let key = word.headWord.lowercased()
            let entry = CacheEntry(word: word, timestamp: Date())
            memoryCache[key] = entry
            updateAccessOrder(for: key)
        }

        // 清理超出限制的缓存
        while memoryCache.count > AppConstants.maxCacheSize {
            evictLRU()
        }

        Task {
            await saveCacheToDisk()
        }
    }

    /// 清除所有缓存
    func clearCache() {
        memoryCache.removeAll()
        accessOrder.removeAll()
        try? FileManager.default.removeItem(at: diskCacheURL)
        print("🗑️ 缓存已清空")
    }

    /// 清除过期缓存
    func clearExpiredCache() {
        let expiredKeys = memoryCache.filter { $0.value.isExpired }.map { $0.key }
        for key in expiredKeys {
            memoryCache.removeValue(forKey: key)
            accessOrder.removeAll { $0 == key }
        }

        if !expiredKeys.isEmpty {
            print("🗑️ 清除了 \(expiredKeys.count) 个过期缓存")
            Task {
                await saveCacheToDisk()
            }
        }
    }

    /// 获取缓存统计
    func getCacheStats() -> (count: Int, size: Int64) {
        let count = memoryCache.count
        var size: Int64 = 0

        if FileManager.default.fileExists(atPath: diskCacheURL.path) {
            if let attributes = try? FileManager.default.attributesOfItem(atPath: diskCacheURL.path)
            {
                size = attributes[.size] as? Int64 ?? 0
            }
        }

        return (count, size)
    }

    // MARK: - Private Methods

    private func updateAccessOrder(for key: String) {
        // 移除旧位置
        accessOrder.removeAll { $0 == key }
        // 添加到末尾（最新访问）
        accessOrder.append(key)
    }

    private func evictLRU() {
        // 移除最久未使用的条目
        guard let lruKey = accessOrder.first else { return }
        memoryCache.removeValue(forKey: lruKey)
        accessOrder.removeFirst()
        print("🗑️ LRU淘汰: \(lruKey)")
    }

    private func loadCacheFromDisk() {
        guard FileManager.default.fileExists(atPath: diskCacheURL.path) else {
            return
        }

        do {
            let data = try Data(contentsOf: diskCacheURL)
            let cache = try JSONDecoder().decode([String: CacheEntry].self, from: data)

            // 过滤掉过期的缓存
            self.memoryCache = cache.filter { !$0.value.isExpired }
            self.accessOrder = Array(memoryCache.keys)

            print("✅ 从磁盘加载了 \(memoryCache.count) 个缓存")
        } catch {
            print("⚠️ 加载缓存失败: \(error.localizedDescription)")
        }
    }

    private func saveCacheToDisk() async {
        do {
            let data = try JSONEncoder().encode(memoryCache)
            try data.write(to: diskCacheURL, options: .atomic)
        } catch {
            print("⚠️ 保存缓存失败: \(error.localizedDescription)")
        }
    }
}
