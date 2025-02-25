# Docker检测与自动安装工具

这个脚本可以自动检测Linux系统上是否安装了Docker，并提供自动安装功能。

## 功能特点

- 检测系统是否已安装Docker
- 显示Docker版本和服务状态
- 验证用户权限
- 如未安装，自动使用官方安装脚本安装Docker
- 支持多种Linux发行版
- 安装后进行全面检测

## 直接使用（一行命令）

使用curl:
```bash
curl -fsSL https://raw.githubusercontent.com/Eric-Brown77/docker-check-installer/main/check_docker.sh | bash
