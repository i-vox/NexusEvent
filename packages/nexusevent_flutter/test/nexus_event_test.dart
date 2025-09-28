import 'package:flutter_test/flutter_test.dart';
import 'package:nexusevent_flutter/nexusevent.dart';

void main() {
  group('NexusEvent', () {
    late NexusEvent nexusEvent;

    setUp(() {
      nexusEvent = NexusEvent.instance;
      nexusEvent.clear(); // 清空之前的配置
    });

    test('should be singleton', () {
      final instance1 = NexusEvent.instance;
      final instance2 = NexusEvent.instance;
      expect(instance1, same(instance2));
    });

    test('should add and remove senders', () {
      expect(nexusEvent.senderNames, isEmpty);

      nexusEvent.addDiscordSender('test_discord', 'https://discord.com/api/webhooks/123456789/abcdefghij');
      expect(nexusEvent.senderNames, contains('test_discord'));

      nexusEvent.removeSender('test_discord');
      expect(nexusEvent.senderNames, isEmpty);
    });

    test('should throw error for non-existent sender', () async {
      final message = EventMessage(
        title: 'Test Message',
      );

      expect(
        () async => await nexusEvent.send('non_existent', message),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should validate Discord sender configuration', () async {
      nexusEvent.addDiscordSender('valid_discord', 'https://discord.com/api/webhooks/123456789/abcdefghij');
      nexusEvent.addDiscordSender('invalid_discord', 'https://discord.com/api/webhooks/invalid/url');

      expect(await nexusEvent.validateSender('valid_discord'), isTrue);
      expect(await nexusEvent.validateSender('invalid_discord'), isFalse);
      expect(await nexusEvent.validateSender('non_existent'), isFalse);
    });

    test('should validate all senders', () async {
      nexusEvent.addDiscordSender('discord1', 'https://discord.com/api/webhooks/123456789/abcdefghij');
      nexusEvent.addDiscordSender('discord2', 'https://discord.com/api/webhooks/invalid/url');

      final results = await nexusEvent.validateAllSenders();
      expect(results['discord1'], isTrue);
      expect(results['discord2'], isFalse);
    });

    test('should clear all senders', () {
      nexusEvent.addDiscordSender('test1', 'https://discord.com/api/webhooks/123456789/abcdefghij');
      nexusEvent.addDiscordSender('test2', 'https://discord.com/api/webhooks/987654321/klmnopqrst');

      expect(nexusEvent.senderNames, hasLength(2));

      nexusEvent.clear();
      expect(nexusEvent.senderNames, isEmpty);
    });
  });

  group('EventMessage', () {
    test('should create message with required fields', () {
      final message = EventMessage(
        title: 'Test Title',
      );

      expect(message.title, equals('Test Title'));
      expect(message.content, isNull);
      expect(message.url, isNull);
      expect(message.author, isNull);
      expect(message.color, isNull);
      expect(message.metadata, isNull);
      expect(message.timestamp, isNull);
    });

    test('should create message with all fields', () {
      final now = DateTime.now();
      final metadata = {'key': 'value'};

      final message = EventMessage(
        title: 'Test Title',
        content: 'Test Content',
        url: 'https://example.com',
        author: 'Test Author',
        color: 0xff0000,
        metadata: metadata,
        timestamp: now,
      );

      expect(message.title, equals('Test Title'));
      expect(message.content, equals('Test Content'));
      expect(message.url, equals('https://example.com'));
      expect(message.author, equals('Test Author'));
      expect(message.color, equals(0xff0000));
      expect(message.metadata, equals(metadata));
      expect(message.timestamp, equals(now));
    });

    test('should serialize to and from JSON', () {
      final now = DateTime.now();
      final originalMessage = EventMessage(
        title: 'Test Title',
        content: 'Test Content',
        url: 'https://example.com',
        author: 'Test Author',
        color: 0xff0000,
        metadata: {'key': 'value'},
        timestamp: now,
      );

      final json = originalMessage.toJson();
      final reconstructedMessage = EventMessage.fromJson(json);

      expect(reconstructedMessage.title, equals(originalMessage.title));
      expect(reconstructedMessage.content, equals(originalMessage.content));
      expect(reconstructedMessage.url, equals(originalMessage.url));
      expect(reconstructedMessage.author, equals(originalMessage.author));
      expect(reconstructedMessage.color, equals(originalMessage.color));
      expect(reconstructedMessage.metadata, equals(originalMessage.metadata));
      expect(
        reconstructedMessage.timestamp?.millisecondsSinceEpoch,
        equals(originalMessage.timestamp?.millisecondsSinceEpoch),
      );
    });
  });

  group('Platform', () {
    test('should have correct string values', () {
      expect(Platform.discord.value, equals('discord'));
      expect(Platform.slack.value, equals('slack'));
      expect(Platform.telegram.value, equals('telegram'));
      expect(Platform.webhook.value, equals('webhook'));
      expect(Platform.teams.value, equals('teams'));
    });
  });

  group('DiscordConfig', () {
    test('should create valid configuration', () {
      const webhookUrl = 'https://discord.com/api/webhooks/123/abc';
      final config = DiscordConfig(webhookUrl: webhookUrl);

      expect(config.platform, equals(Platform.discord));
      expect(config.webhookUrl, equals(webhookUrl));
      expect(config.config['webhookUrl'], equals(webhookUrl));
    });
  });
}