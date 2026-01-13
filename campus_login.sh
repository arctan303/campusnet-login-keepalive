#!/bin/sh

# =====================================================
# 使用方法:
#   ./campus_login.sh          # 默认 mobile
#   ./campus_login.sh mobile
#   ./campus_login.sh pc
# =====================================================

MODE=${1:-mobile}

BASE_URL="http://1.1.1.1:801/eportal/portal/login"

# ================= 读取配置文件 =================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.sh"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "错误: 未找到配置文件 config.sh"
    echo "请先运行 install.sh 或手动创建 config.sh"
    exit 1
fi

# 加载账号密码
. "$CONFIG_FILE"

# 基本校验
if [ -z "$ACCOUNT" ] || [ -z "$PASSWORD" ]; then
    echo "错误: config.sh 中未正确配置 ACCOUNT 或 PASSWORD"
    exit 1
fi

# ================= 模式参数配置 =================

# --- 移动端 / 手机模式 ---
MOBILE_TYPE="2"
MOBILE_V="3387"
MOBILE_UA="Mozilla/5.0 (Linux; Android 13; SM-S9080) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36"

# --- PC / 电脑模式 ---
PC_TYPE="1"
PC_V="7169"
PC_UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# ================= 逻辑处理 =================

case "$MODE" in
    pc)
        USER_ACCOUNT=",0,$ACCOUNT"
        TERMINAL_TYPE="$PC_TYPE"
        V_CODE="$PC_V"
        UA="$PC_UA"
        echo ">>> 正在执行 PC 模式登录..."
        ;;
    mobile|*)
        USER_ACCOUNT=",1,$ACCOUNT"
        TERMINAL_TYPE="$MOBILE_TYPE"
        V_CODE="$MOBILE_V"
        UA="$MOBILE_UA"
        echo ">>> 正在执行 移动 / 手机 模式登录..."
        ;;
esac

# ================= 获取本机 IP =================

CURRENT_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}')

if [ -z "$CURRENT_IP" ]; then
    echo "错误: 无法获取本机 IP，请检查网络连接"
    exit 1
fi

echo "    当前 IP: $CURRENT_IP"

# ================= 发送登录请求 =================

URL="${BASE_URL}?callback=dr1003\
&login_method=1\
&user_account=${USER_ACCOUNT}\
&user_password=${PASSWORD}\
&wlan_user_ip=${CURRENT_IP}\
&wlan_user_ipv6=\
&wlan_user_mac=000000000000\
&wlan_ac_ip=\
&wlan_ac_name=\
&jsVersion=4.2.1\
&terminal_type=${TERMINAL_TYPE}\
&lang=zh-cn\
&v=${V_CODE}"

RESULT=$(curl --user-agent "$UA" --connect-timeout 5 -s "$URL")

# ================= 结果判断 =================

if echo "$RESULT" | grep -qE '"result":"1"|"success"'; then
    echo ">>> 登录成功！"
    exit 0
else
    echo ">>> 登录失败，返回信息："
    echo "$RESULT"
    exit 1
fi
