#!/bin/bash

# 标题
echo "============================================="
echo "     Docker 安装状态检测与自动安装工具"
echo "============================================="

# 检查Docker是否已安装
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
  read -p "是否要自动安装Docker? (y/n) " REPLY
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 检测系统类型
    if [ -f /etc/debian_version ]; then
      # Debian/Ubuntu
      echo "开始安装 Docker..."
      sudo apt update
      sudo apt install -y docker.io
      sudo systemctl enable --now docker
    elif [ -f /etc/redhat-release ]; then
      # CentOS/RHEL
      echo "开始安装 Docker..."
      sudo yum install -y docker
      sudo systemctl enable --now docker
    else
      echo "无法自动确定您的系统类型，请手动安装Docker"
    fi
  else
    echo "跳过安装。您可以手动安装 Docker:"
    echo "  - Debian/Ubuntu: sudo apt update && sudo apt install docker.io"
    echo "  - CentOS/RHEL: sudo yum install docker"
    echo "  - 或参考官方文档: https://docs.docker.com/engine/install/"
  fi
else
  # 非交互模式 - 直接提供安装说明
  echo "检测到脚本通过管道运行，无法进行交互。请尝试以下方式之一:"
  echo ""
  echo "1. 下载脚本后直接运行，以启用交互功能:"
  echo "   curl -fsSL https://raw.githubusercontent.com/Eric-Brown77/docker-check-installer/main/check_docker.sh -o check_docker.sh"
  echo "   chmod +x check_docker.sh"
  echo "   ./check_docker.sh"
  echo ""
  echo "2. 或直接运行安装命令:"
  echo "   - Debian/Ubuntu: sudo apt update && sudo apt install docker.io"
  echo "   - CentOS/RHEL: sudo yum install docker"
fi
