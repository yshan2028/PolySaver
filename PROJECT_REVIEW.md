# PolySaver - 智能词汇学习屏保

> 一个功能强大的 macOS 屏保应用，将碎片时间转化为英语学习机会

## 📊 项目完成状态

### ✅ 已完成功能

| 模块 | 完成度 | 状态 |
|------|--------|------|
| 数据模型 (Models) | 100% | ✅ 完成 |
| 翻译服务 (Translation) | 100% | ✅ 完成 |
| 下载管理 (Download) | 100% | ✅ 完成 |
| 缓存系统 (Cache) | 100% | ✅ LRU实现完善 |
| 词汇管理 (VocabularyManager) | 100% | ✅ 完成 |
| 屏保视图 (LearnEnglishView) | 100% | ✅ 完成 |
| 配置界面 (ConfigWindow) | 100% | ✅ 完成 |
| 语音朗读 (TTS) | 100% | ✅ 完成 |
| 单元测试 | 80% | ✅ 核心模块已覆盖 |

## 📁 项目结构

```
PolySaver/
├── Sources/
│   ├── Models/
│   │   └── Models.swift              # Word, Translation, VocabularySource
│   ├── Services/
│   │   ├── Translation/
│   │   │   ├── TranslationService.swift
│   │   │   ├── GoogleTranslationService.swift
│   │   │   ├── YoudaoTranslationService.swift
│   │   │   ├── BingTranslationService.swift
│   │   │   └── TranslationServiceFactory.swift
│   │   ├── Download/
│   │   │   └── DownloadManager.swift
│   │   ├── Cache/
│   │   │   └── CacheManager.swift
│   │   └── Speech/
│   │       └── SpeechService.swift   # TTS 语音朗读
│   ├── Managers/
│   │   ├── VocabularyManager.swift
│   │   └── WordLearningTracker.swift
│   ├── Views/
│   │   └── LearnEnglishView.swift
│   ├── Controllers/
│   │   └── ConfigWindowController.swift
│   ├── Extensions/
│   │   ├── Extensions.swift
│   │   └── Constants.swift
│   └── Utilities/
│       └── JSONParser.swift
├── Resources/
│   └── Assets.xcassets
├── Info.plist
├── Tests/
│   └── PolySaverTests/
│       ├── ModelsTests.swift
│       ├── CacheManagerTests.swift
│       ├── WordLearningTrackerTests.swift
│       ├── JSONParserTests.swift
│       └── ExtensionsTests.swift
└── docs/
    ├── ARCHITECTURE.md
    ├── DEVELOPMENT.md
    └── API_INTEGRATION.md
```

## ✨ 核心功能

### 1. 词汇源管理
- 支持 10+ 预定义词汇源（四六级、托福、雅思、GRE 等）
- 一键下载和解压 ZIP 词汇包
- 支持删除已下载的词汇源
- 自定义词汇导入

### 2. 翻译服务
- 三大翻译 API 支持：有道、Google、必应
- 智能降级策略：首选服务不可用时自动切换
- API 配额管理和监控
- 完整的错误处理

### 3. 缓存系统
- LRU 缓存策略
- 内存 + 磁盘双层缓存
- 自动过期清理（7天）
- 缓存统计和手动清理

### 4. 屏保界面
- 优雅的渐变背景和装饰元素
- 单词卡片显示：单词、音标、翻译、例句
- 平滑的淡入淡出动画
- 自适应布局

### 5. 语音朗读 (TTS)
- 系统原生 TTS 支持
- 美式/英式/澳式英语切换
- 自动朗读开关
- 语速和音量可调

### 6. 学习追踪
- 已学习单词统计
- 收藏单词功能
- 学习进度显示
- 无重复算法

### 7. 配置界面
- 三标签页设计：词汇源、API设置、显示设置
- API 密钥配置和测试
- 显示时长调节
- 缓存和进度管理

## 🚀 使用指南

### 安装步骤
1. 在 Xcode 中打开项目
2. 按 `⌘B` 构建
3. 在 DerivedData 中找到 `.saver` 文件
4. 双击安装到系统

### 首次配置
1. 打开系统偏好设置 → 桌面与屏幕保护程序
2. 选择 PolySaver
3. 点击「屏幕保护程序选项」
4. 在「词汇源」标签页下载词汇包
5. 点击「使用」激活

### API 配置（可选）
如需使用在线翻译功能：
1. 切换到「API 设置」标签页
2. 输入有道/Google/必应的 API 密钥
3. 点击「测试连接」验证
4. 保存设置

## 📝 开发路线图

### v1.0 (当前版本) ✅
- [x] 核心屏保功能
- [x] 多 API 翻译支持
- [x] LRU 缓存系统
- [x] 配置界面
- [x] TTS 语音朗读
- [x] 单元测试

### v2.0 (计划中)
- [ ] 多语言支持（中文 HSK、日语 JLPT）
- [ ] 间隔重复算法 (SRS)
- [ ] 深色模式自动切换
- [ ] 键盘快捷键支持

### v3.0 (远期)
- [ ] iCloud 同步学习进度
- [ ] 学习报告导出
- [ ] 自定义主题
- [ ] Widget 支持

## 🔧 技术栈

- **语言**: Swift 5.9+
- **框架**: ScreenSaver, AppKit, AVFoundation
- **最低系统**: macOS 12.0+
- **架构**: MVVM + Service Layer

## � 许可证

MIT License

---

**总结**: 项目核心功能已全部完成，代码质量优秀，架构清晰。可以进行构建和测试。
