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

# 检测是否通过管道运行
if [ -t 0 ]; then
    # 交互式运行
    echo "请选择安装方式:"
    echo "1. 使用Docker官方安装脚本 (curl)"
    echo "2. 使用Docker官方安装脚本 (wget)"
    echo "3. 使用系统包管理器 (apt/yum)"
    echo "4. 跳过安装"
    
    read -p "请输入选项 [1-4]: " choice
    
    case $choice in
        1)
            echo "执行安装: curl -fsSL https://get.docker.com | bash"
            curl -fsSL https://get.docker.com | bash
            ;;
        2)
            echo "执行安装: wget -qO- get.docker.com | bash"
            wget -qO- get.docker.com | bash
            ;;
        3)
            if [ -f /etc/debian_version ]; then
                echo "执行安装: sudo apt update && sudo apt install -y docker.io"
                sudo apt update && sudo apt install -y docker.io
                sudo systemctl enable --now docker
            elif [ -f /etc/redhat-release ]; then
                echo "执行安装: sudo yum install -y docker"
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
            echo "无效选项，退出"
            exit 1
            ;;
    esac
else
    # 通过管道运行
    echo "检测到脚本通过管道运行，无法接收交互式输入。"
    echo "您可以通过以下方式安装Docker："
    echo "1. 使用Docker官方安装脚本："
    echo "   curl -fsSL https://get.docker.com | bash"
    echo "   或"
    echo "   wget -qO- get.docker.com | bash"
    echo ""
    echo "2. 使用系统包管理器："
    echo "   - Debian/Ubuntu: sudo apt update && sudo apt install docker.io"
    echo "   - CentOS/RHEL: sudo yum install docker"
    echo ""
    echo "3. 下载此脚本后以交互方式运行："
    echo "   curl -fsSL [脚本URL] -o docker-install.sh"
    echo "   chmod +x docker-install.sh"
    echo "   ./docker-install.sh"
    exit 0
fi

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
