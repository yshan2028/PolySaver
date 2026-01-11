# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure with professional folder organization
- Multi-API translation support (Google, Youdao, Bing)
- Smart fallback mechanism for translation services
- LRU caching system with disk persistence
- Beautiful screensaver UI with gradient backgrounds
- Download manager for vocabulary sets
- Support for 10 English vocabulary sets (CET-4/6, TOEFL, IELTS, etc.)
- Configuration window with source selection and API settings
- Learning progress tracker
- Word favorites system

### Changed
- Migrated from Objective-C to Swift
- Updated Youdao API signature from MD5 to SHA256 (v3 spec)
- Reorganized project into Services/Models/Views architecture

### Fixed
- Youdao translation API signature algorithm (now uses SHA256)
- Memory leak in download progress handlers
- JSON parsing for large vocabulary files

## [1.0.0] - 2026-01-12

### Initial Release
- First public release of PolySaver
- Support for English vocabulary learning
- macOS 12.0+ compatibility
- MIT License

[Unreleased]: https://github.com/yourname/PolySaver/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourname/PolySaver/releases/tag/v1.0.0
