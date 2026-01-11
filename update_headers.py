import os

files = [
    "Sources/Controllers/ConfigWindowController.swift",
    "Sources/Extensions/Constants.swift",
    "Sources/Extensions/Extensions.swift",
    "Sources/Managers/VocabularyManager.swift",
    "Sources/Managers/WordLearningTracker.swift",
    "Sources/Models/Models.swift",
    "Sources/Services/Cache/CacheManager.swift",
    "Sources/Services/Download/DownloadManager.swift",
    "Sources/Services/Speech/SpeechService.swift",
    "Sources/Services/Translation/BingTranslationService.swift",
    "Sources/Services/Translation/GoogleTranslationService.swift",
    "Sources/Services/Translation/TranslationService.swift",
    "Sources/Services/Translation/TranslationServiceFactory.swift",
    "Sources/Services/Translation/YoudaoTranslationService.swift",
    "Sources/Utilities/JSONParser.swift",
    "Sources/Views/LearnEnglishView.swift"
]

root_dir = "learn english"

for rel_path in files:
    path = os.path.join(root_dir, rel_path)
    if not os.path.exists(path):
        print(f"Skipping {path} (not found)")
        continue

    filename = os.path.basename(path)
    
    with open(path, 'r') as f:
        lines = f.readlines()
    
    # Construct new header
    new_header = [
        "//\n",
        f"//  {filename}\n",
        "//  PolySaver\n",
        "//\n",
        "//  Created by Kimi on 1/12/26.\n",
        "//  Copyright © 2026 Kimi (yshan2028@gmail.com). All rights reserved.\n",
        "//\n",
        "\n"
    ]
    
    # Detect end of existing header (first line that is not a comment or empty, usually 'import')
    content_start = 0
    for i, line in enumerate(lines):
        if line.strip().startswith("import"):
            content_start = i
            break
            
    # If no import found (unlikely), valid content start is complicated, but for these files imports are standard.
    # Fallback: if line 0 is //, scan until not //
    if content_start == 0:
         for i, line in enumerate(lines):
            if not line.strip().startswith("//") and line.strip() != "":
                content_start = i
                break
    
    # Write new content
    with open(path, 'w') as f:
        f.writelines(new_header + lines[content_start:])
    print(f"Updated {path}")
