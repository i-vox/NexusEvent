# Changelog

## 0.1.0

* **Initial release** 🎉
* Cross-platform event messaging SDK for Flutter
* Discord webhook integration support
* Robust error handling with retry mechanism
* Input validation and secure URL handling
* Broadcast messaging to multiple platforms
* Comprehensive test coverage
* Full documentation and examples

### Features
- 🚀 **Multi-platform support**: Discord, Slack, Telegram (Discord implemented)
- 🔒 **Security first**: Strict webhook URL validation and input sanitization
- 🔄 **Retry mechanism**: Exponential backoff for network failures
- 📊 **Broadcast results**: Detailed success/failure reporting
- 🧪 **Well tested**: 100% test coverage
- 📖 **Rich documentation**: Complete API documentation and usage examples

### API
- `NexusEvent.instance` - Singleton access
- `addSender()` - Add message senders
- `send()` - Send to specific sender
- `broadcast()` - Send to multiple senders
- `validateSender()` - Validate sender configuration

### Supported Platforms
- ✅ Discord (via webhooks)
- 🔄 Slack (coming soon)
- 🔄 Telegram (coming soon)