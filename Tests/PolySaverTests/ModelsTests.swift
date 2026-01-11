//
//  ModelsTests.swift
//  PolySaverTests
//
//  Created by AI Assistant on 1/12/26.
//

import XCTest
@testable import learn_english

final class ModelsTests: XCTestCase {
    
    // MARK: - Word Tests
    
    func testWordPrimaryTranslation() {
        let translations = [
            Translation(pos: "n.", tranCn: "苹果"),
            Translation(pos: "v.", tranCn: "吃苹果")
        ]
        let word = Word(headWord: "apple", translations: translations)
        
        XCTAssertEqual(word.primaryTranslation, "苹果")
    }
    
    func testWordPhoneticPreferUS() {
        let word = Word(
            headWord: "test",
            usPhonetic: "test",
            ukPhonetic: "test-uk",
            translations: [Translation(pos: "n.", tranCn: "测试")]
        )
        
        XCTAssertEqual(word.phonetic, "[test]")
    }
    
    func testWordPhoneticFallbackToUK() {
        let word = Word(
            headWord: "test",
            usPhonetic: nil,
            ukPhonetic: "test-uk",
            translations: [Translation(pos: "n.", tranCn: "测试")]
        )
        
        XCTAssertEqual(word.phonetic, "[test-uk]")
    }
    
    func testWordPhoneticEmpty() {
        let word = Word(
            headWord: "test",
            translations: [Translation(pos: "n.", tranCn: "测试")]
        )
        
        XCTAssertEqual(word.phonetic, "")
    }
    
    func testWordTranslationDisplay() {
        let translations = [
            Translation(pos: "n.", tranCn: "苹果"),
            Translation(pos: "v.", tranCn: "吃")
        ]
        let word = Word(headWord: "apple", translations: translations)
        
        XCTAssertEqual(word.translationDisplay, "n. 苹果; v. 吃")
    }
    
    // MARK: - Translation Tests
    
    func testTranslationInit() {
        let translation = Translation(pos: "adj.", tranCn: "美丽的", tranOther: "beautiful")
        
        XCTAssertEqual(translation.pos, "adj.")
        XCTAssertEqual(translation.tranCn, "美丽的")
        XCTAssertEqual(translation.tranOther, "beautiful")
    }
    
    // MARK: - Sentence Tests
    
    func testSentenceInit() {
        let sentence = Sentence(sContent: "Hello world", sCn: "你好世界")
        
        XCTAssertEqual(sentence.sContent, "Hello world")
        XCTAssertEqual(sentence.sCn, "你好世界")
    }
    
    // MARK: - APIProvider Tests
    
    func testAPIProviderRequiresKey() {
        XCTAssertTrue(APIProvider.google.requiresAPIKey)
        XCTAssertTrue(APIProvider.youdao.requiresAPIKey)
        XCTAssertFalse(APIProvider.bing.requiresAPIKey)
    }
    
    func testAPIProviderFreeQuota() {
        XCTAssertNil(APIProvider.google.freeQuota)
        XCTAssertEqual(APIProvider.youdao.freeQuota, 100)
        XCTAssertEqual(APIProvider.bing.freeQuota, 1000)
    }
    
    // MARK: - VocabularySource Tests
    
    func testVocabularySourcePredefined() {
        let sources = VocabularySource.predefinedSources
        
        XCTAssertFalse(sources.isEmpty)
        XCTAssertTrue(sources.contains { $0.identifier == "CET4" })
        XCTAssertTrue(sources.contains { $0.identifier == "CET6" })
        XCTAssertTrue(sources.contains { $0.identifier == "TOEFL" })
    }
    
    func testVocabularySourceLocalPath() {
        let source = VocabularySource(
            name: "Test",
            identifier: "TEST",
            type: .staticFile
        )
        
        XCTAssertTrue(source.localPath.path.contains("TEST"))
        XCTAssertTrue(source.jsonFilePath.path.contains("TEST.json"))
    }
}
