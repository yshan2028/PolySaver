//
//  BingTranslationService.swift
//  learn english
//
//  Created by AI Assistant on 1/12/26.
//

import Foundation

// MARK: - Bing Response Models
private struct BingTranslateResponse: Codable {
    let translations: [TranslationItem]

    struct TranslationItem: Codable {
        let text: String
        let to: String
    }
}

// MARK: - Bing Translation Service
/// 必应翻译 API 实现
class BingTranslationService: TranslationService {
    let provider: APIProvider = .bing
    var apiKey: String?

    private let baseURL = APIEndpoints.bingTranslate

    init() {
        self.apiKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.bingAPIKey)
    }

    func translate(word: String) async throws -> Word {
        // 重新加载密钥（用户可能刚保存）
        self.apiKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.bingAPIKey)
        
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw TranslationError.apiKeyMissing
        }
        
        var request = URLRequest(url: URL(string: "\(baseURL)?api-version=3.0&to=zh-Hans")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let body = [["text": word]]
        request.httpBody = try? JSONEncoder().encode(body)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // 检查HTTP状态码
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 429 {
                        throw TranslationError.rateLimitExceeded
                    } else if httpResponse.statusCode == 403 || httpResponse.statusCode == 401 {
                        throw TranslationError.apiKeyMissing
                    }
                    throw TranslationError.invalidResponse
                }
            }

            let results = try JSONDecoder().decode([BingTranslateResponse].self, from: data)

            guard let translatedText = results.first?.translations.first?.text else {
                throw TranslationError.wordNotFound
            }

            // 增加使用计数
            incrementQuotaCount()

            return Word(
                headWord: word,
                usPhonetic: nil,  // Bing API 不提供音标
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
        // 必应支持批量翻译，可以并行调用
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
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: UserDefaultsKeys.bingMonthCount)

        // 检查是否需要重置（新的月份）
        if let lastReset = defaults.object(forKey: UserDefaultsKeys.bingLastResetDate) as? Date {
            if !Date().isSameMonth(as: lastReset) {
                // 重置计数
                defaults.set(0, forKey: UserDefaultsKeys.bingMonthCount)
                defaults.set(Date(), forKey: UserDefaultsKeys.bingLastResetDate)
                return provider.freeQuota
            }
        } else {
            defaults.set(Date(), forKey: UserDefaultsKeys.bingLastResetDate)
        }

        return max(0, (provider.freeQuota ?? 0) - count)
    }

    // MARK: - Private Methods

    private func incrementQuotaCount() {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: UserDefaultsKeys.bingMonthCount)
        defaults.set(count + 1, forKey: UserDefaultsKeys.bingMonthCount)
    }
}
