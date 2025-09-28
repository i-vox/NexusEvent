# NexusEvent Core

NexusEvent 的核心抽象层，定义了统一的接口和数据结构，供各个语言的 SDK 实现使用。

## 核心概念

### EventMessage
表示要发送的事件消息，包含标题、内容、URL等信息。

### EventSender
事件发送器的抽象接口，不同平台（Discord、Slack、Telegram等）需要实现此接口。

### Platform
支持的目标平台枚举。

## 设计原则

1. **统一性**: 所有语言的SDK都应该实现相同的核心接口
2. **可扩展性**: 新增平台支持时，只需实现EventSender接口
3. **类型安全**: 提供清晰的数据结构定义
4. **简单性**: 保持API简洁易用