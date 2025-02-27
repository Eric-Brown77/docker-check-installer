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
        echo "正在下载并执行Docker官方安装脚本..."
        # 使用 -v 参数增加curl的详细输出
        curl -v -fsSL https://get.docker.com -o get-docker.sh
        echo "执行安装脚本..."
        # 直接运行脚本而不通过管道，确保输出可见
        bash get-docker.sh
        rm get-docker.sh
        ;;
    2)
        echo "执行安装: Docker官方安装脚本 (wget)"
        echo "正在下载并执行Docker官方安装脚本..."
        # 移除 -q 参数，允许wget显示进度
        wget -O- get.docker.com > get-docker.sh
        echo "执行安装脚本..."
        bash get-docker.sh
        rm get-docker.sh
        ;;
    3)
        echo "执行安装: 系统包管理器"
        if [ -f /etc/debian_version ]; then
            echo "检测到Debian/Ubuntu系统，使用apt安装..."
            echo "正在更新软件包列表..."
            sudo apt update -y
            echo "安装Docker..."
            sudo apt install -y docker.io
            echo "启用并启动Docker服务..."
            sudo systemctl enable docker
            sudo systemctl start docker
        elif [ -f /etc/redhat-release ]; then
            echo "检测到CentOS/RHEL系统，使用yum安装..."
            echo "安装Docker..."
            sudo yum install -y docker
            echo "启用并启动Docker服务..."
            sudo systemctl enable docker
            sudo systemctl start docker
        else
            echo "无法确定系统类型，使用Docker官方脚本安装"
            curl -fsSL https://get.docker.com -o get-docker.sh
            bash get-docker.sh
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
