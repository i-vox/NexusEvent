# API 兼容性与版本管理

## 版本策略

NexusEvent 遵循[语义化版本控制 2.0.0](https://semver.org/lang/zh-CN/)规范：

- **主版本号 (Major)**：不兼容的API修改时递增
- **次版本号 (Minor)**：向下兼容的功能性新增时递增
- **修订号 (Patch)**：向下兼容的问题修正时递增

## 当前版本：0.1.0

### API 稳定性保证

在 1.0.0 发布之前：
- ⚠️ API可能发生破坏性变更
- 🔄 我们会尽量保持向后兼容性
- 📢 任何破坏性变更都会在 CHANGELOG 中详细说明

在 1.0.0 发布之后：
- ✅ 保证向后兼容性
- 🚫 破坏性变更只会在主版本号更新时发生
- 📝 所有变更都会有详细的迁移指南

## 近期架构变更 (v0.1.0)

### EventMessage Platform 字段移除

**影响版本**: v0.1.0+  
**变更类型**: 架构改进  
**兼容性**: 向后兼容（字段被忽略）

#### 变更内容

之前的 API：
```dart
// Flutter
final message = EventMessage(
  title: 'Test',
  platform: Platform.discord, // ❌ 不再需要
);

// JavaScript  
const message = {
  title: 'Test',
  platform: Platform.DISCORD, // ❌ 不再需要
};
```

现在的 API：
```dart
// Flutter
final message = EventMessage(
  title: 'Test', // ✅ 平台由 Sender 决定
);

// JavaScript
const message = {
  title: 'Test', // ✅ 平台由 Sender 决定  
};
```

#### 迁移指南

1. **Flutter SDK**: 移除 EventMessage 构造函数中的 `platform` 参数
2. **JavaScript SDK**: 移除消息对象中的 `platform` 属性
3. **理由**: 平台信息应该由发送器决定，而不是消息本身

#### 兼容性说明

- ✅ **向前兼容**: 新代码可以在旧环境中运行（如果旧环境支持）
- ✅ **向后兼容**: 包含 platform 字段的旧代码仍然可以运行（字段会被忽略）

## API 设计原则

### 1. 防御性编程
- 所有公共 API 都包含输入验证
- 提供有意义的错误消息
- 优雅地处理边界情况

### 2. 扩展性设计
- 使用接口和抽象类支持扩展
- 配置通过构造函数参数传递
- 支持依赖注入模式

### 3. 一致性保证
- 跨语言SDK的API保持一致
- 错误处理模式统一
- 命名规范保持一致

## 向后兼容性测试

### 测试策略
1. **单元测试**: 确保新版本通过所有现有测试
2. **集成测试**: 验证与旧版本消息格式的兼容性
3. **回归测试**: 针对每个版本变更进行专门测试

### 测试工具
- Flutter: `flutter test --coverage`
- JavaScript: `npm test -- --coverage`
- 兼容性测试: 专门的兼容性测试套件

## 弃用策略

### 标记弃用
```dart
// Flutter
@Deprecated('使用新的 EventMessage 构造函数，无需 platform 参数')
EventMessage.withPlatform({
  required String title,
  required Platform platform,
});
```

```typescript
// TypeScript
/**
 * @deprecated 使用新的消息格式，无需 platform 字段
 */
interface LegacyEventMessage extends EventMessage {
  platform: Platform;
}
```

### 弃用周期
1. **标记弃用**: 在文档和代码中标记为弃用
2. **保持支持**: 至少2个次版本号内保持支持
3. **警告通知**: 在使用时输出警告信息
4. **完全移除**: 在下一个主版本号中移除

## 版本迁移指南

### 从 0.0.x 到 0.1.0

#### 主要变更
1. EventMessage 不再需要 platform 字段
2. 改进的错误处理和重试机制
3. 增强的输入验证

#### 迁移步骤
1. 更新依赖版本
2. 移除 EventMessage 中的 platform 字段
3. 更新错误处理代码（可选，向后兼容）
4. 运行测试确保功能正常

### 未来版本计划

#### v0.2.0 (计划中)
- Slack 发送器支持
- 批量消息发送
- 消息模板系统

#### v0.3.0 (计划中)  
- Telegram 发送器支持
- 消息队列和重试机制
- 性能监控和指标

#### v1.0.0 (目标)
- API 稳定化
- 完整的生产环境支持
- 全平台支持

## 错误处理变更

### v0.1.0 错误处理改进
- 更详细的错误消息
- 网络错误自动重试
- 配置验证错误的具体描述

### 向后兼容性
所有现有的异常类型和错误代码保持不变，新增的错误处理不会影响现有代码。

## 总结

NexusEvent 承诺在保持创新和改进的同时，尽最大努力维护API的稳定性和向后兼容性。我们会：

1. 📋 在 CHANGELOG 中详细记录所有变更
2. 📚 提供完整的迁移指南  
3. 🧪 通过全面的测试确保兼容性
4. 💬 通过GitHub Issues收集社区反馈
5. 📢 及时通知重要变更

如有任何兼容性问题或疑问，请在 [GitHub Issues](https://github.com/i-vox/NexusEvent/issues) 中反馈。
