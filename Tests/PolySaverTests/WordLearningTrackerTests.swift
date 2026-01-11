//
//  WordLearningTrackerTests.swift
//  PolySaverTests
//
//  Created by AI Assistant on 1/12/26.
//

import XCTest
@testable import learn_english

final class WordLearningTrackerTests: XCTestCase {
    
    var tracker: WordLearningTracker!
    
    override func setUp() {
        super.setUp()
        tracker = WordLearningTracker.shared
    }
    
    override func tearDown() {
        tracker.clearAll()
        super.tearDown()
    }
    
    // MARK: - Learning Tests
    
    func testMarkWordAsLearned() {
        tracker.markWordAsLearned("hello")
        
        XCTAssertTrue(tracker.isWordLearned("hello"))
        XCTAssertTrue(tracker.isWordLearned("HELLO"))  // 大小写不敏感
    }
    
    func testIsWordNotLearned() {
        XCTAssertFalse(tracker.isWordLearned("unknown_word"))
    }
    
    // MARK: - Favorite Tests
    
    func testFavoriteWord() {
        tracker.favoriteWord("beautiful")
        
        XCTAssertTrue(tracker.isWordFavorited("beautiful"))
        XCTAssertTrue(tracker.isWordFavorited("BEAUTIFUL"))
    }
    
    func testUnfavoriteWord() {
        tracker.favoriteWord("test")
        XCTAssertTrue(tracker.isWordFavorited("test"))
        
        tracker.unfavoriteWord("test")
        XCTAssertFalse(tracker.isWordFavorited("test"))
    }
    
    func testGetFavoritedWords() {
        tracker.favoriteWord("apple")
        tracker.favoriteWord("banana")
        tracker.favoriteWord("cherry")
        
        let favorites = tracker.getFavoritedWords()
        
        XCTAssertEqual(favorites.count, 3)
        XCTAssertTrue(favorites.contains("apple"))
        XCTAssertTrue(favorites.contains("banana"))
        XCTAssertTrue(favorites.contains("cherry"))
    }
    
    // MARK: - Stats Tests
    
    func testGetStats() {
        tracker.markWordAsLearned("word1")
        tracker.markWordAsLearned("word2")
        tracker.markWordAsLearned("word3")
        tracker.favoriteWord("word1")
        
        let stats = tracker.getStats()
        
        XCTAssertEqual(stats.learnedWordsCount, 3)
        XCTAssertEqual(stats.favoritedWordsCount, 1)
    }
    
    func testLearningProgress() {
        let stats = tracker.getStats()
        XCTAssertEqual(stats.learningProgress, "刚开始学习")
        
        tracker.markWordAsLearned("test")
        let newStats = tracker.getStats()
        XCTAssertTrue(newStats.learningProgress.contains("已学习"))
    }
    
    // MARK: - Clear Tests
    
    func testClearAll() {
        tracker.markWordAsLearned("word1")
        tracker.favoriteWord("word2")
        
        tracker.clearAll()
        
        XCTAssertFalse(tracker.isWordLearned("word1"))
        XCTAssertFalse(tracker.isWordFavorited("word2"))
        
        let stats = tracker.getStats()
        XCTAssertEqual(stats.learnedWordsCount, 0)
        XCTAssertEqual(stats.favoritedWordsCount, 0)
    }
}
