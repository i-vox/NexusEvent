# NexusEvent JavaScript SDK

A powerful JavaScript/TypeScript SDK for cross-platform message sending, supporting Discord, Slack, Telegram and more platforms.

## Features

- 🚀 Multi-platform support (Discord, Slack, Telegram, etc.)
- 💻 Works in Node.js, browsers, and other JavaScript environments
- 🔄 Promise-based API with comprehensive error handling
- 🎨 Rich message formatting and embed support
- 🛡️ Built-in security and rate limiting
- 📝 Full TypeScript support with strong typing
- 📦 Tree-shakable ES modules and CommonJS support

## Installation

```bash
npm install @nexusevent/nexusevent-js
```

Or with yarn:

```bash
yarn add @nexusevent/nexusevent-js
```

## Quick Start

### ES Modules (Recommended)

```javascript
import { NexusEventClient, DiscordWebhookConfig } from '@nexusevent/nexusevent-js';

const client = new NexusEventClient();

// Discord webhook example
const discordConfig = new DiscordWebhookConfig({
  webhookUrl: 'your-discord-webhook-url'
});

try {
  const result = await client.sendDiscordMessage({
    config: discordConfig,
    content: 'Hello from NexusEvent JavaScript SDK!'
  });
  console.log('Message sent successfully:', result.success);
} catch (error) {
  console.error('Error sending message:', error);
}
```

### CommonJS

```javascript
const { NexusEventClient, DiscordWebhookConfig } = require('@nexusevent/nexusevent-js');

const client = new NexusEventClient();
// ... rest is the same
```

## Supported Platforms

- **Discord**: Webhook messages with rich embeds
- **Slack**: Webhook and Bot API support
- **Telegram**: Bot API integration
- And more coming soon...

## Advanced Usage

### Discord Rich Embeds

```javascript
import { NexusEventClient, DiscordWebhookConfig } from '@nexusevent/nexusevent-js';

const client = new NexusEventClient();
const config = new DiscordWebhookConfig({
  webhookUrl: 'your-webhook-url'
});

await client.sendDiscordMessage({
  config,
  embeds: [{
    title: 'System Alert',
    description: 'Server deployment completed successfully',
    color: 0x00ff00,
    fields: [
      { name: 'Environment', value: 'Production', inline: true },
      { name: 'Version', value: 'v1.2.3', inline: true }
    ],
    timestamp: new Date().toISOString()
  }]
});
```

### Slack Messages

```javascript
import { NexusEventClient, SlackWebhookConfig } from '@nexusevent/nexusevent-js';

const client = new NexusEventClient();
const config = new SlackWebhookConfig({
  webhookUrl: 'your-slack-webhook-url'
});

await client.sendSlackMessage({
  config,
  text: 'Deployment notification',
  blocks: [
    {
      type: 'section',
      text: {
        type: 'mrkdwn',
        text: '*Deployment Complete* :white_check_mark:\nVersion 1.2.3 is now live!'
      }
    }
  ]
});
```

## TypeScript Support

This package is written in TypeScript and includes comprehensive type definitions:

```typescript
import { 
  NexusEventClient, 
  DiscordWebhookConfig, 
  DiscordEmbed,
  MessageResult 
} from '@nexusevent/nexusevent-js';

const client: NexusEventClient = new NexusEventClient();

const embed: DiscordEmbed = {
  title: 'Typed Embed',
  description: 'Full TypeScript support!',
  color: 0x7289da
};

const result: MessageResult = await client.sendDiscordMessage({
  config: new DiscordWebhookConfig({ webhookUrl: 'url' }),
  embeds: [embed]
});
```

## Error Handling

```javascript
import { NexusEventClient, NexusEventError } from '@nexusevent/nexusevent-js';

try {
  await client.sendMessage(/* ... */);
} catch (error) {
  if (error instanceof NexusEventError) {
    console.error('NexusEvent Error:', error.message);
    console.error('Error Code:', error.code);
  } else {
    console.error('Unknown error:', error);
  }
}
```

## Browser Usage

The SDK works in browsers with module bundlers like Webpack, Rollup, or Vite:

```html
<script type="module">
  import { NexusEventClient } from './node_modules/@nexusevent/nexusevent-js/dist/index.esm.js';
  
  const client = new NexusEventClient();
  // ... use the client
</script>
```

## Documentation

For detailed documentation and examples, visit:
- [Main Documentation](https://github.com/i-vox/NexusEvent)
- [JavaScript Demo](https://github.com/i-vox/NexusEvent/tree/main/examples/js-demo)
- [API Reference](https://github.com/i-vox/NexusEvent/tree/main/packages/nexusevent-js/docs)

## Contributing

We welcome contributions! Please see our [Contributing Guide](https://github.com/i-vox/NexusEvent/blob/main/.github/CONTRIBUTING.md) for details.

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.

## Support

- [GitHub Issues](https://github.com/i-vox/NexusEvent/issues)
- [Security Policy](https://github.com/i-vox/NexusEvent/blob/main/.github/SECURITY.md)