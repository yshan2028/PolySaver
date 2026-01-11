//
//  Constants.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import Foundation

// MARK: - UserDefaults Keys
enum UserDefaultsKeys {
    static let selectedVocabularySource = "SelectedVocabularySource"
    static let wordDisplayDuration = "WordDisplayDuration"
    static let downloadedSources = "DownloadedSources"
    static let preferredAPIProvider = "PreferredAPIProvider"

    // API Keys
    static let googleAPIKey = "GoogleAPIKey"
    static let youdaoAppKey = "YoudaoAppKey"
    static let youdaoAppSecret = "YoudaoAppSecret"
    static let bingAPIKey = "BingAPIKey"

    // API Quota Tracking
    static let youdaoTodayCount = "YoudaoTodayCount"
    static let youdaoLastResetDate = "YoudaoLastResetDate"
    static let bingMonthCount = "BingMonthCount"
    static let bingLastResetDate = "BingLastResetDate"

    // Learning Progress
    static let learnedWords = "LearnedWords"
    static let favoritedWords = "FavoritedWords"
}

// MARK: - File Paths
enum FilePaths {
    static let vocabularyDirectoryName = "Vocabularies"
    static let customDirectoryName = "Custom"
    static let cacheDirectoryName = "Cache"
}

// MARK: - API Endpoints
enum APIEndpoints {
    static let googleTranslate = "https://translation.googleapis.com/language/translate/v2"
    static let youdaoTranslate = "https://openapi.youdao.com/api"
    static let bingTranslate = "https://api.cognitive.microsofttranslator.com/translate"
}

// MARK: - App Constants
enum AppConstants {
    static let defaultDisplayDuration: TimeInterval = 5.0  // 默认5秒
    static let minDisplayDuration: TimeInterval = 2.0
    static let maxDisplayDuration: TimeInterval = 30.0

    static let animationDuration: TimeInterval = 0.5

    // Cache
    static let maxCacheSize: Int = 1000  // 最多缓存1000个单词
    static let cacheExpirationDays: Int = 7  // 缓存7天
}
