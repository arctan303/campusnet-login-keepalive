# campusnet-login-keepalive
广州热点校园网（ePortal）自动登录与断网重连脚本，适用于路由器和 Linux。

项目地址: https://github.com/arctan303/campusnet-login-keepalive

## 功能
- 自动登录校园网（移动/PC 两种模式）
- 断网检测与自动重连
- 轻量脚本，适合路由器定时保活

## 目录结构
- `campus_login.sh`: 登录脚本
- `keepalive.sh`: 断网检测与重连脚本
- `install.sh`: 一键安装与管理
- `config.example.sh`: 配置模板

## 安装与配置
推荐使用一键安装脚本（交互式）：

```sh
sh install.sh
```

安装脚本提供 4 个选项：
1) 一键安装（下载脚本 + 修复格式 + 设置权限 + 写入配置）
2) 修改配置（修改账号、密码、登录模式）
3) 测试登录（选择 mobile 或 pc）
4) 运行日志（执行保活并跟踪日志）

## 手动配置（可选）
复制并编辑配置文件：

```sh
cp config.example.sh config.sh
```

配置字段说明（`config.sh`）：
- `ACCOUNT`: 校园网账号
- `PASSWORD`: 校园网密码
- `LOGIN_MODE`: 默认登录模式（`mobile` 或 `pc`）

## 使用说明
手动登录：

```sh
./campus_login.sh mobile
./campus_login.sh pc
```

运行保活：

```sh
./keepalive.sh
```

查看日志（只有断线时才会有日志）：

```sh
tail -f /tmp/campus_login.log
```

## 定时保活（可选）
例如每分钟检测一次：

```sh
crontab -e
```

```
* * * * * sh /data/school_net/keepalive.sh
```

## 注意事项
- 路由器环境建议使用 `/data/school_net` 作为持久化目录
- 如果脚本来自 Windows 环境，请先执行格式修复（必做）：

```sh
sed -i 's/\r$//' /data/school_net/campus_login.sh
chmod +x /data/school_net/campus_login.sh
```
