#!/bin/bash

# NexusEvent 项目一致性检查脚本
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT=$(dirname "$(dirname "$(readlink -f "$0")")")

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_check() {
    echo -e "${BLUE}[CHECK]${NC} $1"
}

# 检查函数
check_versions() {
    log_check "检查版本号一致性..."
    
    FLUTTER_VERSION=$(grep "version:" packages/nexusevent_flutter/pubspec.yaml | cut -d' ' -f2)
    JS_VERSION=$(grep "\"version\":" packages/nexusevent-js/package.json | cut -d'"' -f4)
    
    if [ "$FLUTTER_VERSION" = "$JS_VERSION" ]; then
        log_info "版本号一致: $FLUTTER_VERSION"
    else
        log_error "版本号不一致: Flutter($FLUTTER_VERSION) vs JavaScript($JS_VERSION)"
        return 1
    fi
}

check_license() {
    log_check "检查许可证一致性..."
    
    # 检查LICENSE文件是否存在
    if [ ! -f "LICENSE" ]; then
        log_error "LICENSE文件不存在"
        return 1
    fi
    
    # 检查LICENSE文件是否是Apache 2.0
    if ! grep -q "Apache License" LICENSE; then
        log_error "LICENSE文件不是Apache 2.0"
        return 1
    fi
    
    # 检查Flutter pubspec.yaml
    if ! grep -q "license: Apache-2.0" packages/nexusevent_flutter/pubspec.yaml; then
        log_error "Flutter pubspec.yaml中的许可证不是Apache-2.0"
        return 1
    fi
    
    # 检查JavaScript package.json
    if ! grep -q '"license": "Apache-2.0"' packages/nexusevent-js/package.json; then
        log_error "JavaScript package.json中的许可证不是Apache-2.0"
        return 1
    fi
    
    log_info "许可证信息一致: Apache-2.0"
}

check_readme_links() {
    log_check "检查README链接..."
    
    # 检查是否存在中英文README
    if [ ! -f "README.md" ] || [ ! -f "README.zh.md" ]; then
        log_error "缺少README文件"
        return 1
    fi
    
    # 检查语言切换链接
    if ! grep -q "README.zh.md" README.md; then
        log_error "英文README缺少中文版本链接"
        return 1
    fi
    
    log_info "README文件检查通过"
}

check_placeholder_values() {
    log_check "检查占位符值..."
    
    ISSUES_FOUND=0
    
    # 检查your-org占位符
    if grep -r "your-org" . --exclude-dir=node_modules --exclude-dir=.dart_tool --exclude="$(basename "$0")" >/dev/null; then
        log_warn "发现your-org占位符，需要替换为实际的组织名"
        grep -r "your-org" . --exclude-dir=node_modules --exclude-dir=.dart_tool --exclude="$(basename "$0")" | head -5
        ISSUES_FOUND=1
    fi
    
    # 检查your-email@example.com占位符
    if grep -r "your-email@example.com" . --exclude-dir=node_modules --exclude-dir=.dart_tool --exclude="$(basename "$0")" >/dev/null; then
        log_warn "发现your-email@example.com占位符，需要替换为实际邮箱"
        ISSUES_FOUND=1
    fi
    
    # 检查YOUR_WEBHOOK_URL占位符
    if grep -r "YOUR_WEBHOOK_URL" . --exclude-dir=node_modules --exclude-dir=.dart_tool --exclude="$(basename "$0")" >/dev/null; then
        log_info "发现YOUR_WEBHOOK_URL占位符（这是正常的示例占位符）"
    fi
    
    if [ $ISSUES_FOUND -eq 0 ]; then
        log_info "占位符检查通过"
    fi
    
    return $ISSUES_FOUND
}

check_dependencies() {
    log_check "检查依赖版本..."
    
    # 检查Flutter依赖
    cd packages/nexusevent_flutter
    if ! flutter pub deps > /dev/null 2>&1; then
        log_error "Flutter依赖有问题"
        cd ../..
        return 1
    fi
    cd ../..
    
    # 检查JavaScript依赖
    cd packages/nexusevent-js
    if [ ! -d "node_modules" ]; then
        log_warn "JavaScript依赖未安装，运行npm install"
        npm install > /dev/null 2>&1
    fi
    cd ../..
    
    log_info "依赖检查通过"
}

check_build() {
    log_check "检查构建..."
    
    # Flutter构建检查
    cd packages/nexusevent_flutter
    if ! flutter analyze > /dev/null 2>&1; then
        log_error "Flutter analyze失败"
        cd ../..
        return 1
    fi
    cd ../..
    
    # JavaScript构建检查
    cd packages/nexusevent-js
    if ! npm run build > /dev/null 2>&1; then
        log_error "JavaScript构建失败"
        cd ../..
        return 1
    fi
    cd ../..
    
    log_info "构建检查通过"
}

check_tests() {
    log_check "检查测试..."
    
    # Flutter测试
    cd packages/nexusevent_flutter
    if ! flutter test > /dev/null 2>&1; then
        log_error "Flutter测试失败"
        cd ../..
        return 1
    fi
    cd ../..
    
    # JavaScript测试
    cd packages/nexusevent-js
    if ! npm test > /dev/null 2>&1; then
        log_error "JavaScript测试失败"
        cd ../..
        return 1
    fi
    cd ../..
    
    log_info "测试检查通过"
}

generate_report() {
    log_info "生成一致性报告..."
    
    echo "# NexusEvent 项目一致性报告" > consistency-report.md
    echo "生成时间: $(date)" >> consistency-report.md
    echo "" >> consistency-report.md
    
    echo "## 版本信息" >> consistency-report.md
    echo "- Flutter SDK: $(grep "version:" packages/nexusevent_flutter/pubspec.yaml | cut -d' ' -f2)" >> consistency-report.md
    echo "- JavaScript SDK: $(grep "\"version\":" packages/nexusevent-js/package.json | cut -d'"' -f4)" >> consistency-report.md
    echo "" >> consistency-report.md
    
    echo "## 许可证信息" >> consistency-report.md
    echo "- 许可证类型: Apache-2.0" >> consistency-report.md
    echo "" >> consistency-report.md
    
    echo "## 文件统计" >> consistency-report.md
    echo "- 总文件数: $(find . -type f \( -name "*.dart" -o -name "*.ts" -o -name "*.js" -o -name "*.md" \) ! -path "./node_modules/*" ! -path "./.dart_tool/*" | wc -l | tr -d ' ')" >> consistency-report.md
    echo "- Dart文件: $(find . -name "*.dart" ! -path "./.dart_tool/*" | wc -l | tr -d ' ')" >> consistency-report.md
    echo "- TypeScript文件: $(find . -name "*.ts" ! -path "./node_modules/*" | wc -l | tr -d ' ')" >> consistency-report.md
    echo "- JavaScript文件: $(find . -name "*.js" ! -path "./node_modules/*" | wc -l | tr -d ' ')" >> consistency-report.md
    echo "- Markdown文件: $(find . -name "*.md" | wc -l | tr -d ' ')" >> consistency-report.md
    
    log_info "报告已生成: consistency-report.md"
}

# 主函数
main() {
    log_info "开始NexusEvent项目一致性检查..."
    echo "项目路径: $PROJECT_ROOT"
    echo ""
    
    cd "$PROJECT_ROOT" || exit 1
    
    TOTAL_CHECKS=0
    PASSED_CHECKS=0
    
    # 运行所有检查
    checks=(
        "check_versions"
        "check_license" 
        "check_readme_links"
        "check_placeholder_values"
        "check_dependencies"
        "check_build"
        "check_tests"
    )
    
    for check in "${checks[@]}"; do
        TOTAL_CHECKS=$((TOTAL_CHECKS + 1))
        if $check; then
            PASSED_CHECKS=$((PASSED_CHECKS + 1))
        fi
        echo ""
    done
    
    # 生成报告
    generate_report
    
    # 总结
    echo "=========================="
    log_info "检查完成: $PASSED_CHECKS/$TOTAL_CHECKS 通过"
    
    if [ $PASSED_CHECKS -eq $TOTAL_CHECKS ]; then
        log_info "🎉 所有检查通过，项目已准备好发布！"
        exit 0
    else
        log_error "⚠️  有 $((TOTAL_CHECKS - PASSED_CHECKS)) 项检查未通过，请修复后重试"
        exit 1
    fi
}

# 如果直接运行此脚本
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi