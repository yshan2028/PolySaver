//
//  ExtensionsTests.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import XCTest

@testable import learn_english

final class ExtensionsTests: XCTestCase {

    // MARK: - String Extension Tests

    func testMD5Hash() {
        let testString = "hello"
        let md5 = testString.md5

        XCTAssertEqual(md5, "5d41402abc4b2a76b9719d911017c592")
    }

    func testSHA256Hash() {
        let testString = "hello"
        let sha256 = testString.sha256

        XCTAssertEqual(sha256, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
    }

    func testEmptyStringHash() {
        let emptyString = ""

        XCTAssertFalse(emptyString.md5.isEmpty)
        XCTAssertFalse(emptyString.sha256.isEmpty)
    }

    // MARK: - Date Extension Tests

    func testIsSameDay() {
        let date1 = Date()
        let date2 = Date()

        XCTAssertTrue(date1.isSameDay(as: date2))
    }

    func testIsSameDayDifferentDays() {
        let date1 = Date()
        let date2 = Calendar.current.date(byAdding: .day, value: -1, to: date1)!

        XCTAssertFalse(date1.isSameDay(as: date2))
    }

    func testIsSameMonth() {
        let date1 = Date()
        let date2 = Date()

        XCTAssertTrue(date1.isSameMonth(as: date2))
    }

    func testIsSameMonthDifferentMonths() {
        let date1 = Date()
        let date2 = Calendar.current.date(byAdding: .month, value: -1, to: date1)!

        XCTAssertFalse(date1.isSameMonth(as: date2))
    }

    // MARK: - UserDefaults Extension Tests

    func testDisplayDurationDefault() {
        // 清除现有设置
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.wordDisplayDuration)

        let duration = UserDefaults.standard.displayDuration

        XCTAssertEqual(duration, AppConstants.defaultDisplayDuration)
    }

    func testDisplayDurationSet() {
        UserDefaults.standard.displayDuration = 10.0

        XCTAssertEqual(UserDefaults.standard.displayDuration, 10.0)

        // 清理
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.wordDisplayDuration)
    }

    func testDownloadedSources() {
        // 清除现有设置
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.downloadedSources)

        XCTAssertTrue(UserDefaults.standard.downloadedSources.isEmpty)

        UserDefaults.standard.addDownloadedSource("CET4")
        UserDefaults.standard.addDownloadedSource("CET6")

        XCTAssertEqual(UserDefaults.standard.downloadedSources.count, 2)
        XCTAssertTrue(UserDefaults.standard.downloadedSources.contains("CET4"))
        XCTAssertTrue(UserDefaults.standard.downloadedSources.contains("CET6"))

        // 重复添加不应增加
        UserDefaults.standard.addDownloadedSource("CET4")
        XCTAssertEqual(UserDefaults.standard.downloadedSources.count, 2)

        // 清理
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.downloadedSources)
    }

    // MARK: - FileManager Extension Tests

    func testVocabularyDirectory() {
        let dir = FileManager.vocabularyDirectory

        XCTAssertTrue(dir.path.contains("PolySaver"))
        XCTAssertTrue(dir.path.contains("Vocabularies"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: dir.path))
    }

    func testCacheDirectory() {
        let dir = FileManager.cacheDirectory

        XCTAssertTrue(dir.path.contains("Cache"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: dir.path))
    }

    func testCustomVocabularyDirectory() {
        let dir = FileManager.customVocabularyDirectory

        XCTAssertTrue(dir.path.contains("Custom"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: dir.path))
    }
}
