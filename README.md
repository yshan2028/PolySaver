# PolySaver

<div align="center">

![PolySaver Logo](docs/images/logo.png)

**A Beautiful macOS Screensaver for Language Learning**

Transform your idle screen time into a productive language learning experience with elegant word cards, multi-API translation support, and smart caching.

![macOS](https://img.shields.io/badge/macOS-12.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Build](https://img.shields.io/github/actions/workflow/status/yourname/PolySaver/build.yml)

[English](README.md) | [中文](README_zh.md)

![Screenshot](docs/images/screenshot.png)

</div>

## ✨ Features

- 🎨 **Beautiful UI** - Elegant word cards with gradient backgrounds and smooth animations
- 🌍 **Multi-Language Support** - English (10+ vocabulary sets), with plans for Chinese, Japanese, French, Korean
- 🔄 **Smart Translation** - Automatic fallback across Google, Youdao, and Bing Translate APIs
- 💾 **Intelligent Caching** - LRU cache with disk persistence to minimize API calls
- 📥 **Flexible Import** - Download curated vocabulary sets or import your own word lists
- 📊 **Learning Progress** - Track your study journey with built-in statistics
- 🎯 **No Repetition** - Smart algorithm ensures you see each word once before cycling

## 🚀 Quick Start

### Installation

1. Download the latest `.saver` file from [Releases](https://github.com/yourname/PolySaver/releases)
2. Double-click to install
3. Go to **System Preferences → Desktop & Screen Saver → Screen Saver**
4. Select **PolySaver** from the list

### First-Time Setup

1. Click **Screen Saver Options**
2. Select a vocabulary source (e.g., "CET-4" for English)
3. Click **Download** and wait for completion
4. Click **Use** to activate
5. Enjoy learning! 🎉

## 📦 Supported Vocabulary Sets

### English
- CET-4 / CET-6 (Chinese College English Test)
- TOEFL / IELTS / GRE / GMAT / SAT
- Specialized vocabularies (TEM-4, TEM-8)

### Coming Soon
- 🇨🇳 Chinese HSK (汉语水平考试)
- 🇯🇵 Japanese JLPT (日本語能力試験)
- 🇫🇷 French DELF/DALF
- 🇰🇷 Korean TOPIK (한국어능력시험)

## 🛠️ For Developers

### Requirements

- macOS 12.0+
- Xcode 14.0+
- Swift 5.9+

### Building from Source

```bash
git clone https://github.com/yourname/PolySaver.git
cd PolySaver
open PolySaver.xcodeproj
```

Press `⌘B` to build, then find the `.saver` file in DerivedData.

### Project Structure

```
PolySaver/
├── Sources/
│   ├── Models/              # Data models
│   ├── Services/            # Translation, Download, Cache
│   ├── Managers/            # Business logic
│   ├── Views/               # UI components
│   ├── Controllers/         # Window controllers
│   ├── Extensions/          # Swift extensions
│   └── Utilities/           # Helper classes
├── Resources/               # Assets and plists
├── Tests/                   # Unit tests
└── docs/                    # Documentation
```

See [ARCHITECTURE.md](docs/en/ARCHITECTURE.md) for detailed design.

### API Integration

PolySaver supports **3 translation providers** with automatic fallback:

| Provider | Free Quota | Features |
|----------|------------|----------|
| **Youdao** ✅ Recommended | 100/day | Phonetics, Examples |
| **Bing** | 2M chars/month | Good for batch translation |
| **Google** | Paid only | High quality |

To configure APIs:
1. Get your API keys ([guide](docs/en/API_INTEGRATION.md))
2. Open Screen Saver Options
3. Enter credentials in API Settings tab

## 🌟 Roadmap

- [x] Multi-API translation with smart fallback
- [x] LRU caching system
- [x] Beautiful gradient UI
- [ ] **v2.0**: Multi-language support (Chinese, Japanese, etc.)
- [ ] **v2.1**: Spaced Repetition Algorithm (SRS)
- [ ] **v2.2**: Text-to-Speech (TTS)
- [ ] **v3.0**: iCloud sync for learning progress
- [ ] **v3.1**: Dark mode detection

## 📖 Documentation

- [Architecture Design](docs/en/ARCHITECTURE.md)
- [API Integration Guide](docs/en/API_INTEGRATION.md)
- [Contributing Guidelines](CONTRIBUTING.md)
- [Development Setup](docs/en/DEVELOPMENT.md)
- [中文文档](docs/zh/)

## 🤝 Contributing

We love contributions! Please read our [Contributing Guide](CONTRIBUTING.md) before submitting PRs.

### Good First Issues

- 🌐 Add new language support
- 🎨 Design new themes
- 📝 Improve documentation
- 🐛 Fix bugs

See [open issues](https://github.com/yourname/PolySaver/issues) for current tasks.

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) for details.

## 🙏 Acknowledgments

- Vocabulary data from [kajweb/dict](https://github.com/kajweb/dict)
- Translation APIs: Google Cloud Translation, Youdao AI, Microsoft Azure Translator
- Inspired by macOS's built-in Word of the Day screensaver

## 👨‍💻 About the Author

**Kimi** (yshan2028@gmail.com)

I am a Test Development Engineer with 15 years of experience, currently based in Shanghai, China 🇨🇳. This is my first open-source Apple screensaver project. 

**If you find this project helpful, please give it a ⭐️ on GitHub!** Your support keeps me motivated to improve the project.

## 📬 Contact

- **Issues**: [GitHub Issues](https://github.com/yshan2028/PolySaver/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yshan2028/PolySaver/discussions)
- **Email**: yshan2028@gmail.com

## ⭐ Star History

[![Star History Chart](https://api.star-history.com/svg?repos=yourname/PolySaver&type=Date)](https://star-history.com/#yourname/PolySaver&Date)

---

<div align="center">
Made with ❤️ by the PolySaver Team
</div>
