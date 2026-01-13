#!/bin/sh

# ================= 基本配置 =================
INSTALL_DIR="/data/school_net"
REPO_RAW="https://raw.githubusercontent.com/arctan303/campusnet-login-keepalive/main"
LOGIN_SCRIPT="campus_login.sh"
KEEPALIVE_SCRIPT="keepalive.sh"
CONFIG_FILE="config.sh"
# ===========================================

echo "========================================="
echo " 广州热点校园网自动登录脚本 安装程序"
echo "========================================="

# 1. 创建目录
echo "[1/5] 创建安装目录: $INSTALL_DIR"
mkdir -p "$INSTALL_DIR" || {
    echo "创建目录失败"
    exit 1
}

cd "$INSTALL_DIR" || exit 1

# 2. 下载脚本
echo "[2/5] 下载脚本文件..."

download() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1" -o "$2"
    else
        wget -q "$1" -O "$2"
    fi
}

download "$REPO_RAW/$LOGIN_SCRIPT" "$LOGIN_SCRIPT" || exit 1
download "$REPO_RAW/$KEEPALIVE_SCRIPT" "$KEEPALIVE_SCRIPT" || exit 1

# 3. 修复 CRLF（Windows 换行符）
echo "[3/5] 修复脚本格式（CRLF -> LF）"
sed -i 's/\r$//' "$LOGIN_SCRIPT"
sed -i 's/\r$//' "$KEEPALIVE_SCRIPT"

# 4. 设置执行权限
echo "[4/5] 设置执行权限"
chmod +x "$LOGIN_SCRIPT" "$KEEPALIVE_SCRIPT"

# 5. 生成配置文件
echo "[5/5] 配置校园网账号信息"
echo

read -p "请输入校园网账号: " CAMPUS_USER
read -s -p "请输入校园网密码: " CAMPUS_PASS
echo

cat > "$CONFIG_FILE" <<EOF
# 校园网账号配置
ACCOUNT=",1,$CAMPUS_USER"
PASSWORD="$CAMPUS_PASS"
EOF

chmod 600 "$CONFIG_FILE"

echo
echo "========================================="
echo " 安装完成 ✅"
echo "-----------------------------------------"
echo " 安装目录: $INSTALL_DIR"
echo " 登录脚本: ./$LOGIN_SCRIPT"
echo " 保活脚本: ./$KEEPALIVE_SCRIPT"
echo " 配置文件: ./$CONFIG_FILE"
echo
echo " 示例："
echo "   手动登录: ./$LOGIN_SCRIPT"
echo "   定时保活: crontab -e"
echo "   * * * * * sh $INSTALL_DIR/$KEEPALIVE_SCRIPT"
echo "========================================="
