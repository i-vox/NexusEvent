// JavaScript SDK 使用示例
// 注意：在实际使用中，这里应该导入发布到GitHub Packages的包
// const { NexusEvent, Platform } = require('@i-vox/nexusevent-js');

// 使用本地开发版本（从编译后的dist目录导入）
const { NexusEvent, Platform } = require('../../packages/nexusevent-js/dist/index.js');

/**
 * 演示基本的Discord消息发送功能
 */
async function demonstrateDiscordSending() {
  console.log('🚀 NexusEvent JavaScript SDK 演示');
  console.log('=' .repeat(50));

  try {
    // 获取NexusEvent实例
    const nexus = NexusEvent.getInstance();

    // 配置Discord发送器
    const webhookUrl = process.env.DISCORD_WEBHOOK_URL || 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL';
    nexus.addDiscordSender('main_discord', webhookUrl);

    console.log('✅ Discord发送器配置完成');

    // 验证配置
    const isValid = await nexus.validateSender('main_discord');
    if (!isValid) {
      console.warn('⚠️ Discord Webhook URL格式无效或未配置');
      console.log('请设置环境变量 DISCORD_WEBHOOK_URL 为有效的Discord Webhook URL');
      return;
    }

    console.log('✅ 配置验证通过');

    // 发送简单消息
    const simpleMessage = {
      title: '测试消息',
      timestamp: new Date(),
    };

    await nexus.send('main_discord', simpleMessage);
    console.log('✅ 简单消息发送成功');

    // 发送丰富内容的消息
    const richMessage = {
      title: 'JavaScript SDK 演示',
      content: '这是一条通过 NexusEvent JavaScript SDK 发送的测试消息',
      url: 'https://github.com/i-vox/NexusEvent',
      author: 'NexusEvent Bot',
      color: 0x00ff00, // 绿色
      timestamp: new Date(),
    };

    await nexus.send('main_discord', richMessage);
    console.log('✅ 丰富内容消息发送成功');

    // 演示广播功能（发送到所有Discord发送器）
    nexus.addDiscordSender('backup_discord', webhookUrl);
    
    const broadcastMessage = {
      title: '广播测试',
      content: '这条消息将被发送到所有Discord发送器',
      timestamp: new Date(),
    };

    // 使用广播功能发送到所有Discord发送器
    const result = await nexus.broadcast(broadcastMessage, [Platform.DISCORD]);
    console.log(`✅ 广播消息发送成功: ${result.successful}/${result.total} 成功`);

    console.log('\n🎉 所有演示完成！');

  } catch (error) {
    console.error('❌ 演示过程中出现错误:', error.message);
  }
}

/**
 * 演示错误处理
 */
async function demonstrateErrorHandling() {
  console.log('\n🔧 错误处理演示');
  console.log('-' .repeat(30));

  try {
    const nexus = NexusEvent.getInstance();

    // 尝试发送到不存在的发送器
    try {
      await nexus.send('nonexistent_sender', {
        title: '测试消息',
      });
    } catch (error) {
      console.log('✅ 正确捕获了不存在发送器的错误:', error.message);
    }

    // 验证所有发送器
    const validationResults = await nexus.validateAllSenders();
    console.log('📊 发送器验证结果:', validationResults);

  } catch (error) {
    console.error('❌ 错误处理演示失败:', error);
  }
}

/**
 * 主函数
 */
async function main() {
  await demonstrateDiscordSending();
  await demonstrateErrorHandling();
}

// 如果直接运行此文件，则执行演示
if (require.main === module) {
  main().catch(console.error);
}

module.exports = {
  demonstrateDiscordSending,
  demonstrateErrorHandling,
};