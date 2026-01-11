//
//  LearnEnglishView.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import AppKit
import ScreenSaver

@objc(LearnEnglishView)
class LearnEnglishView: ScreenSaverView {

    // MARK: - Properties

    private var currentWord: Word?
    private var wordTimer: Timer?

    // UI Layers
    private var gradientLayer: CAGradientLayer?
    private var leftCircle: CAShapeLayer?
    private var rightCircle: CAShapeLayer?
    private var cardView: NSView?
    private var wordLabel: NSTextField?
    private var phoneticLabel: NSTextField?
    private var translationLabel: NSTextField?
    private var progressLabel: NSTextField?
    private var exampleLabel: NSTextField?

    // Vocabulary Manager
    private let vocabularyManager = VocabularyManager.shared
    private let learningTracker = WordLearningTracker.shared
    private let speechService = SpeechService.shared

    // Animation
    private var isWordTransitioning = false
    private var animationTimer: Timer?

    // MARK: - Initialization

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true
        animationTimeInterval = 1.0 / 30.0  // 30 FPS

        // 设置背景色
        layer?.backgroundColor = NSColor.black.cgColor

        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        guard let layer = layer else { return }

        // 1. 渐变背景
        setupGradientBackground()

        // 2. 装饰圆形
        setupDecorativeCircles()

        // 3. 单词卡片
        setupWordCard()
    }

    private func setupGradientBackground() {
        guard let layer = layer else { return }

        // 创建渐变背景
        gradientLayer = CAGradientLayer()
        gradientLayer?.frame = bounds
        gradientLayer?.colors = [
            NSColor(red: 0.05, green: 0.05, blue: 0.1, alpha: 1.0).cgColor,
            NSColor(red: 0.1, green: 0.08, blue: 0.15, alpha: 1.0).cgColor,
        ]
        gradientLayer?.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer?.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer!)
    }

    private func setupDecorativeCircles() {
        guard let layer = layer else { return }

        let circleRadius: CGFloat = min(bounds.width, bounds.height) * 0.3

        // 左下角青色圆形
        leftCircle = CAShapeLayer()
        let leftPath = CGPath(
            ellipseIn: CGRect(
                x: -circleRadius * 0.5,
                y: -circleRadius * 0.5,
                width: circleRadius,
                height: circleRadius),
            transform: nil)
        leftCircle?.path = leftPath
        leftCircle?.fillColor = NSColor.gradientCyan.cgColor
        leftCircle?.opacity = 0.4
        layer.addSublayer(leftCircle!)

        // 右上角粉色圆形
        rightCircle = CAShapeLayer()
        let rightPath = CGPath(
            ellipseIn: CGRect(
                x: bounds.width - circleRadius * 0.5,
                y: bounds.height - circleRadius * 0.5,
                width: circleRadius,
                height: circleRadius),
            transform: nil)
        rightCircle?.path = rightPath
        rightCircle?.fillColor = NSColor.gradientPink.cgColor
        rightCircle?.opacity = 0.4
        layer.addSublayer(rightCircle!)
    }

    private func setupWordCard() {
        let cardWidth: CGFloat = min(650, bounds.width * 0.8)
        let cardHeight: CGFloat = min(400, bounds.height * 0.6)
        let cardX = (bounds.width - cardWidth) / 2
        let cardY = (bounds.height - cardHeight) / 2

        // 创建卡片视图
        cardView = NSView(frame: NSRect(x: cardX, y: cardY, width: cardWidth, height: cardHeight))
        cardView?.wantsLayer = true
        cardView?.layer?.backgroundColor = NSColor.cardBackground.cgColor
        cardView?.layer?.cornerRadius = 24
        cardView?.layer?.shadowColor = NSColor.black.cgColor
        cardView?.layer?.shadowOpacity = 0.5
        cardView?.layer?.shadowOffset = CGSize(width: 0, height: -10)
        cardView?.layer?.shadowRadius = 30

        guard let cardView = cardView else { return }
        addSubview(cardView)

        // 单词文本 (顶部中央)
        wordLabel = createLabel(
            fontSize: min(56, cardWidth * 0.09),
            weight: .thin,
            alignment: .center,
            color: .primaryText
        )
        wordLabel?.frame = NSRect(x: 30, y: cardHeight - 100, width: cardWidth - 60, height: 70)
        cardView.addSubview(wordLabel!)

        // 音标 (单词下方)
        phoneticLabel = createLabel(
            fontSize: min(22, cardWidth * 0.035),
            weight: .regular,
            alignment: .center,
            color: .secondaryText
        )
        phoneticLabel?.frame = NSRect(x: 30, y: cardHeight - 145, width: cardWidth - 60, height: 30)
        cardView.addSubview(phoneticLabel!)

        // 翻译 (中间)
        translationLabel = createLabel(
            fontSize: min(20, cardWidth * 0.032),
            weight: .medium,
            alignment: .center,
            color: .primaryText
        )
        translationLabel?.frame = NSRect(
            x: 30, y: cardHeight - 220, width: cardWidth - 60, height: 60)
        translationLabel?.maximumNumberOfLines = 3
        translationLabel?.lineBreakMode = .byWordWrapping
        cardView.addSubview(translationLabel!)

        // 例句 (底部)
        exampleLabel = createLabel(
            fontSize: min(14, cardWidth * 0.022),
            weight: .regular,
            alignment: .center,
            color: .secondaryText
        )
        exampleLabel?.frame = NSRect(x: 30, y: 60, width: cardWidth - 60, height: 80)
        exampleLabel?.maximumNumberOfLines = 3
        exampleLabel?.lineBreakMode = .byWordWrapping
        cardView.addSubview(exampleLabel!)

        // 进度标签 (右下角)
        progressLabel = createLabel(
            fontSize: min(14, cardWidth * 0.022),
            weight: .regular,
            alignment: .right,
            color: NSColor(white: 0.5, alpha: 1.0)
        )
        progressLabel?.frame = NSRect(x: cardWidth - 180, y: 20, width: 150, height: 25)
        cardView.addSubview(progressLabel!)
    }

    private func createLabel(
        fontSize: CGFloat, weight: NSFont.Weight,
        alignment: NSTextAlignment, color: NSColor
    ) -> NSTextField {
        let label = NSTextField()
        label.isBezeled = false
        label.drawsBackground = false
        label.isEditable = false
        label.isSelectable = false
        label.textColor = color
        label.font = NSFont.systemFont(ofSize: fontSize, weight: weight)
        label.alignment = alignment
        label.cell?.wraps = true
        label.cell?.isScrollable = false
        return label
    }

    // MARK: - ScreenSaver Methods

    override func startAnimation() {
        super.startAnimation()

        // 加载第一个单词
        Task {
            await loadNextWord()
        }

        // 启动定时器
        let duration = UserDefaults.standard.displayDuration
        wordTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) {
            [weak self] _ in
            Task {
                await self?.loadNextWord()
            }
        }
    }

    override func stopAnimation() {
        super.stopAnimation()
        wordTimer?.invalidate()
        wordTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
    }

    override func draw(_ rect: NSRect) {
        super.draw(rect)
        NSColor.black.setFill()
        rect.fill()
    }

    override func animateOneFrame() {
        // 动画更新在定时器中处理
    }

    override var hasConfigureSheet: Bool {
        return true
    }

    override var configureSheet: NSWindow? {
        let controller = ConfigWindowController()
        return controller.window
    }

    // MARK: - Word Loading

    private func loadNextWord() async {
        guard !isWordTransitioning else { return }
        isWordTransitioning = true

        do {
            let word = try await vocabularyManager.getNextWord()

            // 标记为已学习
            learningTracker.markWordAsLearned(word.headWord)

            await MainActor.run {
                displayWord(word)
            }
        } catch {
            await MainActor.run {
                displayError(error.localizedDescription)
            }
        }

        isWordTransitioning = false
    }

    private func displayWord(_ word: Word) {
        // 淡出当前内容
        fadeOut { [weak self] in
            guard let self = self else { return }

            self.currentWord = word

            // 更新文本
            self.wordLabel?.stringValue = word.headWord
            self.phoneticLabel?.stringValue = word.phonetic
            self.translationLabel?.stringValue = word.translationDisplay

            // 显示例句（如果有）
            if let sentence = word.sentences?.first {
                self.exampleLabel?.stringValue = "📖 \(sentence.sContent)\n\(sentence.sCn)"
            } else {
                self.exampleLabel?.stringValue = ""
            }

            // 更新进度
            let (source, wordCount) = self.vocabularyManager.getCurrentSourceInfo()
            let stats = self.learningTracker.getStats()
            if let source = source {
                self.progressLabel?.stringValue = "\(source.name) · 已学 \(stats.learnedWordsCount)"
            } else {
                self.progressLabel?.stringValue = ""
            }

            // 淡入新内容
            self.fadeIn()

            // 自动朗读（如果启用）
            if self.speechService.autoSpeakEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.speechService.speak(word.headWord)
                }
            }
        }
    }

    private func displayError(_ message: String) {
        wordLabel?.stringValue = "⚠️"
        phoneticLabel?.stringValue = ""
        translationLabel?.stringValue = message
        exampleLabel?.stringValue = "请在设置中选择并下载词汇源"
        progressLabel?.stringValue = ""
    }

    // MARK: - Animations

    private func fadeOut(completion: @escaping () -> Void) {
        NSAnimationContext.runAnimationGroup(
            { context in
                context.duration = AppConstants.animationDuration
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                wordLabel?.animator().alphaValue = 0
                phoneticLabel?.animator().alphaValue = 0
                translationLabel?.animator().alphaValue = 0
                exampleLabel?.animator().alphaValue = 0
            }, completionHandler: completion)
    }

    private func fadeIn() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = AppConstants.animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            wordLabel?.animator().alphaValue = 1
            phoneticLabel?.animator().alphaValue = 1
            translationLabel?.animator().alphaValue = 1
            exampleLabel?.animator().alphaValue = 1
        })
    }

    // MARK: - Layout

    override func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize)
        updateLayout()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateLayout()
    }

    private func updateLayout() {
        // 更新渐变背景
        gradientLayer?.frame = bounds

        // 更新装饰圆形
        let circleRadius: CGFloat = min(bounds.width, bounds.height) * 0.3

        let leftPath = CGPath(
            ellipseIn: CGRect(
                x: -circleRadius * 0.5,
                y: -circleRadius * 0.5,
                width: circleRadius,
                height: circleRadius),
            transform: nil)
        leftCircle?.path = leftPath

        let rightPath = CGPath(
            ellipseIn: CGRect(
                x: bounds.width - circleRadius * 0.5,
                y: bounds.height - circleRadius * 0.5,
                width: circleRadius,
                height: circleRadius),
            transform: nil)
        rightCircle?.path = rightPath

        // 更新卡片位置
        let cardWidth: CGFloat = min(650, bounds.width * 0.8)
        let cardHeight: CGFloat = min(400, bounds.height * 0.6)
        let cardX = (bounds.width - cardWidth) / 2
        let cardY = (bounds.height - cardHeight) / 2

        cardView?.frame = NSRect(x: cardX, y: cardY, width: cardWidth, height: cardHeight)

        // 更新标签位置
        wordLabel?.frame = NSRect(x: 30, y: cardHeight - 100, width: cardWidth - 60, height: 70)
        phoneticLabel?.frame = NSRect(x: 30, y: cardHeight - 145, width: cardWidth - 60, height: 30)
        translationLabel?.frame = NSRect(
            x: 30, y: cardHeight - 220, width: cardWidth - 60, height: 60)
        exampleLabel?.frame = NSRect(x: 30, y: 60, width: cardWidth - 60, height: 80)
        progressLabel?.frame = NSRect(x: cardWidth - 180, y: 20, width: 150, height: 25)
    }

    deinit {
        wordTimer?.invalidate()
        animationTimer?.invalidate()
        speechService.stop()
    }
}
