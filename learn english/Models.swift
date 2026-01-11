//
//  Models.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import Foundation

// MARK: - Translation Model
/// 单词的翻译信息
struct Translation: Codable {
    let pos: String           // 词性 (vt./n./adj./adv.)
    let tranCn: String        // 中文翻译
    let tranOther: String?    // 英文解释（可选）
    
    init(pos: String, tranCn: String, tranOther: String? = nil) {
        self.pos = pos
        self.tranCn = tranCn
        self.tranOther = tranOther
    }
}

// MARK: - Sentence Model
/// 例句
struct Sentence: Codable {
    let sContent: String      // 英文例句
    let sCn: String          // 中文翻译
    
    init(sContent: String, sCn: String) {
        self.sContent = sContent
        self.sCn = sCn
    }
}

// MARK: - Word Model
/// 单词核心数据模型
struct Word: Codable {
    let headWord: String              // 单词
    let usPhonetic: String?           // 美式音标
    let ukPhonetic: String?           // 英式音标
    let translations: [Translation]   // 翻译列表
    let sentences: [Sentence]?        // 例句列表（可选）
    
    /// 主要翻译（默认取第一个）
    var primaryTranslation: String {
        translations.first?.tranCn ?? ""
    }
    
    /// 首选音标（优先美式，其次英式）
    var phonetic: String {
        if let us = usPhonetic, !us.isEmpty {
            return "[\(us)]"
        } else if let uk = ukPhonetic, !uk.isEmpty {
            return "[\(uk)]"
        }
        return ""
    }
    
    /// 词性和翻译组合显示
    var translationDisplay: String {
        translations.map { "\($0.pos) \($0.tranCn)" }
            .joined(separator: "; ")
    }
    
    init(headWord: String,
         usPhonetic: String? = nil,
         ukPhonetic: String? = nil,
         translations: [Translation],
         sentences: [Sentence]? = nil) {
        self.headWord = headWord
        self.usPhonetic = usPhonetic
        self.ukPhonetic = ukPhonetic
        self.translations = translations
        self.sentences = sentences
    }
}

// MARK: - Source Type
/// 数据源类型
enum SourceType: String, Codable {
    case staticFile    // 静态JSON文件（离线）
    case api          // 在线API（需联网）
    case custom       // 用户自定义导入
}

// MARK: - API Provider
/// API提供商
enum APIProvider: String, Codable, CaseIterable {
    case google = "Google Translate"
    case youdao = "有道翻译"
    case bing = "必应翻译"
    
    /// 是否需要API密钥
    var requiresAPIKey: Bool {
        switch self {
        case .google: return true
        case .youdao: return true
        case .bing: return false  // 必应提供免费额度
        }
    }
    
    /// 免费配额（每日/每月）
    var freeQuota: Int? {
        switch self {
        case .google: return nil     // 需付费
        case .youdao: return 100     // 每日100次
        case .bing: return 1000      // 每月1000次
        }
    }
    
    /// 显示名称
    var displayName: String {
        return rawValue
    }
}

// MARK: - Vocabulary Source
/// 词汇源配置
struct VocabularySource: Codable {
    let name: String              // 显示名称 (如 "英语四级")
    let identifier: String        // 唯一标识 (如 "CET4")
    let type: SourceType          // 数据源类型
    let githubURL: String?        // GitHub 下载地址（静态文件）
    var isDownloaded: Bool        // 是否已下载
    
    /// 本地存储路径
    var localPath: URL {
        FileManager.vocabularyDirectory
            .appendingPathComponent(identifier)
    }
    
    /// JSON 文件路径
    var jsonFilePath: URL {
        localPath.appendingPathComponent("\(identifier).json")
    }
    
    init(name: String,
         identifier: String,
         type: SourceType,
         githubURL: String? = nil,
         isDownloaded: Bool = false) {
        self.name = name
        self.identifier = identifier
        self.type = type
        self.githubURL = githubURL
        self.isDownloaded = isDownloaded
    }
    
    // MARK: - Predefined Sources
    
    /// 预定义的词汇源列表
    static let predefinedSources: [VocabularySource] = [
        VocabularySource(
            name: "英语四级",
            identifier: "CET4",
            type: .staticFile,
            githubURL: "https://github.com/kajweb/dict/raw/master/book/1521164643060_CET4_3.zip"
        ),
        VocabularySource(
            name: "英语六级",
            identifier: "CET6",
            type: .staticFile,
            githubURL: "https://github.com/kajweb/dict/raw/master/book/1521164633851_CET6_3.zip"
        ),
        VocabularySource(
            name: "考研",
            identifier: "KaoYan",
            type: .staticFile,
            githubURL: "https://github.com/kajweb/dict/raw/master/book/1521164658897_KaoYan_3.zip"
        ),
        VocabularySource(
            name: "专四",
            identifier: "Level4",
            type: .staticFile,
            githubURL: "https://github.com/kajweb/dict/raw/master/book/1521164647417_Level4_1.zip"
        ),
        VocabularySource(
            name: "专八",
            identifier: "Level8",
            type: .staticFile,
            githubURL: "https://github.com/kajweb/dict/raw/master/book/1521164635290_Level8_1.zip"
        ),
        VocabularySource(
            name: "雅思",
            identifier: "IELTS",
            type: .staticFile,
            githubURL: "https://github.com/kajweb/dict/raw/master/book/1521164624473_IELTSluan_2.zip"
        ),
        VocabularySource(
            name: "托福",
            identifier: "TOEFL",
            type: .staticFile,
            githubURL: "https://github.com/kajweb/dict/raw/master/book/1521164640451_TOEFL_2.zip"
        ),
        VocabularySource(
            name: "GMAT",
            identifier: "GMAT",
            type: .staticFile,
            githubURL: "https://github.com/kajweb/dict/raw/master/book/1521164629611_GMATluan_2.zip"
        ),
        VocabularySource(
            name: "SAT",
            identifier: "SAT",
            type: .staticFile,
            githubURL: "https://github.com/kajweb/dict/raw/master/book/1521164670910_SAT_2.zip"
        ),
        VocabularySource(
            name: "GRE",
            identifier: "GRE",
            type: .staticFile,
            githubURL: "https://github.com/kajweb/dict/raw/master/book/1521164637271_GRE_2.zip"
        )
    ]
}
