# Contributing to PolySaver

First off, thank you for considering contributing to PolySaver! It's people like you that make this project such a great learning tool for everyone.

## Code of Conduct

This project and everyone participating in it is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps to reproduce the problem**
* **Provide system information** (macOS version, PolySaver version)
* **Include screenshots** if applicable
* **Describe the behavior you observed and what you expected**

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Explain why this enhancement would be useful**
* **List any similar features in other screensavers**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. Ensure the test suite passes
4. Make sure your code follows the Swift style guide
5. Write a clear commit message

## Development Setup

### Prerequisites

- macOS 12.0+
- Xcode 14.0+
- Swift 5.9+

### Building

```bash
git clone https://github.com/yourname/PolySaver.git
cd PolySaver
open PolySaver.xcodeproj
```

### Running Tests

Press `⌘U` in Xcode or run:

```bash
xcodebuild test -scheme PolySaver
```

## Style Guide

### Swift Style

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

* Use `camelCase` for variables and functions
* Use `PascalCase` for types
* Prefer clarity over brevity
* Use Swift's built-in types and conventions

**Example:**

```swift
// Good
func translateWord(_ word: String) async throws -> Word

// Bad
func trans(w: String) -> Word?
```

### Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters
* Reference issues and pull requests after the first line

**Example:**

```
Add Japanese language support

- Implement JLPT vocabulary parser
- Add hiragana/katakana rendering
- Update UI for Japanese characters

Fixes #123
```

## Project Structure

```
Sources/
├── Models/              # Data models
├── Services/            # External services (Translation, Download, Cache)
├── Managers/            # Business logic
├── Views/               # UI components
├── Controllers/         # Window controllers
├── Extensions/          # Swift extensions
└── Utilities/           # Helper classes
```

## Adding a New Language

To add support for a new language (e.g., Japanese):

1. **Create Language Model**
   ```swift
   // Sources/Models/JapaneseWord.swift
   struct JapaneseWord: LanguageWord {
       let kanji: String
       let hiragana: String
       let meaning: String
   }
   ```

2. **Implement Parser**
   ```swift
   // Sources/Utilities/JapaneseParser.swift
   class JapaneseParser: VocabularyParser {
       func parse(data: Data) -> [JapaneseWord]
   }
   ```

3. **Update VocabularyManager**
   - Add language detection logic
   - Register new parser

4. **Add Tests**
   ```swift
   // Tests/JapaneseParserTests.swift
   func testParseJPLTVocabulary() { ... }
   ```

5. **Update Documentation**
   - Add to README.md
   - Create docs/languages/Japanese.md

## Translation API Integration

When adding a new translation API:

1. Implement `TranslationService` protocol
2. Add error handling for API-specific errors
3. Implement quota tracking if applicable
4. Add to `TranslationServiceFactory`
5. Update API documentation

**Example:**

```swift
class NewTranslationService: TranslationService {
    let provider: APIProvider = .newProvider
    var apiKey: String?
    
    func translate(word: String) async throws -> Word {
        // Implementation
    }
}
```

## Documentation

* Add XML documentation comments for public APIs
* Update relevant markdown files in `docs/`
* Include code examples where applicable
* Maintain both English and Chinese documentation

## Testing

* Write unit tests for new features
* Ensure translation API mocks are used in tests
* Test edge cases (network failures, invalid JSON, etc.)
* Maintain >80% code coverage

## Questions?

Feel free to ask questions in:
* [GitHub Discussions](https://github.com/yourname/PolySaver/discussions)
* [Issues](https://github.com/yourname/PolySaver/issues)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for making PolySaver better! 🎉
