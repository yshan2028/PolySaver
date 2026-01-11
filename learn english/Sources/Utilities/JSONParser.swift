//
//  JSONParser.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import Foundation

// MARK: - JSON Parser for GitHub Dictionary Format
/// 解析GitHub词汇源的JSON格式
struct JSONParser {

    // MARK: - GitHub Dict Format Models

    private struct WordEntry: Codable {
        let wordRank: Int
        let headWord: String
        let content: ContentWrapper

        struct ContentWrapper: Codable {
            let word: WordDetail
        }

        struct WordDetail: Codable {
            let content: WordContent
        }

        struct WordContent: Codable {
            let usphone: String?
            let ukphone: String?
            let trans: [TransItem]?
            let sentence: SentenceWrapper?

            struct TransItem: Codable {
                let pos: String
                let tranCn: String
                let tranOther: String?
            }

            struct SentenceWrapper: Codable {
                let sentences: [SentenceItem]?
            }

            struct SentenceItem: Codable {
                let sContent: String
                let sCn: String
            }
        }

        // Convert WordEntry to Word model
        func toWord() -> Word {
            let wordContent = content.word.content

            let translations =
                wordContent.trans?.map { trans in
                    Translation(
                        pos: trans.pos,
                        tranCn: trans.tranCn,
                        tranOther: trans.tranOther)
                } ?? []

            let sentences = wordContent.sentence?.sentences?.map { sent in
                Sentence(sContent: sent.sContent, sCn: sent.sCn)
            }

            return Word(
                headWord: headWord,
                usPhonetic: wordContent.usphone,
                ukPhonetic: wordContent.ukphone,
                translations: translations.isEmpty
                    ? [Translation(pos: "n.", tranCn: "未知")] : translations,
                sentences: sentences)
        }
    }

    // MARK: - Parsing Methods

    /// 解析JSON文件并返回单词列表
    static func parseVocabularyFile(at url: URL) throws -> [Word] {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(
                domain: "JSONParser", code: 404,
                userInfo: [NSLocalizedDescriptionKey: "文件不存在: \(url.path)"])
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        // 尝试解析为单个对象或数组
        if let wordEntries = try? decoder.decode([WordEntry].self, from: data) {
            return wordEntries.map { $0.toWord() }
        } else if let wordEntry = try? decoder.decode(WordEntry.self, from: data) {
            return [wordEntry.toWord()]
        } else {
            throw NSError(
                domain: "JSONParser", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "无法解析JSON格式"])
        }
    }

    /// 解析目录中的所有JSON文件
    static func parseVocabularyDirectory(at url: URL) throws -> [Word] {
        var allWords: [Word] = []

        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: nil)

        for fileURL in files where fileURL.pathExtension == "json" {
            do {
                let words = try parseVocabularyFile(at: fileURL)
                allWords.append(contentsOf: words)
            } catch {
                print("⚠️ 解析文件失败: \(fileURL.lastPathComponent) - \(error.localizedDescription)")
            }
        }

        return allWords
    }
}
