//
//  CacheManagerTests.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import XCTest

@testable import learn_english

final class CacheManagerTests: XCTestCase {

    var cacheManager: CacheManager!

    override func setUp() {
        super.setUp()
        cacheManager = CacheManager.shared
    }

    override func tearDown() {
        cacheManager.clearCache()
        super.tearDown()
    }

    // MARK: - Cache Tests

    func testCacheWord() {
        let word = Word(
            headWord: "test",
            usPhonetic: "test",
            translations: [Translation(pos: "n.", tranCn: "测试")]
        )

        cacheManager.cacheWord(word)

        let cached = cacheManager.getCachedWord(for: "test")
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached?.headWord, "test")
    }

    func testCacheWordCaseInsensitive() {
        let word = Word(
            headWord: "Hello",
            translations: [Translation(pos: "interj.", tranCn: "你好")]
        )

        cacheManager.cacheWord(word)

        // 应该能用小写查找
        let cached = cacheManager.getCachedWord(for: "hello")
        XCTAssertNotNil(cached)
    }

    func testCacheWordNotFound() {
        let cached = cacheManager.getCachedWord(for: "nonexistent_word_xyz")
        XCTAssertNil(cached)
    }

    func testCacheBatchWords() {
        let words = [
            Word(headWord: "apple", translations: [Translation(pos: "n.", tranCn: "苹果")]),
            Word(headWord: "banana", translations: [Translation(pos: "n.", tranCn: "香蕉")]),
            Word(headWord: "cherry", translations: [Translation(pos: "n.", tranCn: "樱桃")]),
        ]

        cacheManager.cacheWords(words)

        XCTAssertNotNil(cacheManager.getCachedWord(for: "apple"))
        XCTAssertNotNil(cacheManager.getCachedWord(for: "banana"))
        XCTAssertNotNil(cacheManager.getCachedWord(for: "cherry"))
    }

    func testClearCache() {
        let word = Word(
            headWord: "test",
            translations: [Translation(pos: "n.", tranCn: "测试")]
        )

        cacheManager.cacheWord(word)
        XCTAssertNotNil(cacheManager.getCachedWord(for: "test"))

        cacheManager.clearCache()
        XCTAssertNil(cacheManager.getCachedWord(for: "test"))
    }

    func testCacheStats() {
        let words = [
            Word(headWord: "word1", translations: [Translation(pos: "n.", tranCn: "单词1")]),
            Word(headWord: "word2", translations: [Translation(pos: "n.", tranCn: "单词2")]),
        ]

        cacheManager.cacheWords(words)

        let stats = cacheManager.getCacheStats()
        XCTAssertGreaterThanOrEqual(stats.count, 2)
    }
}
