# NexusEvent Flutter SDK

A powerful Flutter SDK for cross-platform message sending, supporting Discord, Slack, Telegram and more platforms.

## Features

- 🚀 Multi-platform support (Discord, Slack, Telegram, etc.)
- 📱 Cross-platform Flutter support (iOS, Android, Web, Desktop)
- 🔄 Asynchronous API with comprehensive error handling
- 🎨 Rich message formatting and embed support
- 🛡️ Built-in security and rate limiting
- 📝 TypeScript-like strong typing

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  nexusevent_flutter: ^0.1.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:nexusevent_flutter/nexusevent_flutter.dart';

void main() async {
  // Initialize the client
  final client = NexusEventClient();
  
  // Discord webhook example
  final discordConfig = DiscordWebhookConfig(
    webhookUrl: 'your-discord-webhook-url',
  );
  
  try {
    final result = await client.sendDiscordMessage(
      config: discordConfig,
      content: 'Hello from NexusEvent Flutter SDK!',
    );
    print('Message sent successfully: ${result.success}');
  } catch (e) {
    print('Error sending message: $e');
  }
}
```

## Supported Platforms

- **Discord**: Webhook messages with rich embeds
- **Slack**: Webhook and Bot API support
- **Telegram**: Bot API integration
- And more coming soon...

## Documentation

For detailed documentation and examples, visit:
- [Main Documentation](https://github.com/i-vox/NexusEvent)
- [Flutter Demo](https://github.com/i-vox/NexusEvent/tree/main/examples/flutter_demo)

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.

## Support

- [GitHub Issues](https://github.com/i-vox/NexusEvent/issues)
- [Security Policy](https://github.com/i-vox/NexusEvent/blob/main/.github/SECURITY.md)