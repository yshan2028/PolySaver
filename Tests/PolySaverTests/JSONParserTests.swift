//
//  JSONParserTests.swift
//  PolySaverTests
//
//  Created by AI Assistant on 1/12/26.
//

import XCTest
@testable import learn_english

final class JSONParserTests: XCTestCase {
    
    var tempDirectory: URL!
    
    override func setUp() {
        super.setUp()
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("PolySaverTests_\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempDirectory)
        super.tearDown()
    }
    
    // MARK: - Parse Tests
    
    func testParseVocabularyFile() throws {
        // 创建测试 JSON 文件
        let testJSON = """
        [
            {
                "wordRank": 1,
                "headWord": "hello",
                "content": {
                    "word": {
                        "content": {
                            "usphone": "həˈloʊ",
                            "ukphone": "həˈləʊ",
                            "trans": [
                                {"pos": "interj.", "tranCn": "你好", "tranOther": "greeting"}
                            ],
                            "sentence": {
                                "sentences": [
                                    {"sContent": "Hello, world!", "sCn": "你好，世界！"}
                                ]
                            }
                        }
                    }
                }
            }
        ]
        """
        
        let fileURL = tempDirectory.appendingPathComponent("test.json")
        try testJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        let words = try JSONParser.parseVocabularyFile(at: fileURL)
        
        XCTAssertEqual(words.count, 1)
        XCTAssertEqual(words[0].headWord, "hello")
        XCTAssertEqual(words[0].usPhonetic, "həˈloʊ")
        XCTAssertEqual(words[0].ukPhonetic, "həˈləʊ")
        XCTAssertEqual(words[0].translations.count, 1)
        XCTAssertEqual(words[0].translations[0].pos, "interj.")
        XCTAssertEqual(words[0].translations[0].tranCn, "你好")
        XCTAssertEqual(words[0].sentences?.count, 1)
        XCTAssertEqual(words[0].sentences?[0].sContent, "Hello, world!")
    }
    
    func testParseVocabularyFileNotFound() {
        let nonExistentURL = tempDirectory.appendingPathComponent("nonexistent.json")
        
        XCTAssertThrowsError(try JSONParser.parseVocabularyFile(at: nonExistentURL))
    }
    
    func testParseVocabularyDirectory() throws {
        // 创建多个测试 JSON 文件
        let testJSON1 = """
        [{"wordRank": 1, "headWord": "apple", "content": {"word": {"content": {"trans": [{"pos": "n.", "tranCn": "苹果"}]}}}}]
        """
        let testJSON2 = """
        [{"wordRank": 1, "headWord": "banana", "content": {"word": {"content": {"trans": [{"pos": "n.", "tranCn": "香蕉"}]}}}}]
        """
        
        try testJSON1.write(to: tempDirectory.appendingPathComponent("file1.json"), atomically: true, encoding: .utf8)
        try testJSON2.write(to: tempDirectory.appendingPathComponent("file2.json"), atomically: true, encoding: .utf8)
        
        let words = try JSONParser.parseVocabularyDirectory(at: tempDirectory)
        
        XCTAssertEqual(words.count, 2)
        XCTAssertTrue(words.contains { $0.headWord == "apple" })
        XCTAssertTrue(words.contains { $0.headWord == "banana" })
    }
    
    func testParseEmptyDirectory() throws {
        let emptyDir = tempDirectory.appendingPathComponent("empty")
        try FileManager.default.createDirectory(at: emptyDir, withIntermediateDirectories: true)
        
        let words = try JSONParser.parseVocabularyDirectory(at: emptyDir)
        
        XCTAssertTrue(words.isEmpty)
    }
    
    func testParseInvalidJSON() throws {
        let invalidJSON = "{ invalid json }"
        let fileURL = tempDirectory.appendingPathComponent("invalid.json")
        try invalidJSON.write(to: fileURL, atomically: true, encoding: .utf8)
        
        XCTAssertThrowsError(try JSONParser.parseVocabularyFile(at: fileURL))
    }
}
