#!/bin/bash

# 设置颜色输出
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # 无颜色

echo "============================================="
echo "     Docker 安装状态检测与自动安装工具"
echo "============================================="

# 检查 docker 命令是否存在
check_docker_command() {
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}✓ Docker 命令已安装${NC}"
        return 0
    else
        echo -e "${RED}✗ Docker 命令未安装${NC}"
        return 1
    fi
}

# 检查 docker 服务状态
check_docker_service() {
    if systemctl is-active --quiet docker; then
        echo -e "${GREEN}✓ Docker 服务正在运行${NC}"
        return 0
    else
        echo -e "${RED}✗ Docker 服务未运行${NC}"
        return 1
    fi
}

# 尝试运行 docker 版本命令
check_docker_version() {
    if docker --version &> /dev/null; then
        echo -e "${GREEN}✓ Docker 版本: $(docker --version)${NC}"
        return 0
    else
        echo -e "${RED}✗ 无法获取 Docker 版本${NC}"
        return 1
    fi
}

# 检查 docker 运行权限
check_docker_permission() {
    if docker info &> /dev/null; then
        echo -e "${GREEN}✓ 当前用户有权限运行 Docker${NC}"
        return 0
    else
        echo -e "${YELLOW}! 当前用户可能没有权限运行 Docker${NC}"
        echo -e "${YELLOW}  可能需要将用户添加到 docker 组或使用 sudo${NC}"
        return 1
    fi
}

# 安装Docker函数
install_docker() {
    echo -e "\n${YELLOW}=== 尝试安装 Docker ===${NC}"
    
    # 尝试使用第一种方法安装
    echo -e "${YELLOW}尝试使用 curl 安装 Docker...${NC}"
    if command -v curl &> /dev/null; then
        echo "执行: curl -fsSL https://get.docker.com | bash -s docker"
        curl -fsSL https://get.docker.com | bash -s docker
        
        # 安装后检查
        echo -e "\n${YELLOW}=== 检查安装结果 ===${NC}"
        if check_docker_command; then
            echo -e "${GREEN}Docker 安装成功!${NC}"
            return 0
        else
            echo -e "${RED}第一种安装方法失败，尝试第二种方法...${NC}"
        fi
    else
        echo -e "${RED}curl 命令不存在，跳过第一种安装方法${NC}"
    fi
    
    # 尝试使用第二种方法安装
    echo -e "${YELLOW}尝试使用 wget 安装 Docker...${NC}"
    if command -v wget &> /dev/null; then
        echo "执行: wget -qO- get.docker.com | bash"
        wget -qO- get.docker.com | bash
        
        # 安装后再次检查
        echo -e "\n${YELLOW}=== 检查安装结果 ===${NC}"
        if check_docker_command; then
            echo -e "${GREEN}Docker 安装成功!${NC}"
            return 0
        else
            echo -e "${RED}第二种安装方法也失败了${NC}"
            return 1
        fi
    else
        echo -e "${RED}wget 命令不存在，无法使用第二种安装方法${NC}"
        return 1
    fi
}

# 主函数
main() {
    echo "检查 Docker 安装状态..."
    
    # 检查是否存在 docker 命令
    if check_docker_command; then
        # 如果命令存在，检查版本
        check_docker_version
        
        # 检查服务状态，如果系统使用systemd
        if command -v systemctl &> /dev/null; then
            check_docker_service
        else
            echo -e "${YELLOW}! 系统不使用 systemd，跳过服务状态检查${NC}"
        fi
        
        # 检查权限
        check_docker_permission
        
        # 尝试运行简单的docker命令
        if docker ps &> /dev/null; then
            echo -e "${GREEN}✓ Docker 可以正常运行 (docker ps 命令成功)${NC}"
            echo -e "\n${GREEN}=== Docker 已安装且可用 ===${NC}"
        else
            echo -e "${RED}✗ Docker 命令存在但无法正常运行${NC}"
            echo -e "\n${YELLOW}=== Docker 已安装但可能存在配置问题 ===${NC}"
        fi
    else
        echo -e "\n${RED}=== Docker 未安装 ===${NC}"
        
        # 询问是否自动安装Docker
        echo -e "${YELLOW}是否要自动安装Docker? (y/n)${NC}"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            install_docker
            
            # 安装后进行全面检查
            if check_docker_command; then
                echo -e "\n${YELLOW}=== 进行安装后完整检查 ===${NC}"
                
                # 检查版本
                check_docker_version
                
                # 检查服务状态
                if command -v systemctl &> /dev/null; then
                    # 启动Docker服务
                    echo "尝试启动Docker服务..."
                    sudo systemctl start docker 2>/dev/null
                    
                    check_docker_service
                else
                    echo -e "${YELLOW}! 系统不使用 systemd，跳过服务状态检查${NC}"
                fi
                
                # 检查权限
                check_docker_permission
                
                # 尝试运行
                if docker ps &> /dev/null; then
                    echo -e "${GREEN}✓ Docker 可以正常运行 (docker ps 命令成功)${NC}"
                    echo -e "\n${GREEN}=== Docker 安装完成并可用 ===${NC}"
                else
                    echo -e "${RED}✗ Docker 已安装但可能需要配置${NC}"
                    echo -e "\n${YELLOW}您可能需要将当前用户添加到docker组:${NC}"
                    echo "  sudo usermod -aG docker $USER"
                    echo "  (需要注销并重新登录才能生效)"
                fi
            else
                echo -e "\n${RED}=== 安装 Docker 失败 ===${NC}"
                echo -e "${YELLOW}建议手动安装:${NC}"
                echo "  - 请参考官方文档: https://docs.docker.com/engine/install/"
            fi
        else
            echo -e "${YELLOW}跳过安装。您可以手动安装 Docker:${NC}"
            echo "  - Debian/Ubuntu: sudo apt update && sudo apt install docker.io"
            echo "  - CentOS/RHEL: sudo yum install docker"
            echo "  - 或参考官方文档: https://docs.docker.com/engine/install/"
        fi
    fi
}

# 执行主函数
main