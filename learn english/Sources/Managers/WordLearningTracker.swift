//
//  WordLearningTracker.swift
//  learn english
//
//  Created by AI Assistant on 1/12/26.
//

import Foundation

// MARK: - Learning Stats
struct LearningStats {
    let learnedWordsCount: Int
    let favoritedWordsCount: Int
    let totalWordsShown: Int

    var learningProgress: String {
        if totalWordsShown == 0 {
            return "刚开始学习"
        }
        return "已学习 \(learnedWordsCount) 个单词"
    }
}

// MARK: - Word Learning Tracker
/// 学习进度跟踪器
class WordLearningTracker {
    static let shared = WordLearningTracker()

    private var learnedWords: Set<String> = []
    private var favoritedWords: Set<String> = []

    private init() {
        loadFromDefaults()
    }

    // MARK: - Public Methods

    /// 标记单词为已学习
    func markWordAsLearned(_ word: String) {
        let normalized = word.lowercased()
        learnedWords.insert(normalized)
        saveToDefaults()
    }

    /// 收藏单词
    func favoriteWord(_ word: String) {
        let normalized = word.lowercased()
        favoritedWords.insert(normalized)
        saveToDefaults()
    }

    /// 取消收藏
    func unfavoriteWord(_ word: String) {
        let normalized = word.lowercased()
        favoritedWords.remove(normalized)
        saveToDefaults()
    }

    /// 检查是否已学习
    func isWordLearned(_ word: String) -> Bool {
        return learnedWords.contains(word.lowercased())
    }

    /// 检查是否已收藏
    func isWordFavorited(_ word: String) -> Bool {
        return favoritedWords.contains(word.lowercased())
    }

    /// 获取学习统计
    func getStats() -> LearningStats {
        return LearningStats(
            learnedWordsCount: learnedWords.count,
            favoritedWordsCount: favoritedWords.count,
            totalWordsShown: learnedWords.count
        )
    }

    /// 获取收藏的单词列表
    func getFavoritedWords() -> [String] {
        return Array(favoritedWords).sorted()
    }

    /// 清除所有学习记录
    func clearAll() {
        learnedWords.removeAll()
        favoritedWords.removeAll()
        saveToDefaults()
    }

    // MARK: - Private Methods

    private func loadFromDefaults() {
        if let learned = UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.learnedWords) {
            learnedWords = Set(learned)
        }

        if let favorited = UserDefaults.standard.stringArray(
            forKey: UserDefaultsKeys.favoritedWords)
        {
            favoritedWords = Set(favorited)
        }
    }

    private func saveToDefaults() {
        UserDefaults.standard.set(Array(learnedWords), forKey: UserDefaultsKeys.learnedWords)
        UserDefaults.standard.set(Array(favoritedWords), forKey: UserDefaultsKeys.favoritedWords)
    }
}
