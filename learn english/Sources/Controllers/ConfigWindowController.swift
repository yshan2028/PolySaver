//
//  ConfigWindowController.swift
//  PolySaver
//
//  Created by Kimi on 1/12/26.
//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.
//

import Cocoa

class ConfigWindowController: NSWindowController {

    // MARK: - Properties

    private var tableView: NSTableView!
    private var progressIndicator: NSProgressIndicator!
    private var sourceLabel: NSTextField!
    private var durationPopup: NSPopUpButton!

    // API 配置控件
    private var apiTabView: NSTabView!
    private var youdaoAppKeyField: NSTextField!
    private var youdaoAppSecretField: NSSecureTextField!
    private var googleApiKeyField: NSSecureTextField!
    private var bingApiKeyField: NSSecureTextField!
    private var apiProviderPopup: NSPopUpButton!

    private var vocabularySources: [VocabularySource] = []
    private let vocabularyManager = VocabularyManager.shared
    private let downloadManager = DownloadManager.shared

    // MARK: - Initialization

    init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 650, height: 580),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "PolySaver - 词汇学习屏保设置"
        window.center()

        super.init(window: window)

        setupUI()
        loadData()
        loadAPISettings()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - UI Setup

    private func setupUI() {
        guard let window = window else { return }
        let contentView = NSView(frame: window.contentView!.bounds)
        contentView.autoresizingMask = [.width, .height]

        // 创建 TabView
        apiTabView = NSTabView(frame: NSRect(x: 10, y: 10, width: 630, height: 560))

        // Tab 1: 词汇源管理
        let vocabularyTab = NSTabViewItem(identifier: "vocabulary")
        vocabularyTab.label = "词汇源"
        vocabularyTab.view = createVocabularyTabView()
        apiTabView.addTabViewItem(vocabularyTab)

        // Tab 2: API 设置
        let apiTab = NSTabViewItem(identifier: "api")
        apiTab.label = "API 设置"
        apiTab.view = createAPITabView()
        apiTabView.addTabViewItem(apiTab)

        // Tab 3: 显示设置
        let displayTab = NSTabViewItem(identifier: "display")
        displayTab.label = "显示设置"
        displayTab.view = createDisplayTabView()
        apiTabView.addTabViewItem(displayTab)

        contentView.addSubview(apiTabView)
        window.contentView = contentView
    }

    private func createVocabularyTabView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 610, height: 500))

        // 标题
        let titleLabel = NSTextField(labelWithString: "词汇源管理")
        titleLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.frame = NSRect(x: 20, y: 460, width: 560, height: 25)
        view.addSubview(titleLabel)

        // 表格视图
        let scrollView = NSScrollView(frame: NSRect(x: 20, y: 120, width: 570, height: 330))
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .bezelBorder

        tableView = NSTableView(frame: scrollView.bounds)
        tableView.headerView = NSTableHeaderView()

        let nameColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("name"))
        nameColumn.title = "词汇源"
        nameColumn.width = 180
        tableView.addTableColumn(nameColumn)

        let statusColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("status"))
        statusColumn.title = "状态"
        statusColumn.width = 100
        tableView.addTableColumn(statusColumn)

        let actionColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("action"))
        actionColumn.title = "操作"
        actionColumn.width = 270
        tableView.addTableColumn(actionColumn)

        tableView.delegate = self
        tableView.dataSource = self

        scrollView.documentView = tableView
        view.addSubview(scrollView)

        // 进度条
        progressIndicator = NSProgressIndicator(
            frame: NSRect(x: 20, y: 85, width: 570, height: 20))
        progressIndicator.isIndeterminate = false
        progressIndicator.minValue = 0
        progressIndicator.maxValue = 100
        progressIndicator.doubleValue = 0
        progressIndicator.isHidden = true
        view.addSubview(progressIndicator)

        // 当前词汇源标签
        sourceLabel = NSTextField(labelWithString: "当前词汇源: 未设置")
        sourceLabel.frame = NSRect(x: 20, y: 50, width: 570, height: 20)
        view.addSubview(sourceLabel)

        // 提示信息
        let tipLabel = NSTextField(labelWithString: "💡 提示: 选择词汇源后点击「下载」，下载完成后点击「使用」激活")
        tipLabel.font = NSFont.systemFont(ofSize: 11)
        tipLabel.textColor = .secondaryLabelColor
        tipLabel.frame = NSRect(x: 20, y: 20, width: 570, height: 20)
        view.addSubview(tipLabel)

        // 自定义导入按钮
        let importButton = NSButton(
            title: "导入自定义词汇...", target: self, action: #selector(importCustomVocabulary))
        importButton.bezelStyle = .rounded
        importButton.frame = NSRect(x: 440, y: 15, width: 150, height: 32)
        view.addSubview(importButton)

        return view
    }

    private func createAPITabView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 610, height: 500))

        // 标题
        let titleLabel = NSTextField(labelWithString: "翻译 API 配置")
        titleLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.frame = NSRect(x: 20, y: 460, width: 560, height: 25)
        view.addSubview(titleLabel)

        // 首选 API 提供商
        let providerLabel = NSTextField(labelWithString: "首选翻译服务:")
        providerLabel.frame = NSRect(x: 20, y: 420, width: 120, height: 20)
        view.addSubview(providerLabel)

        apiProviderPopup = NSPopUpButton(
            frame: NSRect(x: 150, y: 415, width: 200, height: 28), pullsDown: false)
        for provider in APIProvider.allCases {
            apiProviderPopup.addItem(withTitle: provider.displayName)
        }
        apiProviderPopup.target = self
        apiProviderPopup.action = #selector(apiProviderChanged(_:))
        view.addSubview(apiProviderPopup)

        // 分隔线
        let separator1 = NSBox(frame: NSRect(x: 20, y: 400, width: 570, height: 1))
        separator1.boxType = .separator
        view.addSubview(separator1)

        // 有道翻译配置
        let youdaoTitle = NSTextField(labelWithString: "有道翻译 (推荐，免费100次/天)")
        youdaoTitle.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        youdaoTitle.frame = NSRect(x: 20, y: 360, width: 400, height: 20)
        view.addSubview(youdaoTitle)

        let youdaoKeyLabel = NSTextField(labelWithString: "App Key:")
        youdaoKeyLabel.frame = NSRect(x: 40, y: 330, width: 80, height: 20)
        view.addSubview(youdaoKeyLabel)

        youdaoAppKeyField = NSTextField(frame: NSRect(x: 130, y: 325, width: 300, height: 24))
        youdaoAppKeyField.placeholderString = "输入有道 App Key"
        view.addSubview(youdaoAppKeyField)

        let youdaoSecretLabel = NSTextField(labelWithString: "App Secret:")
        youdaoSecretLabel.frame = NSRect(x: 40, y: 295, width: 80, height: 20)
        view.addSubview(youdaoSecretLabel)

        youdaoAppSecretField = NSSecureTextField(
            frame: NSRect(x: 130, y: 290, width: 300, height: 24))
        youdaoAppSecretField.placeholderString = "输入有道 App Secret"
        view.addSubview(youdaoAppSecretField)

        let youdaoHelpButton = NSButton(
            title: "获取密钥 →", target: self, action: #selector(openYoudaoHelp))
        youdaoHelpButton.bezelStyle = .inline
        youdaoHelpButton.frame = NSRect(x: 440, y: 325, width: 100, height: 24)
        view.addSubview(youdaoHelpButton)

        // 分隔线
        let separator2 = NSBox(frame: NSRect(x: 20, y: 270, width: 570, height: 1))
        separator2.boxType = .separator
        view.addSubview(separator2)

        // Google 翻译配置
        let googleTitle = NSTextField(labelWithString: "Google 翻译 (付费，高质量)")
        googleTitle.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        googleTitle.frame = NSRect(x: 20, y: 240, width: 400, height: 20)
        view.addSubview(googleTitle)

        let googleKeyLabel = NSTextField(labelWithString: "API Key:")
        googleKeyLabel.frame = NSRect(x: 40, y: 210, width: 80, height: 20)
        view.addSubview(googleKeyLabel)

        googleApiKeyField = NSSecureTextField(frame: NSRect(x: 130, y: 205, width: 300, height: 24))
        googleApiKeyField.placeholderString = "输入 Google Cloud API Key"
        view.addSubview(googleApiKeyField)

        let googleHelpButton = NSButton(
            title: "获取密钥 →", target: self, action: #selector(openGoogleHelp))
        googleHelpButton.bezelStyle = .inline
        googleHelpButton.frame = NSRect(x: 440, y: 205, width: 100, height: 24)
        view.addSubview(googleHelpButton)

        // 分隔线
        let separator3 = NSBox(frame: NSRect(x: 20, y: 185, width: 570, height: 1))
        separator3.boxType = .separator
        view.addSubview(separator3)

        // 必应翻译配置
        let bingTitle = NSTextField(labelWithString: "必应翻译 (免费200万字符/月)")
        bingTitle.font = NSFont.systemFont(ofSize: 13, weight: .medium)
        bingTitle.frame = NSRect(x: 20, y: 155, width: 400, height: 20)
        view.addSubview(bingTitle)

        let bingKeyLabel = NSTextField(labelWithString: "API Key:")
        bingKeyLabel.frame = NSRect(x: 40, y: 125, width: 80, height: 20)
        view.addSubview(bingKeyLabel)

        bingApiKeyField = NSSecureTextField(frame: NSRect(x: 130, y: 120, width: 300, height: 24))
        bingApiKeyField.placeholderString = "输入 Azure Translator API Key"
        view.addSubview(bingApiKeyField)

        let bingHelpButton = NSButton(
            title: "获取密钥 →", target: self, action: #selector(openBingHelp))
        bingHelpButton.bezelStyle = .inline
        bingHelpButton.frame = NSRect(x: 440, y: 120, width: 100, height: 24)
        view.addSubview(bingHelpButton)

        // 保存按钮
        let saveButton = NSButton(
            title: "保存 API 设置", target: self, action: #selector(saveAPISettings))
        saveButton.bezelStyle = .rounded
        saveButton.frame = NSRect(x: 20, y: 50, width: 120, height: 32)
        view.addSubview(saveButton)

        // 测试按钮
        let testButton = NSButton(title: "测试连接", target: self, action: #selector(testAPIConnection))
        testButton.bezelStyle = .rounded
        testButton.frame = NSRect(x: 150, y: 50, width: 100, height: 32)
        view.addSubview(testButton)

        // 提示
        let tipLabel = NSTextField(labelWithString: "💡 提示: 离线词汇源无需配置 API，仅在线翻译或自定义导入时需要")
        tipLabel.font = NSFont.systemFont(ofSize: 11)
        tipLabel.textColor = .secondaryLabelColor
        tipLabel.frame = NSRect(x: 20, y: 20, width: 570, height: 20)
        view.addSubview(tipLabel)

        return view
    }

    private func createDisplayTabView() -> NSView {
        let view = NSView(frame: NSRect(x: 0, y: 0, width: 610, height: 500))

        // 标题
        let titleLabel = NSTextField(labelWithString: "显示设置")
        titleLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.frame = NSRect(x: 20, y: 460, width: 560, height: 25)
        view.addSubview(titleLabel)

        // 显示时长设置
        let durationLabel = NSTextField(labelWithString: "单词显示时长:")
        durationLabel.frame = NSRect(x: 20, y: 420, width: 120, height: 20)
        view.addSubview(durationLabel)

        durationPopup = NSPopUpButton(
            frame: NSRect(x: 150, y: 415, width: 150, height: 28), pullsDown: false)
        durationPopup.addItems(withTitles: ["2秒", "3秒", "5秒", "10秒", "15秒", "30秒"])
        durationPopup.target = self
        durationPopup.action = #selector(durationChanged(_:))

        // 设置当前选中项
        let currentDuration = UserDefaults.standard.displayDuration
        switch currentDuration {
        case 2: durationPopup.selectItem(at: 0)
        case 3: durationPopup.selectItem(at: 1)
        case 5: durationPopup.selectItem(at: 2)
        case 10: durationPopup.selectItem(at: 3)
        case 15: durationPopup.selectItem(at: 4)
        case 30: durationPopup.selectItem(at: 5)
        default: durationPopup.selectItem(at: 2)  // 默认5秒
        }
        view.addSubview(durationPopup)

        // 语音设置
        let speechTitle = NSTextField(labelWithString: "语音朗读")
        speechTitle.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        speechTitle.frame = NSRect(x: 20, y: 375, width: 200, height: 20)
        view.addSubview(speechTitle)

        let autoSpeakCheckbox = NSButton(
            checkboxWithTitle: "自动朗读单词", target: self, action: #selector(autoSpeakChanged(_:)))
        autoSpeakCheckbox.frame = NSRect(x: 40, y: 345, width: 200, height: 20)
        autoSpeakCheckbox.state = SpeechService.shared.autoSpeakEnabled ? .on : .off
        view.addSubview(autoSpeakCheckbox)

        let voiceLabel = NSTextField(labelWithString: "语音类型:")
        voiceLabel.frame = NSRect(x: 40, y: 315, width: 80, height: 20)
        view.addSubview(voiceLabel)

        let voicePopup = NSPopUpButton(
            frame: NSRect(x: 130, y: 310, width: 150, height: 28), pullsDown: false)
        for voiceType in SpeechVoiceType.allCases {
            voicePopup.addItem(withTitle: voiceType.displayName)
        }
        if let index = SpeechVoiceType.allCases.firstIndex(of: SpeechService.shared.getVoiceType())
        {
            voicePopup.selectItem(at: index)
        }
        voicePopup.target = self
        voicePopup.action = #selector(voiceTypeChanged(_:))
        view.addSubview(voicePopup)

        let testSpeechButton = NSButton(title: "测试朗读", target: self, action: #selector(testSpeech))
        testSpeechButton.bezelStyle = .rounded
        testSpeechButton.frame = NSRect(x: 290, y: 310, width: 80, height: 28)
        view.addSubview(testSpeechButton)

        // 学习统计
        let statsTitle = NSTextField(labelWithString: "学习统计")
        statsTitle.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        statsTitle.frame = NSRect(x: 20, y: 265, width: 200, height: 20)
        view.addSubview(statsTitle)

        let stats = WordLearningTracker.shared.getStats()
        let statsLabel = NSTextField(
            labelWithString: """
                已学习单词: \(stats.learnedWordsCount) 个
                收藏单词: \(stats.favoritedWordsCount) 个
                """)
        statsLabel.frame = NSRect(x: 40, y: 210, width: 300, height: 50)
        statsLabel.isEditable = false
        statsLabel.isBordered = false
        statsLabel.backgroundColor = .clear
        view.addSubview(statsLabel)

        // 缓存统计
        let cacheTitle = NSTextField(labelWithString: "缓存管理")
        cacheTitle.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        cacheTitle.frame = NSRect(x: 20, y: 175, width: 200, height: 20)
        view.addSubview(cacheTitle)

        let cacheStats = CacheManager.shared.getCacheStats()
        let cacheLabel = NSTextField(
            labelWithString:
                "缓存单词: \(cacheStats.count) 个，占用: \(ByteCountFormatter.string(fromByteCount: cacheStats.size, countStyle: .file))"
        )
        cacheLabel.frame = NSRect(x: 40, y: 145, width: 400, height: 20)
        cacheLabel.isEditable = false
        cacheLabel.isBordered = false
        cacheLabel.backgroundColor = .clear
        view.addSubview(cacheLabel)

        let clearCacheButton = NSButton(title: "清除缓存", target: self, action: #selector(clearCache))
        clearCacheButton.bezelStyle = .rounded
        clearCacheButton.frame = NSRect(x: 40, y: 110, width: 100, height: 28)
        view.addSubview(clearCacheButton)

        // 重置学习进度
        let resetTitle = NSTextField(labelWithString: "重置选项")
        resetTitle.font = NSFont.systemFont(ofSize: 14, weight: .medium)
        resetTitle.frame = NSRect(x: 20, y: 75, width: 200, height: 20)
        view.addSubview(resetTitle)

        let resetProgressButton = NSButton(
            title: "重置学习进度", target: self, action: #selector(resetLearningProgress))
        resetProgressButton.bezelStyle = .rounded
        resetProgressButton.frame = NSRect(x: 40, y: 40, width: 120, height: 28)
        view.addSubview(resetProgressButton)

        let resetAllButton = NSButton(
            title: "恢复默认设置", target: self, action: #selector(resetAllSettings))
        resetAllButton.bezelStyle = .rounded
        resetAllButton.frame = NSRect(x: 170, y: 40, width: 120, height: 28)
        view.addSubview(resetAllButton)

        // 关于信息
        let aboutLabel = NSTextField(labelWithString: "PolySaver v1.0 - 让碎片时间成为学习时间")
        aboutLabel.font = NSFont.systemFont(ofSize: 11)
        aboutLabel.textColor = .tertiaryLabelColor
        aboutLabel.frame = NSRect(x: 20, y: 10, width: 570, height: 20)
        view.addSubview(aboutLabel)

        return view
    }

    @objc private func autoSpeakChanged(_ sender: NSButton) {
        SpeechService.shared.autoSpeakEnabled = (sender.state == .on)
    }

    @objc private func voiceTypeChanged(_ sender: NSPopUpButton) {
        let voiceTypes = SpeechVoiceType.allCases
        guard sender.indexOfSelectedItem < voiceTypes.count else { return }
        SpeechService.shared.setVoiceType(voiceTypes[sender.indexOfSelectedItem])
    }

    @objc private func testSpeech() {
        SpeechService.shared.speak("Hello, welcome to PolySaver!")
    }

    private func loadData() {
        vocabularySources = vocabularyManager.getAvailableSources()
        tableView.reloadData()
        updateSourceLabel()
    }

    private func updateSourceLabel() {
        let (source, wordCount) = vocabularyManager.getCurrentSourceInfo()
        if let source = source {
            sourceLabel.stringValue = "当前词汇源: \(source.name) (\(wordCount) 个单词)"
        } else {
            sourceLabel.stringValue = "当前词汇源: 未设置"
        }
    }

    // MARK: - Actions

    @objc private func durationChanged(_ sender: NSPopUpButton) {
        let durations: [TimeInterval] = [2, 3, 5, 10, 15, 30]
        let selectedDuration = durations[sender.indexOfSelectedItem]
        UserDefaults.standard.displayDuration = selectedDuration
    }

    @objc private func apiProviderChanged(_ sender: NSPopUpButton) {
        let providers = APIProvider.allCases
        guard sender.indexOfSelectedItem < providers.count else { return }
        let selectedProvider = providers[sender.indexOfSelectedItem]
        TranslationServiceFactory.shared.setPreferredProvider(selectedProvider)
    }

    @objc private func saveAPISettings() {
        // 保存有道设置
        let youdaoKey = youdaoAppKeyField.stringValue.trimmingCharacters(in: .whitespaces)
        let youdaoSecret = youdaoAppSecretField.stringValue.trimmingCharacters(in: .whitespaces)
        if !youdaoKey.isEmpty {
            UserDefaults.standard.set(youdaoKey, forKey: UserDefaultsKeys.youdaoAppKey)
        }
        if !youdaoSecret.isEmpty {
            UserDefaults.standard.set(youdaoSecret, forKey: UserDefaultsKeys.youdaoAppSecret)
        }

        // 保存 Google 设置
        let googleKey = googleApiKeyField.stringValue.trimmingCharacters(in: .whitespaces)
        if !googleKey.isEmpty {
            UserDefaults.standard.set(googleKey, forKey: UserDefaultsKeys.googleAPIKey)
        }

        // 保存必应设置
        let bingKey = bingApiKeyField.stringValue.trimmingCharacters(in: .whitespaces)
        if !bingKey.isEmpty {
            UserDefaults.standard.set(bingKey, forKey: UserDefaultsKeys.bingAPIKey)
        }

        showAlert(title: "保存成功", message: "API 设置已保存", style: .informational)
    }

    @objc private func testAPIConnection() {
        Task {
            do {
                let testWord = "hello"
                let result = try await TranslationServiceFactory.shared.translate(word: testWord)

                DispatchQueue.main.async {
                    self.showAlert(
                        title: "连接成功 ✅",
                        message: "测试单词: \(testWord)\n翻译结果: \(result.primaryTranslation)",
                        style: .informational
                    )
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(
                        title: "连接失败 ❌",
                        message: error.localizedDescription,
                        style: .warning
                    )
                }
            }
        }
    }

    @objc private func openYoudaoHelp() {
        NSWorkspace.shared.open(URL(string: "https://ai.youdao.com/")!)
    }

    @objc private func openGoogleHelp() {
        NSWorkspace.shared.open(
            URL(string: "https://console.cloud.google.com/apis/library/translate.googleapis.com")!)
    }

    @objc private func openBingHelp() {
        NSWorkspace.shared.open(
            URL(
                string:
                    "https://portal.azure.com/#create/Microsoft.CognitiveServicesTextTranslation")!)
    }

    @objc private func clearCache() {
        let alert = NSAlert()
        alert.messageText = "确认清除缓存？"
        alert.informativeText = "这将删除所有已缓存的翻译结果，下次使用时需要重新请求 API。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "清除")
        alert.addButton(withTitle: "取消")

        if alert.runModal() == .alertFirstButtonReturn {
            CacheManager.shared.clearCache()
            showAlert(title: "清除成功", message: "缓存已清空", style: .informational)
        }
    }

    @objc private func resetLearningProgress() {
        let alert = NSAlert()
        alert.messageText = "确认重置学习进度？"
        alert.informativeText = "这将清除所有学习记录和收藏的单词。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "重置")
        alert.addButton(withTitle: "取消")

        if alert.runModal() == .alertFirstButtonReturn {
            WordLearningTracker.shared.clearAll()
            vocabularyManager.resetProgress()
            showAlert(title: "重置成功", message: "学习进度已重置", style: .informational)
        }
    }

    @objc private func resetAllSettings() {
        let alert = NSAlert()
        alert.messageText = "确认恢复默认设置？"
        alert.informativeText = "这将清除所有设置、API 密钥、学习进度和缓存。"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "恢复默认")
        alert.addButton(withTitle: "取消")

        if alert.runModal() == .alertFirstButtonReturn {
            // 清除所有 UserDefaults
            let domain = Bundle.main.bundleIdentifier ?? "com.polysaver"
            UserDefaults.standard.removePersistentDomain(forName: domain)

            // 清除缓存和学习记录
            CacheManager.shared.clearCache()
            WordLearningTracker.shared.clearAll()

            // 重新加载数据
            loadData()
            loadAPISettings()

            showAlert(title: "重置成功", message: "所有设置已恢复默认", style: .informational)
        }
    }

    private func loadAPISettings() {
        // 加载有道设置
        if let youdaoKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.youdaoAppKey) {
            youdaoAppKeyField.stringValue = youdaoKey
        }
        if let youdaoSecret = UserDefaults.standard.string(forKey: UserDefaultsKeys.youdaoAppSecret)
        {
            youdaoAppSecretField.stringValue = youdaoSecret
        }

        // 加载 Google 设置
        if let googleKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.googleAPIKey) {
            googleApiKeyField.stringValue = googleKey
        }

        // 加载必应设置
        if let bingKey = UserDefaults.standard.string(forKey: UserDefaultsKeys.bingAPIKey) {
            bingApiKeyField.stringValue = bingKey
        }

        // 设置首选提供商
        let currentProvider = UserDefaults.standard.preferredAPIProvider
        if let index = APIProvider.allCases.firstIndex(of: currentProvider) {
            apiProviderPopup.selectItem(at: index)
        }
    }

    private func showAlert(title: String, message: String, style: NSAlert.Style) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = style
        alert.addButton(withTitle: "确定")
        alert.runModal()
    }

    @objc private func downloadSource(_ sender: NSButton) {
        let row = tableView.row(for: sender)
        guard row >= 0, row < vocabularySources.count else { return }

        let source = vocabularySources[row]

        sender.isEnabled = false
        progressIndicator.isHidden = false
        progressIndicator.doubleValue = 0

        Task {
            do {
                try await downloadManager.downloadVocabularySource(source) { progress in
                    DispatchQueue.main.async {
                        self.progressIndicator.doubleValue = Double(progress.percentage)
                    }
                }

                DispatchQueue.main.async {
                    sender.isEnabled = true
                    self.progressIndicator.isHidden = true
                    self.loadData()
                    self.showAlert(
                        title: "下载完成", message: "\(source.name) 下载成功！", style: .informational)
                }
            } catch {
                DispatchQueue.main.async {
                    sender.isEnabled = true
                    self.progressIndicator.isHidden = true
                    self.showAlert(
                        title: "下载失败", message: error.localizedDescription, style: .warning)
                }
            }
        }
    }

    @objc private func selectSource(_ sender: NSButton) {
        let row = tableView.row(for: sender)
        guard row >= 0, row < vocabularySources.count else { return }

        let source = vocabularySources[row]

        Task {
            do {
                try await vocabularyManager.setCurrentSource(source)

                DispatchQueue.main.async {
                    self.updateSourceLabel()
                    self.showAlert(
                        title: "设置成功", message: "已切换到 \(source.name)", style: .informational)
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(
                        title: "设置失败", message: error.localizedDescription, style: .warning)
                }
            }
        }
    }

    @objc private func deleteSource(_ sender: NSButton) {
        let row = tableView.row(for: sender)
        guard row >= 0, row < vocabularySources.count else { return }

        let source = vocabularySources[row]

        let alert = NSAlert()
        alert.messageText = "确认删除？"
        alert.informativeText = "确定要删除词汇源「\(source.name)」吗？删除后需要重新下载。"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "删除")
        alert.addButton(withTitle: "取消")

        if alert.runModal() == .alertFirstButtonReturn {
            do {
                try downloadManager.deleteVocabularySource(source)
                loadData()
                showAlert(title: "删除成功", message: "词汇源「\(source.name)」已删除", style: .informational)
            } catch {
                showAlert(title: "删除失败", message: error.localizedDescription, style: .warning)
            }
        }
    }

    @objc private func importCustomVocabulary() {
        let panel = NSOpenPanel()
        panel.prompt = "导入"
        panel.message = "选择包含英文单词的文本文件 (每行一个单词)"
        panel.allowedContentTypes = [.text, .plainText]
        panel.allowsMultipleSelection = false

        panel.beginSheetModal(for: self.window!) { response in
            guard response == .OK, let url = panel.url else { return }

            Task {
                do {
                    let content = try String(contentsOf: url, encoding: .utf8)
                    let words = content.components(separatedBy: .newlines)
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }

                    guard !words.isEmpty else {
                        DispatchQueue.main.async {
                            self.showAlert(title: "导入失败", message: "文件内容为空", style: .warning)
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        self.progressIndicator.isHidden = false
                        self.progressIndicator.isIndeterminate = true
                        self.progressIndicator.startAnimation(nil)
                    }

                    let imported = try await self.vocabularyManager.importCustomWords(words)

                    DispatchQueue.main.async {
                        self.progressIndicator.stopAnimation(nil)
                        self.progressIndicator.isHidden = true
                        self.loadData()
                        self.showAlert(
                            title: "导入成功", message: "成功导入 \(imported.count) 个单词",
                            style: .informational)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.progressIndicator.stopAnimation(nil)
                        self.progressIndicator.isHidden = true
                        self.showAlert(
                            title: "导入失败", message: error.localizedDescription, style: .warning)
                    }
                }
            }
        }
    }
}

// MARK: - NSTableViewDataSource
extension ConfigWindowController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return vocabularySources.count
    }
}

// MARK: - NSTableViewDelegate
extension ConfigWindowController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int)
        -> NSView?
    {
        let source = vocabularySources[row]

        if tableColumn?.identifier.rawValue == "name" {
            let cellView = NSTableCellView()
            let textField = NSTextField(labelWithString: source.name)
            textField.frame = NSRect(x: 0, y: 0, width: 200, height: 20)
            cellView.addSubview(textField)
            return cellView
        } else if tableColumn?.identifier.rawValue == "status" {
            let cellView = NSTableCellView()
            let textField = NSTextField(labelWithString: source.isDownloaded ? "✅ 已下载" : "❌ 未下载")
            textField.frame = NSRect(x: 0, y: 0, width: 100, height: 20)
            cellView.addSubview(textField)
            return cellView
        } else if tableColumn?.identifier.rawValue == "action" {
            let cellView = NSView(frame: NSRect(x: 0, y: 0, width: 270, height: 30))

            if source.isDownloaded {
                let selectButton = NSButton(
                    title: "使用", target: self, action: #selector(selectSource(_:)))
                selectButton.frame = NSRect(x: 0, y: 2, width: 60, height: 24)
                selectButton.bezelStyle = .rounded
                cellView.addSubview(selectButton)

                let deleteButton = NSButton(
                    title: "删除", target: self, action: #selector(deleteSource(_:)))
                deleteButton.frame = NSRect(x: 70, y: 2, width: 60, height: 24)
                deleteButton.bezelStyle = .rounded
                deleteButton.contentTintColor = .systemRed
                cellView.addSubview(deleteButton)
            } else {
                let downloadButton = NSButton(
                    title: "下载", target: self, action: #selector(downloadSource(_:)))
                downloadButton.frame = NSRect(x: 0, y: 2, width: 60, height: 24)
                downloadButton.bezelStyle = .rounded
                cellView.addSubview(downloadButton)
            }

            return cellView
        }

        return nil
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 35
    }
}
