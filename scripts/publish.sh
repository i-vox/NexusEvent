#!/bin/bash

# NexusEvent 发布脚本
# 仅限项目所有者使用

set -e

echo "🚀 开始发布 NexusEvent v0.1.0"

# 验证发布权限
if [ "$GITHUB_USERNAME" != "i-vox" ]; then
    echo "❌ 错误: 仅限项目所有者发布"
    exit 1
fi

# 检查必需的环境变量
if [ -z "$NPM_TOKEN" ]; then
    echo "❌ 错误: 请设置 NPM_TOKEN 环境变量"
    echo "   获取方法: https://docs.npmjs.com/creating-and-viewing-access-tokens"
    exit 1
fi

if [ -z "$GITHUB_USERNAME" ]; then
    echo "❌ 错误: 请设置 GITHUB_USERNAME 环境变量"
    exit 1
fi

if [ -z "$AUTHOR_EMAIL" ]; then
    echo "❌ 错误: 请设置 AUTHOR_EMAIL 环境变量"
    exit 1
fi

# 获取项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "📦 准备发布 JavaScript SDK..."

# 发布 JavaScript SDK
cd packages/nexusevent-js

# 设置 NPM 认证
echo "🔑 设置 NPM 认证..."
echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" > ~/.npmrc

# 构建和测试
echo "🔧 构建 JavaScript SDK..."
npm run build

echo "🧪 运行 JavaScript SDK 测试..."
npm test

# 发布到 NPM
echo "📤 发布到 NPM..."
npm publish --access public

echo "✅ JavaScript SDK 发布成功!"

cd "$PROJECT_ROOT"

echo "📦 准备发布 Flutter SDK..."

# 发布 Flutter SDK
cd packages/nexusevent_flutter

# Flutter Pub.dev 发布需要交互式认证
echo "🔑 Flutter Pub.dev 发布准备..."
echo "注意: Flutter SDK 发布需要手动认证"

# 获取依赖和测试
echo "🔧 获取 Flutter 依赖..."
flutter pub get

echo "🧪 运行 Flutter SDK 测试..."
flutter test

# 准备发布到 Pub.dev (需要手动确认)
echo "📤 准备发布到 Pub.dev..."
echo "请手动运行: flutter pub publish"

cd "$PROJECT_ROOT"

echo "🎉 JavaScript SDK 发布完成!"
echo ""
echo "📋 发布信息:"
echo "  - JavaScript SDK: @nexusevent/nexusevent-js@0.1.0 ✅"
echo "  - Flutter SDK: nexusevent_flutter@0.1.0 (需要手动发布)"
echo ""
echo "🔗 下一步:"
echo "  1. cd packages/nexusevent_flutter && flutter pub publish"
echo "  2. 创建 GitHub Release tag: git tag v0.1.0 && git push origin v0.1.0"
echo "  3. 更新 README 中的安装说明"