#!/bin/sh

# ================= 基本配置 =================
INSTALL_DIR="/data/school_net"
REPO_RAW="https://raw.githubusercontent.com/arctan303/campusnet-login-keepalive/main"
LOGIN_SCRIPT="campus_login.sh"
KEEPALIVE_SCRIPT="keepalive.sh"
CONFIG_FILE="config.sh"
LOG_FILE="/tmp/campus_login.log"
# ===========================================

print_header() {
    echo "========================================="
    echo " 广州热点校园网自动登录脚本 管理工具"
    echo "========================================="
}

download() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1" -o "$2"
    else
        wget -q "$1" -O "$2"
    fi
}

ensure_dir() {
    mkdir -p "$INSTALL_DIR" || {
        echo "创建目录失败: $INSTALL_DIR"
        exit 1
    }
    cd "$INSTALL_DIR" || exit 1
}

fix_scripts() {
    # 修复 CRLF（Windows 换行符）并设置执行权限（必做）
    sed -i 's/\r$//' "$INSTALL_DIR/$LOGIN_SCRIPT"
    sed -i 's/\r$//' "$INSTALL_DIR/$KEEPALIVE_SCRIPT"
    chmod +x "$INSTALL_DIR/$LOGIN_SCRIPT" "$INSTALL_DIR/$KEEPALIVE_SCRIPT"
}

write_config() {
    read -p "请输入校园网账号: " CAMPUS_USER
    read -s -p "请输入校园网密码: " CAMPUS_PASS
    echo
    read -p "请选择登录类型 (mobile/pc) [mobile]: " CAMPUS_MODE
    echo

    if [ -z "$CAMPUS_MODE" ]; then
        CAMPUS_MODE="mobile"
    fi
    if [ "$CAMPUS_MODE" != "mobile" ] && [ "$CAMPUS_MODE" != "pc" ]; then
        echo "登录类型输入不正确，已使用默认 mobile"
        CAMPUS_MODE="mobile"
    fi

    cat > "$INSTALL_DIR/$CONFIG_FILE" <<EOF
# 校园网账号配置
ACCOUNT="$CAMPUS_USER"
PASSWORD="$CAMPUS_PASS"
# 登录模式: mobile 或 pc
LOGIN_MODE="$CAMPUS_MODE"
EOF
    chmod 600 "$INSTALL_DIR/$CONFIG_FILE"
}

install_all() {
    echo "[1/4] 创建安装目录: $INSTALL_DIR"
    ensure_dir

    echo "[2/4] 下载脚本文件..."
    download "$REPO_RAW/$LOGIN_SCRIPT" "$LOGIN_SCRIPT" || exit 1
    download "$REPO_RAW/$KEEPALIVE_SCRIPT" "$KEEPALIVE_SCRIPT" || exit 1

    echo "[3/4] 修复脚本格式并设置权限"
    fix_scripts

    echo "[4/4] 配置校园网账号信息"
    write_config

    echo
    echo "========================================="
    echo " 安装完成"
    echo "-----------------------------------------"
    echo " 安装目录: $INSTALL_DIR"
    echo " 登录脚本: $INSTALL_DIR/$LOGIN_SCRIPT"
    echo " 保活脚本: $INSTALL_DIR/$KEEPALIVE_SCRIPT"
    echo " 配置文件: $INSTALL_DIR/$CONFIG_FILE"
    echo " 日志文件: $LOG_FILE"
    echo "========================================="
}

update_config() {
    if [ ! -d "$INSTALL_DIR" ]; then
        echo "未找到安装目录: $INSTALL_DIR"
        exit 1
    fi
    echo "修改配置文件: $INSTALL_DIR/$CONFIG_FILE"
    write_config
    echo "配置已更新"
}

test_login() {
    if [ ! -f "$INSTALL_DIR/$LOGIN_SCRIPT" ]; then
        echo "找不到登录脚本: $INSTALL_DIR/$LOGIN_SCRIPT"
        exit 1
    fi
    read -p "请选择测试登录类型 (mobile/pc) [mobile]: " TEST_MODE
    if [ -z "$TEST_MODE" ]; then
        TEST_MODE="mobile"
    fi
    if [ "$TEST_MODE" != "mobile" ] && [ "$TEST_MODE" != "pc" ]; then
        echo "登录类型输入不正确，已使用默认 mobile"
        TEST_MODE="mobile"
    fi
    /bin/sh "$INSTALL_DIR/$LOGIN_SCRIPT" "$TEST_MODE"
}

run_logs() {
    if [ -f "$INSTALL_DIR/$KEEPALIVE_SCRIPT" ]; then
        /bin/sh "$INSTALL_DIR/$KEEPALIVE_SCRIPT"
    else
        echo "找不到保活脚本: $INSTALL_DIR/$KEEPALIVE_SCRIPT"
    fi
    echo "开始观察日志: $LOG_FILE (按 Ctrl+C 退出)"
    tail -f "$LOG_FILE"
}

print_header
echo "请选择操作:"
echo "1) 一键安装"
echo "2) 修改配置"
echo "3) 测试登录"
echo "4) 运行日志"
echo

read -p "输入序号 [1-4]: " CHOICE
case "$CHOICE" in
    1) install_all ;;
    2) update_config ;;
    3) test_login ;;
    4) run_logs ;;
    *) echo "无效选择，已退出" ;;
esac
