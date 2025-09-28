import 'package:flutter/material.dart';
// 注意：在实际使用中，这里应该导入发布到pub.dev的包
// import 'package:nexusevent_flutter/nexusevent.dart';

// 临时导入本地开发版本
import '../../packages/nexusevent_flutter/lib/nexusevent.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NexusEvent Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'NexusEvent Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _webhookUrlController = TextEditingController();

  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeSDK();
  }

  void _initializeSDK() {
    // 初始化NexusEvent SDK
    // 注意：在生产环境中，Webhook URL应该通过配置文件或环境变量获取
    const defaultWebhookUrl = 'https://discord.com/api/webhooks/YOUR_WEBHOOK_URL';
    _webhookUrlController.text = defaultWebhookUrl;
  }

  Future<void> _setupDiscordSender() async {
    try {
      final webhookUrl = _webhookUrlController.text.trim();
      if (webhookUrl.isEmpty) {
        setState(() {
          _statusMessage = '请输入Discord Webhook URL';
        });
        return;
      }

      // 添加Discord发送器
      NexusEvent.instance.addDiscordSender('main_discord', webhookUrl);

      // 验证配置
      final isValid = await NexusEvent.instance.validateSender('main_discord');
      setState(() {
        _statusMessage = isValid 
          ? '✅ Discord发送器配置成功' 
          : '❌ Discord Webhook URL格式无效';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '❌ 配置失败: $e';
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _statusMessage = '请输入消息标题';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = '正在发送消息...';
    });

    try {
      final message = EventMessage(
        title: _titleController.text.trim(),
        content: _contentController.text.trim().isNotEmpty 
          ? _contentController.text.trim() 
          : null,
        url: _urlController.text.trim().isNotEmpty 
          ? _urlController.text.trim() 
          : null,
        author: _authorController.text.trim().isNotEmpty 
          ? _authorController.text.trim() 
          : null,
        color: 0x33ccff,
        timestamp: DateTime.now(),
      );

      await NexusEvent.instance.send('main_discord', message);

      setState(() {
        _statusMessage = '✅ 消息发送成功！';
      });

      // 清空表单
      _titleController.clear();
      _contentController.clear();
      _urlController.clear();
      _authorController.clear();
    } catch (e) {
      setState(() {
        _statusMessage = '❌ 发送失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 配置区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '配置 Discord Webhook',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _webhookUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Discord Webhook URL',
                        hintText: 'https://discord.com/api/webhooks/...',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _setupDiscordSender,
                      child: const Text('设置Discord发送器'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 消息输入区域
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '发送消息',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: '消息标题 *',
                          hintText: '输入消息标题',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: '消息内容',
                          hintText: '输入详细内容（可选）',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _urlController,
                        decoration: const InputDecoration(
                          labelText: 'URL链接',
                          hintText: 'https://example.com（可选）',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _authorController,
                        decoration: const InputDecoration(
                          labelText: '作者',
                          hintText: '消息作者（可选）',
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _sendMessage,
                          child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('发送到 Discord'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 状态显示区域
            if (_statusMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _statusMessage.startsWith('✅') 
                    ? Colors.green.withValues(alpha: 0.1)
                    : _statusMessage.startsWith('❌')
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage.startsWith('✅')
                      ? Colors.green
                      : _statusMessage.startsWith('❌')
                        ? Colors.red
                        : Colors.blue,
                  ),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.startsWith('✅')
                      ? Colors.green.shade700
                      : _statusMessage.startsWith('❌')
                        ? Colors.red.shade700
                        : Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _urlController.dispose();
    _authorController.dispose();
    _webhookUrlController.dispose();
    super.dispose();
  }
}