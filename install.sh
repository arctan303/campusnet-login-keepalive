#!/bin/sh

# ========= 可配置参数 =========
INSTALL_DIR="/data/school_net"
REPO_URL="https://github.com/arctan303/campusnet-login-keepalive.git"
# ==============================

echo "[*] 创建目录 $INSTALL_DIR"
mkdir -p "$INSTALL_DIR" || exit 1

echo "[*] 下载项目..."
if command -v git >/dev/null 2>&1; then
    git clone "$REPO_URL" "$INSTALL_DIR"
else
    echo "[!] 未检测到 git，使用 wget 方式下载"
    wget -qO /tmp/campusnet.tar.gz \
        https://github.com/arctan303/campusnet-login-keepalive/archive/refs/heads/main.tar.gz \
        || exit 1
    tar -xzf /tmp/campusnet.tar.gz -C /tmp
    mv /tmp/campusnet-login-keepalive-main/* "$INSTALL_DIR"
fi

echo "[*] 设置执行权限"
chmod +x "$INSTALL_DIR"/*.sh

echo "[✓] 安装完成"
echo "    目录: $INSTALL_DIR"
echo "    登录脚本: campus_login.sh"
echo "    保活脚本: keepalive.sh"
