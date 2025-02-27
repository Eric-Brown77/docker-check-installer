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
echo "1. 使用Docker官方仓库安装 (推荐)"
echo "2. 使用系统包管理器安装 (简单)"
echo "3. 跳过安装"

# 读取用户输入
read -p "请输入选项 [1-3]: " choice

# 根据用户选择执行安装
case $choice in
    1)
        echo "执行安装: Docker官方仓库"
        if [ -f /etc/debian_version ]; then
            echo "检测到Debian/Ubuntu系统，开始安装..."
            echo "步骤1: 更新软件包索引"
            sudo apt-get update
            
            echo "步骤2: 安装依赖包"
            sudo apt-get install -y ca-certificates curl gnupg
            
            echo "步骤3: 添加Docker官方GPG密钥"
            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            sudo chmod a+r /etc/apt/keyrings/docker.gpg
            
            echo "步骤4: 设置Docker仓库"
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            
            echo "步骤5: 更新软件包索引"
            sudo apt-get update
            
            echo "步骤6: 安装Docker"
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        elif [ -f /etc/redhat-release ]; then
            echo "检测到CentOS/RHEL系统，开始安装..."
            echo "步骤1: 安装必要的依赖"
            sudo yum install -y yum-utils
            
            echo "步骤2: 设置Docker仓库"
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            
            echo "步骤3: 安装Docker"
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            
            echo "步骤4: 启动Docker"
            sudo systemctl start docker
            sudo systemctl enable docker
        else
            echo "无法确定系统类型，请参考Docker官方文档手动安装:"
            echo "https://docs.docker.com/engine/install/"
            exit 1
        fi
        ;;
    2)
        echo "执行安装: 系统包管理器"
        if [ -f /etc/debian_version ]; then
            echo "检测到Debian/Ubuntu系统，使用apt安装..."
            sudo apt-get update
            sudo apt-get install -y docker.io
            sudo systemctl enable --now docker
        elif [ -f /etc/redhat-release ]; then
            echo "检测到CentOS/RHEL系统，使用yum安装..."
            sudo yum install -y docker
            sudo systemctl enable --now docker
        else
            echo "无法确定系统类型，请参考Docker官方文档手动安装:"
            echo "https://docs.docker.com/engine/install/"
            exit 1
        fi
        ;;
    3)
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
    echo "是否将当前用户添加到docker组（免sudo运行docker）？(y/n)"
    read -p "> " add_user
    if [[ "$add_user" =~ ^[Yy]$ ]]; then
        sudo usermod -aG docker $USER
        echo "用户已添加到docker组"
        echo "请注销并重新登录以使更改生效"
    fi
    
    echo ""
    echo "测试Docker是否正常工作:"
    echo "sudo docker run hello-world"
else
    echo "✗ Docker安装失败，请尝试其他安装方式"
fi
