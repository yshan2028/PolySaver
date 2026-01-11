//
//  GoogleTranslationService.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import Foundation

// MARK: - Google Response Models
private struct GoogleTranslateResponse: Codable {
    let data: DataWrapper

    struct DataWrapper: Codable {
        let translations: [TranslationItem]
    }

    struct TranslationItem: Codable {
        let translatedText: String
        let detectedSourceLanguage: String?
    }
}

// MARK: - Google Translation Service
/// Google Translate API 实现
class GoogleTranslationService: TranslationService {
    let provider: APIProvider = .google
    var apiKey: String?

    private let baseURL = APIEndpoints.googleTranslate

    init() {
        self.apiKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.googleAPIKey)
    }

    func translate(word: String) async throws -> Word {
        // 重新加载密钥（用户可能刚保存）
        self.apiKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.googleAPIKey)
        
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw TranslationError.apiKeyMissing
        }

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "q", value: word),
            URLQueryItem(name: "source", value: "en"),
            URLQueryItem(name: "target", value: "zh-CN"),
            URLQueryItem(name: "format", value: "text"),
        ]

        do {
            let (data, response) = try await URLSession.shared.data(from: components.url!)

            // 检查HTTP状态码
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 429 {
                        throw TranslationError.rateLimitExceeded
                    } else if httpResponse.statusCode == 403 {
                        throw TranslationError.apiKeyMissing
                    }
                    throw TranslationError.invalidResponse
                }
            }

            let result = try JSONDecoder().decode(GoogleTranslateResponse.self, from: data)

            guard let translatedText = result.data.translations.first?.translatedText else {
                throw TranslationError.wordNotFound
            }

            return Word(
                headWord: word,
                usPhonetic: nil,  // Google API 不提供音标
                ukPhonetic: nil,
                translations: [Translation(pos: "unknown", tranCn: translatedText)],
                sentences: nil
            )
        } catch let error as TranslationError {
            throw error
        } catch {
            throw TranslationError.networkError(error)
        }
    }

    func translateBatch(words: [String]) async throws -> [Word] {
        // Google API 支持批量翻译，可以并行调用
        return try await withThrowingTaskGroup(of: Word.self) { group in
            for word in words {
                group.addTask {
                    try await self.translate(word: word)
                }
            }

            var results: [Word] = []
            for try await word in group {
                results.append(word)
            }
            return results
        }
    }

    func checkQuota() async -> Int? {
        // Google API 需要付费，无固定配额
        return nil
    }
}
