import 'package:flutter_test/flutter_test.dart';
import 'package:nexusevent_flutter/nexusevent.dart';

void main() {
  group('NexusEvent Core Tests', () {
    test('should create EventMessage with title', () {
      final message = EventMessage(title: 'Test Message');
      expect(message.title, equals('Test Message'));
      expect(message.content, isNull);
    });

    test('should handle Platform enum', () {
      expect(Platform.discord.value, equals('discord'));
      expect(Platform.slack.value, equals('slack'));
    });

    test('should create DiscordConfig', () {
      final config = DiscordConfig(webhookUrl: 'https://example.com/webhook');
      expect(config.platform, equals(Platform.discord));
      expect(config.webhookUrl, equals('https://example.com/webhook'));
    });

  });
}