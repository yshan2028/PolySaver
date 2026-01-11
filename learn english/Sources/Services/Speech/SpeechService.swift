//
//  SpeechService.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import AVFoundation
import Foundation

// MARK: - Speech Voice Type
enum SpeechVoiceType: String, CaseIterable {
    case american = "en-US"
    case british = "en-GB"
    case australian = "en-AU"
    
    var displayName: String {
        switch self {
        case .american: return "美式英语"
        case .british: return "英式英语"
        case .australian: return "澳式英语"
        }
    }
}

// MARK: - Speech Service
/// 语音朗读服务 - 使用系统 TTS
class SpeechService {
    static let shared = SpeechService()
    
    private let synthesizer = AVSpeechSynthesizer()
    private var currentVoiceType: SpeechVoiceType = .american
    
    // 语速设置 (0.0 - 1.0)
    var speechRate: Float = 0.45
    
    // 音量设置 (0.0 - 1.0)
    var volume: Float = 1.0
    
    // 是否启用自动朗读
    var autoSpeakEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "AutoSpeakEnabled") }
        set { UserDefaults.standard.set(newValue, forKey: "AutoSpeakEnabled") }
    }
    
    private init() {
        // 加载用户设置
        if let voiceType = UserDefaults.standard.string(forKey: "SpeechVoiceType"),
           let type = SpeechVoiceType(rawValue: voiceType) {
            currentVoiceType = type
        }
        
        speechRate = UserDefaults.standard.float(forKey: "SpeechRate")
        if speechRate == 0 { speechRate = 0.45 }
        
        volume = UserDefaults.standard.float(forKey: "SpeechVolume")
        if volume == 0 { volume = 1.0 }
    }
    
    // MARK: - Public Methods
    
    /// 朗读单词
    func speak(_ text: String) {
        // 停止当前朗读
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = speechRate
        utterance.volume = volume
        utterance.pitchMultiplier = 1.0
        
        // 选择语音
        if let voice = AVSpeechSynthesisVoice(language: currentVoiceType.rawValue) {
            utterance.voice = voice
        }
        
        synthesizer.speak(utterance)
    }
    
    /// 朗读单词（带例句）
    func speakWord(_ word: Word) {
        var textToSpeak = word.headWord
        
        // 如果有例句，也朗读第一个例句
        if let sentence = word.sentences?.first {
            textToSpeak += ". " + sentence.sContent
        }
        
        speak(textToSpeak)
    }
    
    /// 停止朗读
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    /// 设置语音类型
    func setVoiceType(_ type: SpeechVoiceType) {
        currentVoiceType = type
        UserDefaults.standard.set(type.rawValue, forKey: "SpeechVoiceType")
    }
    
    /// 获取当前语音类型
    func getVoiceType() -> SpeechVoiceType {
        return currentVoiceType
    }
    
    /// 保存设置
    func saveSettings() {
        UserDefaults.standard.set(speechRate, forKey: "SpeechRate")
        UserDefaults.standard.set(volume, forKey: "SpeechVolume")
    }
    
    /// 获取可用的语音列表
    func getAvailableVoices() -> [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language.starts(with: "en")
        }
    }
    
    /// 检查 TTS 是否可用
    var isAvailable: Bool {
        return !AVSpeechSynthesisVoice.speechVoices().isEmpty
    }
    
    /// 是否正在朗读
    var isSpeaking: Bool {
        return synthesizer.isSpeaking
    }
}
