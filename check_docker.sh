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
    # 安装Docker
    # 这里可以添加您的安装代码
    echo "开始安装Docker..."
    # ...安装代码
  else
    echo "跳过安装。您可以手动安装 Docker:"
    echo "  - Debian/Ubuntu: sudo apt update && sudo apt install docker.io"
    echo "  - CentOS/RHEL: sudo yum install docker"
    echo "  - 或参考官方文档: https://docs.docker.com/engine/install/"
  fi
else
  # 通过管道运行时，通知用户并提供手动安装方式
  echo "检测到脚本通过管道运行，无法接收交互式输入。"
  echo "跳过安装。您可以手动安装 Docker:"
  echo "  - Debian/Ubuntu: sudo apt update && sudo apt install docker.io"
  echo "  - CentOS/RHEL: sudo yum install docker"
  echo "  - 或参考官方文档: https://docs.docker.com/engine/install/"
  echo ""
  echo "要使用交互式安装，请下载脚本后运行:"
  echo "  curl -fsSL https://raw.githubusercontent.com/Eric-Brown77/docker-check-installer/main/check_docker.sh -o check_docker.sh"
  echo "  chmod +x check_docker.sh"
  echo "  ./check_docker.sh"
fi
