#!/bin/bash

# 标题
echo "============================================="
echo "         Docker 全自动安装工具"
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
    # 交互式运行 - 提示用户
    echo "请选择安装方式："
    echo "1) 使用Docker官方安装脚本 (curl)"
    echo "2) 使用Docker官方安装脚本 (wget)"
    echo "3) 使用系统包管理器安装 (apt/yum)"
    echo "4) 跳过安装"
    
    read -p "请输入选项 [1-4]: " choice
    
    case $choice in
        1)
            echo "使用Docker官方安装脚本 (curl)..."
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            rm get-docker.sh
            ;;
        2)
            echo "使用Docker官方安装脚本 (wget)..."
            wget -qO- get.docker.com | sudo bash
            ;;
        3)
            # 检测系统类型
            if [ -f /etc/debian_version ]; then
                # Debian/Ubuntu
                echo "检测到Debian/Ubuntu系统，使用apt安装..."
                sudo apt update
                sudo apt install -y docker.io
                sudo systemctl enable --now docker
            elif [ -f /etc/redhat-release ]; then
                # CentOS/RHEL
                echo "检测到CentOS/RHEL系统，使用yum安装..."
                sudo yum install -y docker
                sudo systemctl enable --now docker
            else
                echo "无法自动检测系统类型，尝试使用Docker官方脚本..."
                curl -fsSL https://get.docker.com -o get-docker.sh
                sudo sh get-docker.sh
                rm get-docker.sh
            fi
            ;;
        4)
            echo "跳过安装。您可以稍后手动安装Docker："
            echo "  - 官方安装脚本: curl -fsSL https://get.docker.com | bash"
            echo "  - Debian/Ubuntu: sudo apt update && sudo apt install docker.io"
            echo "  - CentOS/RHEL: sudo yum install docker"
            exit 0
            ;;
        *)
            echo "无效选项，使用默认方式安装（Docker官方脚本）..."
            curl -fsSL https://get.docker.com -o get-docker.sh
            sudo sh get-docker.sh
            rm get-docker.sh
            ;;
    esac
else
    # 非交互式运行 - 提供选项
    echo "检测到脚本通过管道运行，无法接收交互式输入。"
    echo "您可以通过以下方式安装Docker："
    echo ""
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

# 检查安装结果
if command -v docker &> /dev/null; then
    echo "✓ Docker 安装成功！"
    docker --version
    
    echo "是否将当前用户添加到docker组（免sudo运行docker）？"
    echo "1) 是"
    echo "2) 否"
    
    read -p "请选择 [1-2]: " user_choice
    if [ "$user_choice" = "1" ]; then
        sudo usermod -aG docker $USER
        echo "用户已添加到docker组"
        echo "请注销并重新登录以使更改生效"
    fi
    
    echo "Docker安装和配置完成！"
else
    echo "✗ Docker安装失败，请尝试其他安装方式或检查系统兼容性"
fi
