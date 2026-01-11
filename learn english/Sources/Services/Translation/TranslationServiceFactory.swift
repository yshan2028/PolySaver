//
//  TranslationServiceFactory.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import Foundation

// MARK: - Translation Service Factory
/// API 工厂类 - 管理所有翻译服务并提供降级策略
class TranslationServiceFactory {
    static let shared = TranslationServiceFactory()

    private var services: [APIProvider: TranslationService] = [:]
    private var preferredProvider: APIProvider

    private init() {
        // 从 UserDefaults 读取首选提供商
        self.preferredProvider = UserDefaults.standard.preferredAPIProvider

        // 初始化所有服务
        services[.google] = GoogleTranslationService()
        services[.youdao] = YoudaoTranslationService()
        services[.bing] = BingTranslationService()
    }

    // MARK: - Public Methods

    /// 设置首选API提供商
    func setPreferredProvider(_ provider: APIProvider) {
        self.preferredProvider = provider
        UserDefaults.standard.preferredAPIProvider = provider
    }

    /// 获取指定提供商的服务
    func getService(for provider: APIProvider) -> TranslationService? {
        return services[provider]
    }

    /// 获取可用的翻译服务（带降级策略）
    func getAvailableService() async -> TranslationService? {
        // 1. 尝试首选服务
        if let service = services[preferredProvider],
            await service.isAvailable()
        {
            return service
        }

        // 2. 降级到其他服务（按优先级：有道 > 必应 > Google）
        let fallbackOrder: [APIProvider] = [.youdao, .bing, .google]
        for provider in fallbackOrder where provider != preferredProvider {
            if let service = services[provider],
                await service.isAvailable()
            {
                print("⚠️ 首选服务 \(preferredProvider.displayName) 不可用，降级到 \(provider.displayName)")
                return service
            }
        }

        return nil
    }

    /// 翻译单词（自动选择最佳服务）
    func translate(word: String) async throws -> Word {
        guard let service = await getAvailableService() else {
            throw TranslationError.quotaExceeded
        }

        do {
            return try await service.translate(word: word)
        } catch {
            // 如果失败，尝试降级到其他服务
            print("⚠️ \(service.provider.displayName) 翻译失败: \(error.localizedDescription)")
            return try await translateWithFallback(word: word, excludeProvider: service.provider)
        }
    }

    /// 批量翻译
    func translateBatch(words: [String]) async throws -> [Word] {
        guard let service = await getAvailableService() else {
            throw TranslationError.quotaExceeded
        }

        do {
            return try await service.translateBatch(words: words)
        } catch {
            print("⚠️ \(service.provider.displayName) 批量翻译失败: \(error.localizedDescription)")
            // 批量失败时，尝试逐个翻译
            var results: [Word] = []
            for word in words {
                do {
                    let result = try await translate(word: word)
                    results.append(result)
                } catch {
                    print("⚠️ 单词 \(word) 翻译失败，跳过")
                    continue
                }
            }
            return results
        }
    }

    /// 检查所有服务的配额状态
    func checkAllQuotas() async -> [APIProvider: Int?] {
        var quotas: [APIProvider: Int?] = [:]
        for (provider, service) in services {
            quotas[provider] = await service.checkQuota()
        }
        return quotas
    }

    // MARK: - Private Methods

    private func translateWithFallback(word: String, excludeProvider: APIProvider) async throws
        -> Word
    {
        let fallbackOrder: [APIProvider] = [.youdao, .bing, .google]

        for provider in fallbackOrder where provider != excludeProvider {
            if let service = services[provider],
                await service.isAvailable()
            {
                do {
                    print("🔄 尝试使用 \(provider.displayName) 翻译...")
                    return try await service.translate(word: word)
                } catch {
                    print("⚠️ \(provider.displayName) 也失败了: \(error.localizedDescription)")
                    continue
                }
            }
        }

        throw TranslationError.quotaExceeded
    }
}
