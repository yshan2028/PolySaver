//
//  YoudaoTranslationService.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import Foundation

// MARK: - Youdao Response Models
private struct YoudaoResponse: Codable {
    let errorCode: String
    let query: String?
    let translation: [String]?
    let basic: BasicInfo?
    let web: [WebTranslation]?

    struct BasicInfo: Codable {
        let phonetic: String?
        let usPhonetic: String?
        let ukPhonetic: String?
        let explains: [String]?

        enum CodingKeys: String, CodingKey {
            case phonetic
            case usPhonetic = "us-phonetic"
            case ukPhonetic = "uk-phonetic"
            case explains
        }
    }

    struct WebTranslation: Codable {
        let key: String
        let value: [String]
    }
}

// MARK: - Youdao Translation Service
/// 有道翻译 API 实现
class YoudaoTranslationService: TranslationService {
    let provider: APIProvider = .youdao
    var apiKey: String?
    var appSecret: String?

    private let baseURL = APIEndpoints.youdaoTranslate

    init() {
        // 从 UserDefaults 加载密钥
        self.apiKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.youdaoAppKey)
        self.appSecret = UserDefaults.standard.string(forKey: UserDefaultsKeys.youdaoAppSecret)
    }

    func translate(word: String) async throws -> Word {
        // 重新加载密钥（用户可能刚保存）
        reloadCredentials()

        guard let apiKey = apiKey, !apiKey.isEmpty,
            let appSecret = appSecret, !appSecret.isEmpty
        else {
            throw TranslationError.apiKeyMissing
        }

        // 检查配额
        if let quota = await checkQuota(), quota <= 0 {
            throw TranslationError.quotaExceeded
        }

        // 有道API签名计算 - 确保 curtime 一致
        let salt = UUID().uuidString
        let curtime = String(Int(Date().timeIntervalSince1970))
        let sign = calculateSign(query: word, salt: salt, curtime: curtime, appSecret: appSecret)

        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "q", value: word),
            URLQueryItem(name: "from", value: "en"),
            URLQueryItem(name: "to", value: "zh-CHS"),
            URLQueryItem(name: "appKey", value: apiKey),
            URLQueryItem(name: "salt", value: salt),
            URLQueryItem(name: "sign", value: sign),
            URLQueryItem(name: "signType", value: "v3"),
            URLQueryItem(name: "curtime", value: curtime),
        ]

        do {
            let (data, _) = try await URLSession.shared.data(from: components.url!)
            let result = try JSONDecoder().decode(YoudaoResponse.self, from: data)

            // 检查错误码
            guard result.errorCode == "0" else {
                // 处理有道 API 错误码
                switch result.errorCode {
                case "101": throw TranslationError.apiKeyMissing  // 缺少必填参数
                case "102": throw TranslationError.apiKeyMissing  // 不支持的语言类型
                case "103": throw TranslationError.wordNotFound  // 翻译文本过长
                case "108": throw TranslationError.apiKeyMissing  // 应用ID无效
                case "110": throw TranslationError.quotaExceeded  // 无相关服务的有效实例
                case "111": throw TranslationError.apiKeyMissing  // 开发者账号无效
                case "113": throw TranslationError.wordNotFound  // 查询为空
                case "202": throw TranslationError.apiKeyMissing  // 签名检验失败
                case "401": throw TranslationError.quotaExceeded  // 账户已欠费
                case "411": throw TranslationError.rateLimitExceeded  // 访问频率受限
                default: throw TranslationError.invalidResponse
                }
            }

            // 增加调用计数
            incrementQuotaCount()

            // 转换为 Word 模型
            return convertToWord(from: result, headWord: word)
        } catch let error as TranslationError {
            throw error
        } catch {
            throw TranslationError.networkError(error)
        }
    }

    func translateBatch(words: [String]) async throws -> [Word] {
        // 有道免费版有频率限制，需要串行调用
        var results: [Word] = []
        for word in words {
            try await Task.sleep(nanoseconds: 100_000_000)  // 100ms延迟
            do {
                let result = try await translate(word: word)
                results.append(result)
            } catch {
                // 批量翻译时忽略个别错误
                print("⚠️ 翻译失败: \(word) - \(error.localizedDescription)")
                continue
            }
        }
        return results
    }

    func checkQuota() async -> Int? {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: UserDefaultsKeys.youdaoTodayCount)

        // 检查是否需要重置（新的一天）
        if let lastReset = defaults.object(forKey: UserDefaultsKeys.youdaoLastResetDate) as? Date {
            if !Date().isSameDay(as: lastReset) {
                // 重置计数
                defaults.set(0, forKey: UserDefaultsKeys.youdaoTodayCount)
                defaults.set(Date(), forKey: UserDefaultsKeys.youdaoLastResetDate)
                return 100
            }
        } else {
            defaults.set(Date(), forKey: UserDefaultsKeys.youdaoLastResetDate)
        }

        return max(0, 100 - count)
    }

    // MARK: - Private Methods

    private func reloadCredentials() {
        self.apiKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.youdaoAppKey)
        self.appSecret = UserDefaults.standard.string(forKey: UserDefaultsKeys.youdaoAppSecret)
    }

    private func calculateSign(query: String, salt: String, curtime: String, appSecret: String)
        -> String
    {
        // 有道API v3签名算法: sha256(appKey + truncate(q) + salt + curtime + appSecret)
        let signStr = "\(apiKey ?? "")\(truncate(query))\(salt)\(curtime)\(appSecret)"
        return signStr.sha256  // 使用 SHA256 而非 MD5
    }

    private func truncate(_ query: String) -> String {
        // 有道API要求：如果query长度大于20，则截取前10和后10
        if query.count <= 20 {
            return query
        }
        let start = query.prefix(10)
        let end = query.suffix(10)
        return "\(start)\(query.count)\(end)"
    }

    private func incrementQuotaCount() {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: UserDefaultsKeys.youdaoTodayCount)
        defaults.set(count + 1, forKey: UserDefaultsKeys.youdaoTodayCount)
    }

    private func convertToWord(from response: YoudaoResponse, headWord: String) -> Word {
        var translations: [Translation] = []

        // 从 basic.explains 提取翻译
        if let explains = response.basic?.explains {
            for explain in explains {
                // 尝试分离词性和翻译
                if let dotIndex = explain.firstIndex(of: ".") {
                    let pos = String(explain[..<dotIndex])
                    let trans = String(explain[explain.index(after: dotIndex)...])
                        .trimmingCharacters(in: .whitespaces)
                    translations.append(Translation(pos: pos, tranCn: trans))
                } else {
                    translations.append(Translation(pos: "n.", tranCn: explain))
                }
            }
        } else if let trans = response.translation?.first {
            // 如果没有 basic，使用简单翻译
            translations.append(Translation(pos: "n.", tranCn: trans))
        }

        // 从 web 提取例句
        let sentences: [Sentence]? = response.web?.map {
            Sentence(sContent: $0.key, sCn: $0.value.joined(separator: "; "))
        }

        return Word(
            headWord: headWord,
            usPhonetic: response.basic?.usPhonetic,
            ukPhonetic: response.basic?.ukPhonetic,
            translations: translations.isEmpty
                ? [Translation(pos: "n.", tranCn: "未找到翻译")] : translations,
            sentences: sentences
        )
    }
}
