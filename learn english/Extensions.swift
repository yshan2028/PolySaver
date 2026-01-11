//
//  Extensions.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import AppKit
import CryptoKit
import Foundation

// MARK: - FileManager Extensions
extension FileManager {
    /// 词汇根目录
    static var vocabularyDirectory: URL {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        let vocabularyDir =
            appSupport
            .appendingPathComponent("PolySaver")
            .appendingPathComponent(FilePaths.vocabularyDirectoryName)

        // 确保目录存在
        try? FileManager.default.createDirectory(
            at: vocabularyDir, withIntermediateDirectories: true)

        return vocabularyDir
    }

    /// 自定义词汇目录
    static var customVocabularyDirectory: URL {
        let customDir = vocabularyDirectory.appendingPathComponent(FilePaths.customDirectoryName)
        try? FileManager.default.createDirectory(at: customDir, withIntermediateDirectories: true)
        return customDir
    }

    /// 缓存目录
    static var cacheDirectory: URL {
        let cacheDir = vocabularyDirectory.appendingPathComponent(FilePaths.cacheDirectoryName)
        try? FileManager.default.createDirectory(at: cacheDir, withIntermediateDirectories: true)
        return cacheDir
    }

    /// 解压ZIP文件
    func unzipFile(at sourceURL: URL, to destinationURL: URL) throws {
        // 使用系统的 unzip 命令
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-o", sourceURL.path, "-d", destinationURL.path]

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw NSError(
                domain: "UnzipError", code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: "解压失败"])
        }
    }
}

// MARK: - UserDefaults Extensions
extension UserDefaults {
    /// 已选择的词汇源
    var selectedSource: String? {
        get { string(forKey: UserDefaultsKeys.selectedVocabularySource) }
        set { set(newValue, forKey: UserDefaultsKeys.selectedVocabularySource) }
    }

    /// 单词显示时长
    var displayDuration: TimeInterval {
        get {
            let duration = double(forKey: UserDefaultsKeys.wordDisplayDuration)
            return duration > 0 ? duration : AppConstants.defaultDisplayDuration
        }
        set { set(newValue, forKey: UserDefaultsKeys.wordDisplayDuration) }
    }

    /// 首选API提供商
    var preferredAPIProvider: APIProvider {
        get {
            guard let rawValue = string(forKey: UserDefaultsKeys.preferredAPIProvider),
                let provider = APIProvider(rawValue: rawValue)
            else {
                return .youdao  // 默认使用有道
            }
            return provider
        }
        set { set(newValue.rawValue, forKey: UserDefaultsKeys.preferredAPIProvider) }
    }

    /// 已下载的词汇源列表
    var downloadedSources: [String] {
        get { stringArray(forKey: UserDefaultsKeys.downloadedSources) ?? [] }
        set { set(newValue, forKey: UserDefaultsKeys.downloadedSources) }
    }

    /// 添加已下载的词汇源
    func addDownloadedSource(_ identifier: String) {
        var sources = downloadedSources
        if !sources.contains(identifier) {
            sources.append(identifier)
            downloadedSources = sources
        }
    }
}

// MARK: - String Extensions
extension String {
    /// MD5 哈希（已废弃，仅用于兼容旧版）
    var md5: String {
        let digest = Insecure.MD5.hash(data: Data(self.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    /// SHA256 哈希（有道API v3 签名算法）
    var sha256: String {
        let digest = SHA256.hash(data: Data(self.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - NSColor Extensions
extension NSColor {
    /// 屏保主题色
    static let screensaverBackground = NSColor.black

    /// 渐变色 - 左下（青色）
    static let gradientCyan = NSColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 0.6)

    /// 渐变色 - 右上（粉色）
    static let gradientPink = NSColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 0.6)

    /// 卡片背景色（半透明）
    static let cardBackground = NSColor(white: 0.15, alpha: 0.8)

    /// 文字颜色
    static let primaryText = NSColor.white
    static let secondaryText = NSColor(white: 0.8, alpha: 1.0)
}

// MARK: - Date Extensions
extension Date {
    /// 是否是同一天
    func isSameDay(as other: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: other)
    }

    /// 是否是同一个月
    func isSameMonth(as other: Date) -> Bool {
        let components1 = Calendar.current.dateComponents([.year, .month], from: self)
        let components2 = Calendar.current.dateComponents([.year, .month], from: other)
        return components1.year == components2.year && components1.month == components2.month
    }
}
