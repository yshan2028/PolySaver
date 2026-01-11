//
//  TranslationService.swift
//  learn english
//
//  Created by AI Assistant on 1/12/26.
//

import Foundation

// MARK: - Translation Error
/// 翻译服务错误类型
enum TranslationError: Error, LocalizedError {
    case networkError(Error)
    case apiKeyMissing
    case quotaExceeded
    case invalidResponse
    case wordNotFound
    case rateLimitExceeded

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "网络错误: \(error.localizedDescription)"
        case .apiKeyMissing:
            return "API密钥未配置"
        case .quotaExceeded:
            return "API配额已用完"
        case .invalidResponse:
            return "API响应格式错误"
        case .wordNotFound:
            return "未找到该单词"
        case .rateLimitExceeded:
            return "请求过于频繁，请稍后再试"
        }
    }
}

// MARK: - Translation Service Protocol
/// 翻译服务协议
protocol TranslationService: AnyObject {
    var provider: APIProvider { get }
    var apiKey: String? { get set }

    /// 翻译单个单词
    func translate(word: String) async throws -> Word

    /// 批量翻译（优化API调用）
    func translateBatch(words: [String]) async throws -> [Word]

    /// 检查API配额
    func checkQuota() async -> Int?

    /// 检查服务是否可用
    func isAvailable() async -> Bool
}

// MARK: - Default Implementation
extension TranslationService {
    func isAvailable() async -> Bool {
        // 检查API密钥
        if provider.requiresAPIKey && apiKey == nil {
            return false
        }

        // 检查配额
        if let quota = await checkQuota(), quota <= 0 {
            return false
        }

        return true
    }
}
