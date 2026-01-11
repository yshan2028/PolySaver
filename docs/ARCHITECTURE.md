# Architecture Design

## Overview

PolyglotSaver follows a clean, protocol-oriented architecture inspired by MVVM and service-oriented design principles.

## Architecture Diagram

```mermaid
graph TB
    subgraph "Presentation Layer"
        A[LearnEnglishView]
        B[ConfigWindowController]
    end
    
    subgraph "Business Logic Layer"
        C[VocabularyManager]
        D[WordLearningTracker]
    end
    
    subgraph "Service Layer"
        E[TranslationServiceFactory]
        F[DownloadManager]
        G[CacheManager]
        
        subgraph "Translation Services"
            E1[GoogleTranslationService]
            E2[YoudaoTranslationService]
            E3[BingTranslationService]
        end
    end
    
    subgraph "Data Layer"
        H[(FileManager)]
        I[(UserDefaults)]
    end
    
    A --> C
    B --> C
    B --> F
    C --> E
    C --> G
    E --> E1
    E --> E2
    E --> E3
    E1 --> H
    E2 --> H
    E3 --> H
    G --> H
    F --> H
    C --> I
