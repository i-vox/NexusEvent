# 贡献指南

感谢你对 NexusEvent 项目的兴趣！我们欢迎各种形式的贡献，包括但不限于：

- 🐛 报告bug
- 💡 提出新功能建议  
- 📝 改进文档
- 🔧 提交代码修复
- ✨ 添加新功能
- 🧪 添加测试用例

## 开发环境设置

### 前置要求

- **Flutter**: >= 3.19.0
- **Node.js**: >= 18.0.0
- **Git**: 最新版本

### 克隆仓库

```bash
git clone https://github.com/your-org/NexusEvent.git
cd NexusEvent
```

### Flutter SDK 开发

```bash
cd packages/nexusevent_flutter
flutter pub get
flutter analyze
flutter test
```

### JavaScript SDK 开发

```bash
cd packages/nexusevent-js
npm install
npm run build
npm test
npm run lint
```

## 项目结构

```
NexusEvent/
├── packages/                    # SDK包
│   ├── nexusevent-core/         # 核心类型定义
│   ├── nexusevent_flutter/      # Flutter SDK
│   └── nexusevent-js/           # JavaScript SDK
├── examples/                    # 示例应用
│   ├── flutter_demo/
│   └── js-demo/
├── docs/                        # 文档
├── scripts/                     # 构建和发布脚本
└── .github/workflows/           # CI/CD配置
```

## 开发流程

### 1. 创建Issue

在开始开发前，请先创建或查看相关的Issue：

- 🐛 **Bug报告**: 使用Bug模板，包含复现步骤和环境信息
- 💡 **功能请求**: 描述需求场景和期望行为
- 📝 **文档改进**: 指出需要改进的文档部分

### 2. Fork和分支

```bash
# Fork仓库到你的账号
# 克隆你的Fork
git clone https://github.com/YOUR_USERNAME/NexusEvent.git
cd NexusEvent

# 创建特性分支
git checkout -b feature/your-feature-name
# 或者
git checkout -b bugfix/issue-number
```

### 3. 开发规范

#### 代码风格

**Flutter/Dart:**
- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 规范
- 使用 `flutter analyze` 检查代码
- 所有公共API需要文档注释

**JavaScript/TypeScript:**
- 使用 ESLint 配置的代码风格
- 优先使用 TypeScript
- 所有公共API需要JSDoc注释

#### 提交信息规范

使用 [Conventional Commits](https://conventionalcommits.org/) 格式：

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**类型说明:**
- `feat`: 新功能
- `fix`: Bug修复  
- `docs`: 文档更改
- `style`: 代码格式化（不影响功能）
- `refactor`: 重构（既不修复bug也不添加功能）
- `test`: 添加或修改测试
- `chore`: 构建过程或辅助工具的变动

**示例:**
```
feat(flutter): add Slack sender support

Add SlackSender class with webhook integration
- Support rich message formatting
- Include configuration validation
- Add comprehensive tests

Closes #123
```

### 4. 测试要求

#### 必须测试
- 所有新功能必须包含单元测试
- Bug修复必须包含回归测试
- 测试覆盖率应保持在80%以上

#### Flutter测试

```bash
cd packages/nexusevent_flutter
flutter test
# 生成覆盖率报告
flutter test --coverage
```

#### JavaScript测试

```bash
cd packages/nexusevent-js
npm test
# 查看覆盖率
npm test -- --coverage
```

### 5. 提交Pull Request

#### PR检查清单

- [ ] 代码遵循项目风格指南
- [ ] 添加了必要的测试用例
- [ ] 所有测试通过
- [ ] 更新了相关文档
- [ ] PR描述清晰说明了变更内容
- [ ] 如果是破坏性变更，在PR中明确标注

#### PR模板

```markdown
## 变更类型
- [ ] Bug修复
- [ ] 新功能
- [ ] 破坏性变更
- [ ] 文档更新

## 描述
简短描述这个PR的目的和变更内容。

## 相关Issue
Closes #(issue number)

## 测试
描述你是如何测试这些变更的：
- [ ] 单元测试
- [ ] 集成测试
- [ ] 手动测试

## 截图（如适用）
添加截图来说明变更效果。

## 检查清单
- [ ] 我的代码遵循项目的代码风格
- [ ] 我已进行了自我代码审查
- [ ] 我已添加了必要的注释
- [ ] 我已添加或更新了相关测试
- [ ] 新增和现有测试都通过
- [ ] 我已更新了相关文档
```

## 添加新平台支持

### Flutter SDK

1. 在 `lib/src/senders/` 创建新的发送器类：

```dart
// lib/src/senders/slack_sender.dart
class SlackSender implements EventSender {
  @override
  Platform get platform => Platform.slack;
  
  @override
  Future<void> send(EventMessage message) async {
    // 实现Slack发送逻辑
  }
  
  @override
  Future<bool> validateConfig() async {
    // 实现配置验证
  }
}
```

2. 在 `types.dart` 中添加配置类：

```dart
class SlackConfig extends SenderConfig {
  SlackConfig({required String webhookUrl})
      : super(platform: Platform.slack, config: {'webhookUrl': webhookUrl});
}
```

3. 添加便捷方法到 `NexusEvent` 类：

```dart
void addSlackSender(String name, String webhookUrl) {
  final config = SlackConfig(webhookUrl: webhookUrl);
  final sender = SlackSender(config);
  addSender(name, sender);
}
```

### JavaScript SDK

类似的步骤，在 `src/senders/` 目录下创建对应的实现。

## 文档贡献

### 文档类型
- **API文档**: 直接在代码中使用注释
- **使用指南**: 在各包的 README.md 中
- **开发文档**: 在 `docs/` 目录中

### 文档更新
- 新功能需要更新相关的README和示例
- API变更需要更新文档注释
- 重要变更需要更新CHANGELOG.md

## 发布流程

### 版本号规范
使用 [Semantic Versioning](https://semver.org/)：
- **MAJOR**: 破坏性API变更
- **MINOR**: 向后兼容的新功能
- **PATCH**: 向后兼容的bug修复

### 发布步骤
1. 更新 CHANGELOG.md
2. 运行发布脚本: `./scripts/publish.sh <version>`
3. 创建GitHub Release
4. 发布到包管理器

## 社区行为准则

### 我们的承诺
为了营造一个开放友好的环境，我们承诺让参与我们项目和社区的每个人都享有无骚扰的体验。

### 行为标准
**正面行为:**
- 使用友好和包容的语言
- 尊重不同的观点和经验  
- 优雅地接受建设性批评
- 关注对社区最有利的事情
- 对其他社区成员表示同理心

**不当行为:**
- 使用性别化的语言或图像，以及不当的性关注或性暗示
- 恶意评论、人身攻击或政治攻击
- 公开或私下的骚扰
- 未经明确许可发布他人的私人信息
- 其他在专业环境中被认为不当的行为

## 获得帮助

### 联系方式
- **GitHub Issues**: 报告bug或提出功能请求
- **GitHub Discussions**: 一般性讨论和问答
- **Email**: 发送邮件到 [your-email@example.com]

### 响应时间
- Issue响应: 通常在2-3个工作日内
- PR审查: 通常在1周内完成初次审查
- 安全问题: 24小时内响应

## 许可证

通过贡献代码，你同意你的贡献将在与项目相同的 [Apache License 2.0](../LICENSE) 下授权。
