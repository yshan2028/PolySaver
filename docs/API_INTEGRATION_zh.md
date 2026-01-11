# API 集成指南

本指南将帮助你为 PolySaver 设置翻译 API 密钥。

## 🌐 支持的翻译 API

PolySaver 支持 **3 大翻译提供商** 并具备自动降级功能：

| 提供商 | 免费额度 | 适用场景 | 难度 |
|--------|----------|----------|------|
| **有道翻译 (Youdao)** ✅ | 100次/天 | 音标 & 例句 | 简单 |
| **必应翻译 (Bing)** | 200万字符/月 | 批量翻译 | 中等 |
| **Google 翻译** | 仅付费 | 高质量翻译 | 困难 |

## 📝 有道翻译 (推荐)

### 第 1 步：注册账号
1. 访问 [有道智云](https://ai.youdao.com/)
2. 注册一个免费账号
3. 完成邮箱验证

### 第 2 步：创建应用
1.进入 **控制台** → **我的应用**
2. 点击 **创建应用**
3. 填写详情：
   - **应用名称**: PolySaver
   - **应用类型**: 文本翻译
   - **平台**: macOS
4. 提交并等待审批（通常是即时的）

### 第 3 步：获取凭证
你将获得：
- **应用 ID (App Key)**: 例如 `1a2b3c4d5e6f7g8h`
- **应用密钥 (App Secret)**: 例如 `9i0j1k2l3m4n5o6p`

### 第 4 步：在 PolySaver 中配置
1. 打开 **系统偏好设置** → **桌面与屏幕保护程序**
2. 选择 **PolySaver** → **屏幕保护程序选项**
3. 切换到 **API 设置** 标签页
4. 选择 **有道翻译** 作为首选提供商
5. 输入你的 **应用 ID** 和 **应用密钥**
6. 点击 **测试连接**
7. 保存设置

### API 文档
- [官方文档](https://ai.youdao.com/docs/doc-trans-api.s#p01)
- 免费版限制：**100 次请求/天**
- 响应包含：翻译、音标、例句

## 🌍 必应翻译 (Bing)

### 第 1 步：创建 Azure 账号
1. 访问 [Azure 门户](https://portal.azure.com/)
2. 注册（需要信用卡，新用户有 $200 免费额度）

### 第 2 步：创建 Translator 资源
1. 在 Azure 门户搜索 **Translator**
2. 点击 **创建**
3. 配置：
   - **订阅**: 你的订阅
   - **资源组**: 新建或使用现有的
   - **区域**: 选择最近的区域
   - **名称**: polysaver-translator
   - **定价层**: **F0 (免费)** - 200万字符/月
4. 审阅 + 创建

### 第 3 步：获取 API Key
1. 进入你的 Translator 资源
2. 导航到 **Keys and Endpoint** (密钥和终结点)
3. 复制 **KEY 1**

### 第 4 步：在 PolySaver 中配置
1. 打开 PolySaver 设置
2. 选择 **必应翻译**
3. 输入 **API Key**
4. 测试并保存

### API 文档
- [官方文档](https://docs.microsoft.com/azure/cognitive-services/translator/)
- 免费额度：**200 万字符/月**
- 不提供音标

## 🔍 Google 翻译

### 第 1 步：创建 GCP 项目 API
1. 访问 [Google Cloud Console](https://console.cloud.google.com/)
2. 创建新项目：**PolySaver**

### 第 2 步：启用 API
1. 进入 **APIs & Services** → **Library**
2. 搜索 **Cloud Translation API**
3. 点击 **Enable (启用)**

### 第 3 步：创建凭证
1. 进入 **APIs & Services** → **Credentials**
2. 点击 **Create Credentials** → **API Key**
3. 复制生成的密钥
4. (可选) 限制密钥仅用于 Translation API

### 第 4 步：启用计费
⚠️ **注意**: Google Translation API **仅限付费**
1. 进入 **Billing (计费)**
2. 关联计费账户
3. 价格：**$20 / 100万字符**

### 第 5 步：在 PolySaver 中配置
1. 打开 PolySaver 设置
2. 选择 **Google 翻译**
3. 输入 **API Key**
4. 测试并保存

### API 文档
- [官方文档](https://cloud.google.com/translate/docs)
- **无免费额度** (需付费)
- 翻译质量最高

## 🔄 自动降级策略

当某个 API 失败时，PolySaver 会自动切换：

```
1. 尝试有道 (100次/天)
   ↓ (额度超限或报错)
2. 降级到必应 (200万字符/月)
   ↓ (额度超限或报错)
3. 降级到 Google (付费)
   ↓ (报错)
4. 返回错误信息
```

## 🔒 安全最佳实践

### ⚠️ 当前实现
API 密钥存储在 **UserDefaults** (未加密)

### ✅ 生产环境建议
使用 **Keychain** 进行安全存储：

```swift
import Security

func saveToKeychain(account: String, password: String) {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: account,
        kSecValueData as String: password.data(using: .utf8)!,
        kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
    ]
    
    SecItemDelete(query as CFDictionary)  // 删除旧的
    SecItemAdd(query as CFDictionary, nil)  // 添加新的
}
```

## 📊 成本对比

假设 **每月 1000 个单词** 的使用量：

| 提供商 | 成本 | 备注 |
|--------|------|------|
| 有道 | **¥0** | 免费 (100次/天限制) ✅ |
| 必应 | **¥0** | 免费 (200万字符) ✅ |
| Google | **~$5** | 付费 ($20/100万字符) |

**推荐**：日常学习使用 **有道**，必应作为备用。

## ❓ 故障排除

### "API Key Missing" 错误
- 检查是否填写了 App Key 和 App Secret (有道)
- 确认没有多余的空格

### "Quota Exceeded" 错误 (额度超限)
- 有道：等待第二天 (北京时间凌晨重置)
- 必应：等待下个月
- Google：检查计费账户

### "Invalid Response" 错误
- 检查网络连接
- 验证 API 端点是否变更
- 检查 API 服务状态页

### "Rate Limit Exceeded" 错误 (频率受限)
- 有道：最大 10 次请求/秒
- 等待几秒后重试

## 🧪 测试 API 连接

使用以下测试词来验证你的设置：
```
单词: "serendipity"
预期结果: 意外发现珍奇事物的本领；有意外发现珍宝的运气
```

如果你获得了正确的翻译，说明 API 配置成功！ ✅

## 📞 支持

遇到问题？在 GitHub 上提交 Issue：
https://github.com/yshan2028/PolySaver/issues
