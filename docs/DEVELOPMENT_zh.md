# 开发指南

本指南将帮助贡献者搭建 PolySaver 的开发环境。

## 📋先决条件

- macOS 12.0 或更高版本
- Xcode 14.0 或更高版本
- Swift 5.9 或更高版本
- Git 2.30 或更高版本

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone git@github.com:yshan2028/PolySaver.git
cd PolySaver
```

### 2. 在 Xcode 中打开

```bash
open PolySaver.xcodeproj
```

### 3. 构建项目

按下 `⌘B` 或点击菜单栏 **Product → Build**

### 4. 运行屏保

由于屏保无法直接从 Xcode 运行，你需要：

**方案 A：安装并测试**
1. 构建项目 (`⌘B`)
2. 在 DerivedData 中找到 `learn english.saver` (注意：实际文件名可能为 `learn english.saver`)：
   ```bash
   ~/Library/Developer/Xcode/DerivedData/learn_english-*/Build/Products/Debug/learn english.saver
   ```
3. 双击安装
4. 通过 **系统偏好设置 → 屏幕保护程序** 进行测试

**方案 B：使用 Preview 模式**
```bash
# 创建测试用的宿主应用
# 参见 Tests/PreviewApp/ 示例
```

### 5. 启用开发者模式

为了更快的迭代测试：
```bash
# 禁用 /Library/Screen Savers 的系统完整性保护 (SIP)
# (不建议在生产环境中使用)

# 或者复制到用户目录替代
cp -r "build/Debug/learn english.saver" ~/Library/Screen\ Savers/
```

## 📁 项目结构

```
PolySaver/
├── Sources/
│   ├── Models/
│   │   └── Models.swift              # 数据模型 (Word, Translation 等)
│   ├── Services/
│   │   ├── Translation/              # 翻译 API 实现
│   │   │   ├── TranslationService.swift
│   │   │   ├── GoogleTranslationService.swift
│   │   │   ├── YoudaoTranslationService.swift
│   │   │   ├── BingTranslationService.swift
│   │   │   └── TranslationServiceFactory.swift
│   │   ├── Download/
│   │   │   └── DownloadManager.swift  # ZIP 下载与解压
│   │   └── Cache/
│   │       └── CacheManager.swift     # LRU 缓存系统
│   ├── Managers/
│   │   ├── VocabularyManager.swift    # 核心业务逻辑
│   │   └── WordLearningTracker.swift  # 学习进度追踪
│   ├── Views/
│   │   └── LearnEnglishView.swift     # 屏保主视图
│   ├── Controllers/
│   │   └── ConfigWindowController.swift  # 配置界面
│   ├── Extensions/
│   │   ├── Extensions.swift           # Swift 扩展
│   │   └── Constants.swift            # 全局常量
│   └── Utilities/
│       └── JSONParser.swift           # 词汇 JSON 解析器
├── Resources/                    
│   └── Assets.xcassets               # 图片与颜色资源
├── Info.plist                        # Bundle 配置
├── Tests/
│   ├── learn english.saver/          # 构建出的屏保包
└── docs/                             # 文档
```

## 🔧 开发工作流

### 创建新功能

1. **创建分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **编写代码** 遵循 Swift 风格指南

3. **添加测试**
   ```bash
   # 使用 ⌘U 运行测试，或：
   xcodebuild test -scheme "learn english"
   ```

4. **更新文档**
   - 更新相关的 `.md` 文件
   - 添加代码注释
   - 更新 CHANGELOG.md

5. **提交并推送**
   ```bash
   git add .
   git commit -m "Add feature: 你的功能描述"
   git push origin feature/your-feature-name
   ```

6. **创建 Pull Request**
   - 前往 GitHub
   - 创建 PR 并填写详细描述
   - 请求代码审查

### 添加新的翻译 API

1. **创建服务类**
   ```swift
   // Sources/Services/Translation/NewAPIService.swift
   class NewAPIService: TranslationService {
       let provider: APIProvider = .newProvider
       var apiKey: String?
       
       func translate(word: String) async throws -> Word {
           // 实现逻辑
       }
   }
   ```

2. **更新 APIProvider 枚举**
   ```swift
   // Sources/Models/Models.swift
   enum APIProvider: String, CaseIterable {
       case google = "Google Translate"
       case youdao = "有道翻译"
       case bing = "必应翻译"
       case newProvider = "New Provider"  // 在此添加
   }
   ```

3. **在工厂中注册**
   ```swift
   // Sources/Services/Translation/TranslationServiceFactory.swift
   services[.newProvider] = NewAPIService()
   ```

4. **添加测试**
   ```swift
   // Tests/PolySaverTests/NewAPIServiceTests.swift
   func testNewAPITranslation() async throws {
       let service = NewAPIService()
       service.apiKey = "test-key"
       let result = try await service.translate(word: "test")
       XCTAssertEqual(result.headWord, "test")
   }
   ```

### 添加新语言

1. **创建特定语言模型**
   ```swift
   // Sources/Models/ChineseWord.swift
   struct ChineseWord: Codable {
       let simplified: String  // 简体
       let traditional: String? // 繁体
       let pinyin: String      // 拼音
       let meaning: String     // 意思
   }
   ```

2. **实现解析器**
   ```swift
   // Sources/Utilities/ChineseParser.swift
   class ChineseParser {
       func parse(data: Data) -> [ChineseWord] {
           // 解析 HSK 词汇 JSON
       }
   }
   ```

3. **更新 VocabularyManager**

4. **更新 UI** (如有需要，例如字体渲染、RTL 支持等)

## 🧪 测试

### 单元测试

```bash
# 运行所有测试
xcodebuild test -scheme "learn english"

# 运行特定测试
xcodebuild test -scheme "learn english" -only-testing:PolySaverTests/VocabularyManagerTests
```

### 手动测试清单

- [ ] 下载词汇源
- [ ] 切换词汇源
- [ ] 测试 API 翻译 (使用真实 Key)
- [ ] 测试离线模式
- [ ] 测试缓存持久化
- [ ] 测试屏保动画
- [ ] 测试配置更改
- [ ] 测试错误处理 (断网、无效 JSON 等)

## 🐛 调试

### 屏保调试

屏保调试比较棘手，以下是一些技巧：

**方法 1：日志记录**
```swift
// 使用 print() 或 OSLog
import os.log

let logger = Logger(subsystem: "com.yshan.PolySaver", category: "debug")
logger.info("Word loaded: \(word.headWord)")
```

检查日志：
```bash
log stream --predicate 'subsystem == "com.yshan.PolySaver"'
```

**方法 2：创建测试应用**
- 创建一个标准的 macOS 应用，嵌入屏保视图。
- 这样可以使用正常的 Xcode 调试功能。

**方法 3：附加调试器**
```bash
# 查找屏保进程
ps aux | grep "learn english"

# 在 Xcode 中附加: Debug → Attach to Process
```

### 常见问题

**问题**：重新构建后更改未生效
- **解决**：退出系统偏好设置并重新打开

**问题**：屏保启动时崩溃
- **解决**：检查控制台应用中的崩溃日志

**问题**：无法调试异步代码
- **解决**：使用 `print()` 或写入文件到 `~/Library/Logs/`

## 📊 性能提示

### 性能分析

1. 构建用于分析的版本：**Product → Profile** (`⌘I`)
2. 选择 **Time Profiler** 或 **Allocations**
3. 让屏保运行几分钟
4. 分析热点

### 内存管理

```swift
// 在闭包中使用 weak self
Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
    self?.loadNextWord()
}

// 在 deinit 中清理
deinit {
    timer?.invalidate()
    timer = nil
}
```

### 性能目标

- **CPU**: 空闲时 < 5%
- **内存**: 基础使用 < 50MB
- **FPS**: 动画保持 30fps
- **API 响应**: 单词查询 < 2s

## 🔄 代码风格

遵循 [Swift API 设计指南](https://swift.org/documentation/api-design-guidelines/)：

```swift
// ✅ 推荐
func translateWord(_ word: String) async throws -> Word

// ❌ 不推荐
func trans(w: String) -> Word?

// ✅ 推荐 - 清晰且描述性强
let vocabularyManager = VocabularyManager.shared

// ❌ 不推荐 - 缩写
let vocabMgr = VocabMgr.shared
```

使用 SwiftLint：
```bash
brew install swiftlint
swiftlint lint
```

## 📚 常用资源

- [ScreenSaver Framework 文档](https://developer.apple.com/documentation/screensaver)
- [Swift 并发编程](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Xcode 调试指南](https://developer.apple.com/documentation/xcode/debugging)

## 🤝 获取帮助

- **GitHub Discussions**: 提问或分享想法
- **Issues**: 报告 Bug 或请求功能
- **Discord**: 加入我们的社区 (即将推出)

---

编码愉快！ 🚀
