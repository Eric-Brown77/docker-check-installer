#!/bin/bash

# 标题
echo "============================================="
echo "         Docker 安装状态检测与安装工具"
echo "============================================="

# 检查是否已安装Docker
echo "检查 Docker 安装状态..."
if command -v docker &> /dev/null; then
    echo "✓ Docker 已安装"
    docker --version
    exit 0
else
    echo "✗ Docker 命令未安装"
    echo "=== Docker 未安装 ==="
fi

# 重新开放tty以接收用户输入
exec < /dev/tty 2>/dev/null || true

# 显示安装选项
echo "请选择安装方式:"
echo "1. 使用Docker官方安装脚本 (curl)"
echo "2. 使用Docker官方安装脚本 (wget)"
echo "3. 使用系统包管理器 (apt/yum)"
echo "4. 跳过安装"

# 尝试读取用户输入
if [ -t 0 ]; then
    # 终端可用，直接读取
    read -p "请输入选项 [1-4]: " choice
else
    # 终端不可用，提供替代方法
    echo ""
    echo "检测到脚本通过管道运行。请输入选项号码:"
    echo "（如果无法输入，请下载脚本后直接运行）"
    
    # 尝试从/dev/tty读取（可能在某些环境下工作）
    read -p "请输入选项 [1-4]: " choice 2>/dev/null || {
        echo "无法接收输入。请尝试以下方法之一:"
        echo ""
        echo "1. 直接运行这些命令之一:"
        echo "   - curl -fsSL https://get.docker.com | bash"
        echo "   - wget -qO- get.docker.com | bash"
        echo "   - sudo apt update && sudo apt install docker.io (Debian/Ubuntu)"
        echo "   - sudo yum install docker (CentOS/RHEL)"
        echo ""
        echo "2. 下载脚本后交互式运行:"
        echo "   curl -fsSL [脚本URL] -o docker-install.sh"
        echo "   chmod +x docker-install.sh"
        echo "   ./docker-install.sh"
        exit 0
    }
fi

# 根据用户选择执行安装
case $choice in
    1)
        echo "执行安装: Docker官方安装脚本 (curl)"
        curl -fsSL https://get.docker.com | bash
        ;;
    2)
        echo "执行安装: Docker官方安装脚本 (wget)"
        wget -qO- get.docker.com | bash
        ;;
    3)
        echo "执行安装: 系统包管理器"
        if [ -f /etc/debian_version ]; then
            echo "检测到Debian/Ubuntu系统，使用apt安装..."
            sudo apt update
            sudo apt install -y docker.io
            sudo systemctl enable --now docker
        elif [ -f /etc/redhat-release ]; then
            echo "检测到CentOS/RHEL系统，使用yum安装..."
            sudo yum install -y docker
            sudo systemctl enable --now docker
        else
            echo "无法确定系统类型，使用Docker官方脚本安装"
            curl -fsSL https://get.docker.com | bash
        fi
        ;;
    4)
        echo "跳过安装"
        exit 0
        ;;
    *)
        echo "无效选项或未选择，退出"
        exit 1
        ;;
esac

# 安装后检查
if command -v docker &> /dev/null; then
    echo "✓ Docker 安装成功！"
    docker --version
    
    echo "提示: 如需将当前用户添加到docker组(免sudo使用Docker)，请执行:"
    echo "sudo usermod -aG docker \$USER"
    echo "然后注销并重新登录以使更改生效"
else
    echo "✗ Docker安装失败，请尝试其他安装方式"
fi
