import { NexusEvent } from './NexusEvent';
import { DiscordSender } from './senders/DiscordSender';
import { Platform, EventMessage, DiscordConfig } from './types';

// Mock axios
jest.mock('axios');

describe('NexusEvent', () => {
  let nexusEvent: NexusEvent;

  beforeEach(() => {
    nexusEvent = NexusEvent.getInstance();
    nexusEvent.clear(); // 清空之前的配置
  });

  describe('getInstance', () => {
    it('should return singleton instance', () => {
      const instance1 = NexusEvent.getInstance();
      const instance2 = NexusEvent.getInstance();
      expect(instance1).toBe(instance2);
    });
  });

  describe('sender management', () => {
    it('should add and remove senders', () => {
      expect(nexusEvent.senderNames).toHaveLength(0);

      nexusEvent.addDiscordSender('test_discord', 'https://discord.com/api/webhooks/test');
      expect(nexusEvent.senderNames).toContain('test_discord');
      expect(nexusEvent.senderNames).toHaveLength(1);

      nexusEvent.removeSender('test_discord');
      expect(nexusEvent.senderNames).toHaveLength(0);
    });

    it('should add custom sender', () => {
      const config: DiscordConfig = {
        platform: Platform.DISCORD,
        config: { webhookUrl: 'https://discord.com/api/webhooks/123/abc' }
      };
      const sender = new DiscordSender(config);

      nexusEvent.addSender('custom_discord', sender);
      expect(nexusEvent.senderNames).toContain('custom_discord');
    });

    it('should clear all senders', () => {
      nexusEvent.addDiscordSender('test1', 'https://discord.com/api/webhooks/123');
      nexusEvent.addDiscordSender('test2', 'https://discord.com/api/webhooks/456');

      expect(nexusEvent.senderNames).toHaveLength(2);

      nexusEvent.clear();
      expect(nexusEvent.senderNames).toHaveLength(0);
    });
  });

  describe('message sending', () => {
    const testMessage: EventMessage = {
      title: 'Test Message',
    };

    it('should throw error for non-existent sender', async () => {
      await expect(nexusEvent.send('non_existent', testMessage))
        .rejects
        .toThrow('发送器 "non_existent" 不存在');
    });

    it('should send message to existing sender', async () => {
      const mockSend = jest.fn().mockResolvedValue(undefined);
      const mockSender = {
        platform: Platform.DISCORD,
        send: mockSend,
        validateConfig: jest.fn().mockResolvedValue(true)
      };

      nexusEvent.addSender('test_sender', mockSender);

      await nexusEvent.send('test_sender', testMessage);
      expect(mockSend).toHaveBeenCalledWith(testMessage);
    });
  });

  describe('broadcast', () => {
    const testMessage: EventMessage = {
      title: 'Broadcast Message',
    };

    it('should broadcast to all senders', async () => {
      const mockSend1 = jest.fn().mockResolvedValue(undefined);
      const mockSend2 = jest.fn().mockResolvedValue(undefined);

      const mockSender1 = {
        platform: Platform.DISCORD,
        send: mockSend1,
        validateConfig: jest.fn().mockResolvedValue(true)
      };

      const mockSender2 = {
        platform: Platform.SLACK,
        send: mockSend2,
        validateConfig: jest.fn().mockResolvedValue(true)
      };

      nexusEvent.addSender('discord', mockSender1);
      nexusEvent.addSender('slack', mockSender2);

      await nexusEvent.broadcast(testMessage);

      expect(mockSend1).toHaveBeenCalledWith(testMessage);
      expect(mockSend2).toHaveBeenCalledWith(testMessage);
    });

    it('should broadcast only to specified platforms', async () => {
      const mockSend1 = jest.fn().mockResolvedValue(undefined);
      const mockSend2 = jest.fn().mockResolvedValue(undefined);

      const mockSender1 = {
        platform: Platform.DISCORD,
        send: mockSend1,
        validateConfig: jest.fn().mockResolvedValue(true)
      };

      const mockSender2 = {
        platform: Platform.SLACK,
        send: mockSend2,
        validateConfig: jest.fn().mockResolvedValue(true)
      };

      nexusEvent.addSender('discord', mockSender1);
      nexusEvent.addSender('slack', mockSender2);

      await nexusEvent.broadcast(testMessage, [Platform.DISCORD]);

      expect(mockSend1).toHaveBeenCalledWith(testMessage);
      expect(mockSend2).not.toHaveBeenCalled();
    });
  });

  describe('validation', () => {
    it('should validate sender configuration', async () => {
      const mockValidate = jest.fn().mockResolvedValue(true);
      const mockSender = {
        platform: Platform.DISCORD,
        send: jest.fn(),
        validateConfig: mockValidate
      };

      nexusEvent.addSender('test_sender', mockSender);

      const result = await nexusEvent.validateSender('test_sender');
      expect(result).toBe(true);
      expect(mockValidate).toHaveBeenCalled();
    });

    it('should return false for non-existent sender', async () => {
      const result = await nexusEvent.validateSender('non_existent');
      expect(result).toBe(false);
    });

    it('should validate all senders', async () => {
      const mockSender1 = {
        platform: Platform.DISCORD,
        send: jest.fn(),
        validateConfig: jest.fn().mockResolvedValue(true)
      };

      const mockSender2 = {
        platform: Platform.SLACK,
        send: jest.fn(),
        validateConfig: jest.fn().mockResolvedValue(false)
      };

      nexusEvent.addSender('sender1', mockSender1);
      nexusEvent.addSender('sender2', mockSender2);

      const results = await nexusEvent.validateAllSenders();
      expect(results).toEqual({
        sender1: true,
        sender2: false
      });
    });
  });
});