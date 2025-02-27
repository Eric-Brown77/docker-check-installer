#!/bin/bash

# 设置颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # 无颜色

# 标题
echo "============================================="
echo "     Docker 安装状态检测与自动安装工具"
echo "============================================="

# 检测是否通过管道运行
if [ -t 0 ]; then
  # 交互式运行
  INTERACTIVE=true
else
  # 通过管道运行
  INTERACTIVE=false
  echo "检测到脚本通过管道运行，将自动选择手动安装方式。"
  echo "如需交互式体验，请下载脚本后直接运行。"
  echo ""
fi

# 检查Docker是否已安装
echo "检查 Docker 安装状态..."
if command -v docker &> /dev/null; then
  echo -e "${GREEN}✓ Docker 已安装${NC}"
  docker --version
  
  # 检查Docker服务状态
  if systemctl is-active --quiet docker; then
    echo -e "${GREEN}✓ Docker 服务正在运行${NC}"
  else
    echo -e "${RED}✗ Docker 服务未运行${NC}"
    echo "启动 Docker 服务..."
    sudo systemctl start docker
    if systemctl is-active --quiet docker; then
      echo -e "${GREEN}✓ Docker 服务已启动${NC}"
    else
      echo -e "${RED}✗ 无法启动 Docker 服务${NC}"
    fi
  fi
  
  # 检查当前用户是否在docker组中
  if groups $USER | grep -q docker; then
    echo -e "${GREEN}✓ 当前用户在docker组中${NC}"
  else
    echo -e "${YELLOW}! 当前用户不在docker组中${NC}"
    if $INTERACTIVE; then
      read -p "是否将当前用户添加到docker组? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo usermod -aG docker $USER
        echo "用户已添加到docker组，请注销并重新登录以生效"
      fi
    else
      echo "提示: 您可以使用以下命令将用户添加到docker组:"
      echo "sudo usermod -aG docker \$USER"
      echo "然后注销并重新登录以使更改生效"
    fi
  fi
  
  exit 0
else
  echo -e "${RED}✗ Docker 命令未安装${NC}"
  echo "=== Docker 未安装 ==="
fi

# 安装Docker
install_docker() {
  # 检测Linux发行版
  if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    VER=$DISTRIB_RELEASE
  else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    VER=$(uname -r)
  fi
  
  # 转换为小写
  OS=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
  
  # 根据不同Linux发行版安装Docker
  if [[ "$OS" == *"ubuntu"* ]] || [[ "$OS" == *"debian"* ]]; then
    echo "检测到 $OS 系统，开始安装 Docker..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl enable --now docker
  elif [[ "$OS" == *"centos"* ]] || [[ "$OS" == *"rhel"* ]] || [[ "$OS" == *"fedora"* ]]; then
    echo "检测到 $OS 系统，开始安装 Docker..."
    sudo yum install -y docker
    sudo systemctl enable --now docker
  else
    echo "无法确定您的Linux发行版，请参考Docker官方文档手动安装:"
    echo "https://docs.docker.com/engine/install/"
    exit 1
  fi
  
  # 检查安装结果
  if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker 安装成功${NC}"
    docker --version
    echo "将当前用户添加到docker组..."
    sudo usermod -aG docker $USER
    echo -e "${YELLOW}注意: 请注销并重新登录以使docker组变更生效${NC}"
  else
    echo -e "${RED}✗ Docker 安装失败${NC}"
    echo "请尝试手动安装或参考Docker官方文档:"
    echo "https://docs.docker.com/engine/install/"
    exit 1
  fi
}

# 处理安装选择
if $INTERACTIVE; then
  # 交互模式
  read -p "是否要自动安装Docker? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    install_docker
  else
    echo "跳过安装。您可以手动安装 Docker:"
    echo "  - Debian/Ubuntu: sudo apt update && sudo apt install docker.io"
    echo "  - CentOS/RHEL: sudo yum install docker"
    echo "  - 或参考官方文档: https://docs.docker.com/engine/install/"
  fi
else
  # 非交互模式 - 提供安装指导
  echo "由于以非交互方式运行，跳过自动安装。您可以:"
  echo "1. 直接执行以下命令安装Docker(适用于Debian/Ubuntu):"
  echo "   sudo apt update && sudo apt install docker.io -y && sudo systemctl enable --now docker"
  echo ""
  echo "2. 下载并直接运行此脚本以使用交互功能:"
  echo "   curl -fsSL https://raw.githubusercontent.com/Eric-Brown77/docker-check-installer/main/check_docker.sh -o check_docker.sh"
  echo "   chmod +x check_docker.sh"
  echo "   ./check_docker.sh"
  echo ""
  echo "3. 参考Docker官方文档: https://docs.docker.com/engine/install/"
fi
