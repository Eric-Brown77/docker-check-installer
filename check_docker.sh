#!/bin/bash

# 启用bash调试模式以显示详细执行信息
set -x

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

# 显示安装选项
echo "请选择安装方式:"
echo "1. 使用Docker官方安装脚本 (curl)"
echo "2. 使用Docker官方安装脚本 (wget)"
echo "3. 使用系统包管理器 (apt/yum)"
echo "4. 跳过安装"

# 读取用户输入
read -p "请输入选项 [1-4]: " choice

# 根据用户选择执行安装
case $choice in
    1)
        echo "执行安装: Docker官方安装脚本 (curl)"
        # 下载脚本并设置环境变量强制显示详细输出
        curl -fsSL https://get.docker.com -o get-docker.sh
        # 使用 bash -x 运行脚本，显示每个执行的命令
        VERBOSE=1 DRY_RUN=0 bash -x get-docker.sh
        rm get-docker.sh
        ;;
    2)
        echo "执行安装: Docker官方安装脚本 (wget)"
        wget -O get-docker.sh https://get.docker.com
        VERBOSE=1 DRY_RUN=0 bash -x get-docker.sh
        rm get-docker.sh
        ;;
    3)
        echo "执行安装: 系统包管理器"
        if [ -f /etc/debian_version ]; then
            echo "检测到Debian/Ubuntu系统，使用apt安装..."
            set -x  # 启用命令跟踪
            sudo apt update -y
            sudo apt install -y docker.io
            sudo systemctl enable docker
            sudo systemctl start docker
            set +x  # 禁用命令跟踪
        elif [ -f /etc/redhat-release ]; then
            echo "检测到CentOS/RHEL系统，使用yum安装..."
            set -x  # 启用命令跟踪
            sudo yum install -y docker
            sudo systemctl enable docker
            sudo systemctl start docker
            set +x  # 禁用命令跟踪
        else
            echo "无法确定系统类型，使用Docker官方脚本安装"
            curl -fsSL https://get.docker.com -o get-docker.sh
            VERBOSE=1 DRY_RUN=0 bash -x get-docker.sh
            rm get-docker.sh
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

# 关闭调试模式
set +x

# 安装后检查
echo "检查Docker安装状态..."
if command -v docker &> /dev/null; then
    echo "✓ Docker 安装成功！"
    echo "Docker版本信息:"
    docker --version
    
    echo ""
    echo "Docker服务状态:"
    sudo systemctl status docker --no-pager
    
    echo ""
    echo "提示: 如需将当前用户添加到docker组(免sudo使用Docker)，请执行:"
    echo "sudo usermod -aG docker \$USER"
    echo "然后注销并重新登录以使更改生效"
    
    echo ""
    echo "测试Docker是否正常工作:"
    echo "sudo docker run hello-world"
else
    echo "✗ Docker安装失败，请尝试其他安装方式"
fi
