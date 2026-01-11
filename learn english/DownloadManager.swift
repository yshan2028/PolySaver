//
//  DownloadManager.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import Foundation

// MARK: - Download Error
enum DownloadError: Error, LocalizedError {
    case invalidURL
    case downloadFailed(Error)
    case unzipFailed(Error)
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "无效的下载地址"
        case .downloadFailed(let error):
            return "下载失败: \(error.localizedDescription)"
        case .unzipFailed(let error):
            return "解压失败: \(error.localizedDescription)"
        case .fileNotFound:
            return "文件不存在"
        }
    }
}

// MARK: - Download Progress
struct DownloadProgress {
    let bytesDownloaded: Int64
    let totalBytes: Int64

    var progress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(bytesDownloaded) / Double(totalBytes)
    }

    var percentage: Int {
        return Int(progress * 100)
    }
}

// MARK: - Download Manager
/// 下载管理器 - 负责下载和解压ZIP文件
class DownloadManager: NSObject {
    static let shared = DownloadManager()

    private var activeDownloads: [String: URLSessionDownloadTask] = [:]
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    // 进度回调
    private var progressHandlers: [String: (DownloadProgress) -> Void] = [:]

    private override init() {
        super.init()
    }

    // MARK: - Public Methods

    /// 下载词汇源
    func downloadVocabularySource(
        _ source: VocabularySource,
        progressHandler: ((DownloadProgress) -> Void)? = nil
    ) async throws {
        guard let urlString = source.githubURL,
            let url = URL(string: urlString)
        else {
            throw DownloadError.invalidURL
        }

        // 检查是否已经下载
        if source.isDownloaded && FileManager.default.fileExists(atPath: source.jsonFilePath.path) {
            print("✅ 词汇源 \(source.name) 已存在，跳过下载")
            return
        }

        // 创建目标目录
        try FileManager.default.createDirectory(
            at: source.localPath, withIntermediateDirectories: true)

        // 设置进度回调
        if let handler = progressHandler {
            progressHandlers[source.identifier] = handler
        }

        do {
            // 下载文件
            let downloadLocation = try await download(from: url, identifier: source.identifier)

            // 解压缩
            try FileManager.default.unzipFile(at: downloadLocation, to: source.localPath)

            // 删除ZIP文件
            try? FileManager.default.removeItem(at: downloadLocation)

            // 更新下载状态
            UserDefaults.standard.addDownloadedSource(source.identifier)

            print("✅ 词汇源 \(source.name) 下载完成")
        } catch {
            // 清理失败的下载
            try? FileManager.default.removeItem(at: source.localPath)
            throw error
        }
    }

    /// 取消下载
    func cancelDownload(for identifier: String) {
        activeDownloads[identifier]?.cancel()
        activeDownloads.removeValue(forKey: identifier)
        progressHandlers.removeValue(forKey: identifier)
    }

    /// 删除词汇源
    func deleteVocabularySource(_ source: VocabularySource) throws {
        guard FileManager.default.fileExists(atPath: source.localPath.path) else {
            return
        }

        try FileManager.default.removeItem(at: source.localPath)

        // 更新下载状态
        var downloaded = UserDefaults.standard.downloadedSources
        downloaded.removeAll { $0 == source.identifier }
        UserDefaults.standard.downloadedSources = downloaded

        print("🗑️ 删除词汇源: \(source.name)")
    }

    // MARK: - Private Methods

    private func download(from url: URL, identifier: String) async throws -> URL {
        return try await withCheckedThrowingContinuation { continuation in
            let task = session.downloadTask(with: url) { [weak self] location, _, error in
                self?.activeDownloads.removeValue(forKey: identifier)
                self?.progressHandlers.removeValue(forKey: identifier)

                if let error = error {
                    continuation.resume(throwing: DownloadError.downloadFailed(error))
                    return
                }

                guard let location = location else {
                    continuation.resume(throwing: DownloadError.fileNotFound)
                    return
                }

                // 移动到临时位置
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent("\(identifier).zip")

                do {
                    try? FileManager.default.removeItem(at: tempURL)
                    try FileManager.default.moveItem(at: location, to: tempURL)
                    continuation.resume(returning: tempURL)
                } catch {
                    continuation.resume(throwing: DownloadError.downloadFailed(error))
                }
            }

            activeDownloads[identifier] = task
            task.resume()
        }
    }
}

// MARK: - URLSessionDownloadDelegate
extension DownloadManager: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        // 找到对应的identifier
        for (identifier, task) in activeDownloads where task == downloadTask {
            let progress = DownloadProgress(
                bytesDownloaded: totalBytesWritten,
                totalBytes: totalBytesExpectedToWrite
            )

            DispatchQueue.main.async {
                self.progressHandlers[identifier]?(progress)
            }
            break
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        // 在 download(from:identifier:) 方法中处理
    }
}
