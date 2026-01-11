# API Integration Guide

This guide helps you set up translation API keys for PolySaver.

## 🌐 Supported Translation APIs

PolySaver supports **3 translation providers** with automatic fallback:

| Provider | Free Quota | Best For | Difficulty |
|----------|------------|----------|------------|
| **Youdao** ✅ | 100/day | Phonetics & Examples | Easy |
| **Bing** | 2M chars/month | Batch Translation | Medium |
| **Google** | Paid only | High Quality | Hard |

## 📝 Youdao Translation (Recommended)

### Step 1: Create Account
1. Visit [Youdao AI Cloud](https://ai.youdao.com/)
2. Register for a free account
3. Complete email verification

### Step 2: Create Application
1. Go to **Console** → **My Applications**
2. Click **Create Application**
3. Fill in details:
   - **Application Name**: PolySaver
   - **Application Type**: Text Translation
   - **Platform**: macOS
4. Submit and wait for approval (usually instant)

### Step 3: Get Credentials
You'll receive:
- **App Key** (应用ID): e.g., `1a2b3c4d5e6f7g8h`
- **App Secret** (应用密钥): e.g., `9i0j1k2l3m4n5o6p`

### Step 4: Configure in PolySaver
1. Open **System Preferences** → **Desktop & Screen Saver**
2. Select **PolySaver** → **Screen Saver Options**
3. Go to **API Settings** tab
4. Select **Youdao** as preferred provider
5. Enter your **App Key** and **App Secret**
6. Click **Test Connection**
7. Save settings

### API Documentation
- [Official Docs](https://ai.youdao.com/docs/doc-trans-api.s#p01)
- Free tier: **100 requests/day**
- Response includes: translation, phonetics, examples

## 🌍 Bing Translator

### Step 1: Create Azure Account
1. Visit [Azure Portal](https://portal.azure.com/)
2. Sign up (requires credit card, $200 free credit for new users)

### Step 2: Create Translator Resource
1. Search for **Translator** in Azure Portal
2. Click **Create**
3. Configure:
   - **Subscription**: Your subscription
   - **Resource Group**: Create new or use existing
   - **Region**: Choose nearest region
   - **Name**: polysaver-translator
   - **Pricing Tier**: **F0 (Free)** - 2M chars/month
4. Review + Create

### Step 3: Get API Key
1. Go to your Translator resource
2. Navigate to **Keys and Endpoint**
3. Copy **KEY 1**

### Step 4: Configure in PolySaver
1. Open PolySaver settings
2. Select **Bing** as provider
3. Enter **API Key**
4. Test and save

### API Documentation
- [Official Docs](https://docs.microsoft.com/azure/cognitive-services/translator/)
- Free tier: **2M characters/month**
- No phonetics provided

## 🔍 Google Translate

### Step 1: Create GCP Project
1. Visit [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project: **PolySaver**

### Step 2: Enable API
1. Go to **APIs & Services** → **Library**
2. Search for **Cloud Translation API**
3. Click **Enable**

### Step 3: Create Credentials
1. Go to **APIs & Services** → **Credentials**
2. Click **Create Credentials** → **API Key**
3. Copy the generated key
4. (Optional) Restrict key to Translation API only

### Step 4: Enable Billing
⚠️ **Required**: Google Translation API is **paid only**
1. Go to **Billing**
2. Link a billing account
3. Pricing: **$20 per 1M characters**

### Step 5: Configure in PolySaver
1. Open PolySaver settings
2. Select **Google** as provider
3. Enter **API Key**
4. Test and save

### API Documentation
- [Official Docs](https://cloud.google.com/translate/docs)
- **No free tier** (charges apply)
- Highest translation quality

## 🔄 Fallback Strategy

PolySaver automatically switches APIs when one fails:

```
1. Try Youdao (100/day quota)
   ↓ (quota exceeded or error)
2. Fallback to Bing (2M/month)
   ↓ (quota exceeded or error)
3. Fallback to Google (paid)
   ↓ (error)
4. Return error to user
```

## 🔒 Security Best Practices

### ⚠️ Current Implementation
API keys are stored in **UserDefaults** (unencrypted)

### ✅ Recommended for Production
Use **Keychain** for secure storage:

```swift
import Security

func saveToKeychain(account: String, password: String) {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecValueData as String: password.data(using: .utf8)!,
        kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]
    
    SecItemDelete(query as CFDictionary)  // Delete old
    SecItemAdd(query as CFDictionary, nil)  // Add new
}
```

## 📊 Cost Comparison

Assuming **1000 words/month** usage:

| Provider | Cost | Notes |
|----------|------|-------|
| Youdao | **$0** | Free (100/day limit) ✅ |
| Bing | **$0** | Free (2M chars) ✅ |
| Google | **~$5** | Paid ($20/1M chars) |

**Recommendation**: Use **Youdao** for daily learning, Bing as backup.

## ❓ Troubleshooting

### "API Key Missing" Error
- Check if you entered both App Key and App Secret (for Youdao)
- Verify there are no leading/trailing spaces

### "Quota Exceeded" Error
- Youdao: Wait until next day (resets at midnight UTC+8)
- Bing: Wait until next month
- Google: Check billing account

### "Invalid Response" Error
- Check internet connection
- Verify API endpoint hasn't changed
- Check API service status page

### "Rate Limit Exceeded" Error
- Youdao: Max 10 requests/second
- Wait a few seconds and retry

## 🧪 Testing API Connection

Use this test word to verify your setup:
```
Word: "serendipity"
Expected: 意外发现珍奇事物的本领；有意外发现珍宝的运气
```

If you get the correct translation, your API is configured! ✅

## 📞 Support

Having issues? Open an issue on GitHub:
https://github.com/yshan2028/PolySaver/issues
