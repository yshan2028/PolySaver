# Development Guide

This guide helps contributors set up their development environment for PolySaver.

## 📋 Prerequisites

- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.9 or later
- Git 2.30 or later

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone git@github.com:yshan2028/PolySaver.git
cd PolySaver
```

### 2. Open in Xcode

```bash
open PolySaver.xcodeproj
```

### 3. Build the Project

Press `⌘B` or go to **Product → Build**

### 4. Run as Screensaver

Since screensavers can't be run directly from Xcode, you need to:

**Option A: Install and Test**
1. Build the project (`⌘B`)
2. Find `PolySaver.saver` in DerivedData:
   ```bash
   ~/Library/Developer/Xcode/DerivedData/PolySaver-*/Build/Products/Debug/PolySaver.saver
   ```
3. Double-click to install
4. Test via **System Preferences → Screen Saver**

**Option B: Use Preview Mode**
```bash
# Create a test harness application
# See Tests/PreviewApp/ for example
```

### 5. Enable Developer Mode

For faster iteration:
```bash
# Disable System Integrity Protection for /Library/Screen Savers
# (Not recommended for production)

# Or copy to user directory instead
cp -r build/PolySaver.saver ~/Library/Screen\ Savers/
```

## 📁 Project Structure

```
PolySaver/
├── Sources/
│   ├── Models/
│   │   └── Models.swift              # Data models (Word, Translation, etc.)
│   ├── Services/
│   │   ├── Translation/              # Translation API implementations
│   │   │   ├── TranslationService.swift
│   │   │   ├── GoogleTranslationService.swift
│   │   │   ├── YoudaoTranslationService.swift
│   │   │   ├── BingTranslationService.swift
│   │   │   └── TranslationServiceFactory.swift
│   │   ├── Download/
│   │   │   └── DownloadManager.swift  # ZIP download and extraction
│   │   └── Cache/
│   │       └── CacheManager.swift      # LRU caching system
│   ├── Managers/
│   │   ├── VocabularyManager.swift    # Core business logic
│   │   └── WordLearningTracker.swift  # Progress tracking
│   ├── Views/
│   │   └── LearnEnglishView.swift     # Main screensaver view
│   ├── Controllers/
│   │   └── ConfigWindowController.swift  # Configuration UI
│   ├── Extensions/
│   │   ├── Extensions.swift           # Swift extensions
│   │   └── Constants.swift            # Global constants
│   └── Utilities/
│       └── JSONParser.swift           # Vocabulary JSON parser
├── Resources/                    # Assets and Plist
│   └── Assets.xcassets               # Images and colors
├── Tests/
│   ├── learn english.saver/          # The built screensaver bundle
└── docs/                             # Documentation
```

## 🔧 Development Workflow

### Creating a New Feature

1. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Write code** following Swift style guide

3. **Add tests**
   ```bash
   # Run tests with ⌘U or:
   xcodebuild test -scheme PolySaver
   ```

4. **Update documentation**
   - Update relevant `.md` files
   - Add code comments
   - Update CHANGELOG.md

5. **Commit and push**
   ```bash
   git add .
   git commit -m "Add feature: your feature description"
   git push origin feature/your-feature-name
   ```

6. **Create Pull Request**
   - Go to GitHub
   - Create PR with detailed description
   - Request review

### Adding a New Translation API

1. **Create Service Class**
   ```swift
   // Sources/Services/Translation/NewAPIService.swift
   class NewAPIService: TranslationService {
       let provider: APIProvider = .newProvider
       var apiKey: String?
       
       func translate(word: String) async throws -> Word {
           // Implementation
       }
   }
   ```

2. **Update APIProvider Enum**
   ```swift
   // Sources/Models/Models.swift
   enum APIProvider: String, CaseIterable {
       case google = "Google Translate"
       case youdao = "有道翻译"
       case bing = "必应翻译"
       case newProvider = "New Provider"  // Add here
   }
   ```

3. **Register in Factory**
   ```swift
   // Sources/Services/Translation/TranslationServiceFactory.swift
   services[.newProvider] = NewAPIService()
   ```

4. **Add Tests**
   ```swift
   // Tests/PolySaverTests/NewAPIServiceTests.swift
   func testNewAPITranslation() async throws {
       let service = NewAPIService()
       service.apiKey = "test-key"
       let result = try await service.translate(word: "test")
       XCTAssertEqual(result.headWord, "test")
   }
   ```

### Adding a New Language

1. **Create Language-Specific Models**
   ```swift
   // Sources/Models/ChineseWord.swift
   struct ChineseWord: Codable {
       let simplified: String  // 简体
       let traditional: String? // 繁体
       let pinyin: String      // 拼音
       let meaning: String     // 意思
   }
   ```

2. **Implement Parser**
   ```swift
   // Sources/Utilities/ChineseParser.swift
   class ChineseParser {
       func parse(data: Data) -> [ChineseWord] {
           // Parse HSK vocabulary JSON
       }
   }
   ```

3. **Update VocabularyManager**
   ```swift
   // Add language detection and routing
   ```

4. **Update UI** if needed (font rendering, RTL support, etc.)

## 🧪 Testing

### Unit Tests

```bash
# Run all tests
xcodebuild test -scheme PolySaver

# Run specific test
xcodebuild test -scheme PolySaver -only-testing:PolySaverTests/VocabularyManagerTests
```

### Manual Testing Checklist

- [ ] Download vocabulary source
- [ ] Switch between sources
- [ ] Test API translation (with real keys)
- [ ] Test offline mode
- [ ] Test cache persistence
- [ ] Test screensaver animation
- [ ] Test configuration changes
- [ ] Test error handling (network off, invalid JSON, etc.)

## 🐛 Debugging

### Screensaver Debugging

Screensavers are tricky to debug. Here are some tips:

**Method 1: Logging**
```swift
// Use print() or OSLog
import os.log

let logger = Logger(subsystem: "com.yshan.PolySaver", category: "debug")
logger.info("Word loaded: \(word.headWord)")
```

Check logs:
```bash
log stream --predicate 'subsystem == "com.yshan.PolySaver"'
```

**Method 2: Create Test App**
```swift
// Create a standard macOS app that embeds the screensaver view
// This allows normal Xcode debugging
```

**Method 3: Attach Debugger**
```bash
# Find screensaver process
ps aux | grep PolySaver

# Attach in Xcode: Debug → Attach to Process
```

### Common Issues

**Issue**: Changes not reflected after rebuild
- **Solution**: Quit System Preferences and reopen

**Issue**: Screensaver crashes on launch
- **Solution**: Check Console.app for crash logs

**Issue**: Can't debug async code
- **Solution**: Use `print()` or write to file in `~/Library/Logs/`

## 📊 Performance Tips

### Profiling

1. Build for Profiling: **Product → Profile** (`⌘I`)
2. Choose **Time Profiler** or **Allocations**
3. Let screensaver run for a few minutes
4. Analyze hotspots

### Memory Management

```swift
// Use weak self in closures
Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
    self?.loadNextWord()
}

// Clean up in deinit
deinit {
    timer?.invalidate()
    timer = nil
}
```

### Performance Targets

- **CPU**: < 5% when idle
- **Memory**: < 50MB for basic usage
- **FPS**: 30fps for animations
- **API Response**: < 2s for word lookup

## 🔄 Code Style

Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

```swift
// ✅ Good
func translateWord(_ word: String) async throws -> Word

// ❌ Bad
func trans(w: String) -> Word?

// ✅ Good - Clear and descriptive
let vocabularyManager = VocabularyManager.shared

// ❌ Bad - Abbreviated
let vocabMgr = VocabMgr.shared
```

Use SwiftL int:
```bash
brew install swiftlint
swiftlint lint
```

## 📚 Useful Resources

- [ScreenSaver Framework Docs](https://developer.apple.com/documentation/screensaver)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Xcode Debugging Guide](https://developer.apple.com/documentation/xcode/debugging)

## 🤝 Getting Help

- **GitHub Discussions**: Ask questions, share ideas
- **Issues**: Report bugs or request features
- **Discord**: Join our community (coming soon)

---

Happy coding! 🚀
