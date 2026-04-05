#!/usr/bin/env bash
# vim:ft=bash
# ==============================================================================
# nclients.sh - Neovim 远程客户端
# ==============================================================================
# 将远程 Neovim 会话的文本发送到本地剪贴板/辅助服务
# 用于 SSH 或远程场景下同步剪贴板操作
#
# 用法：nclients.sh <命令> [参数...]
# 命令:
#   im-select  - 切换输入法
#   pbcopy     - 复制文本到剪贴板
#   <默认>     - 复制参数到剪贴板
# ==============================================================================

set -eo pipefail

# 确保 UTF-8 编码
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 运行时目录和辅助服务端口
: "${XDG_RUNTIME_DIR:=$(getconf DARWIN_USER_TEMP_DIR)}"
: "${NVIM_HELPER_PORT:=18643}"

# 重定向输出到客户端日志文件
exec 1> >(tee -a "$XDG_RUNTIME_DIR/nvim.clients.log") 2>&1

# 验证 NVIM_HOME 环境变量已设置
test -n "$NVIM_HOME" || {
    echo "❌ NVIM_HOME not set"
    exit 1
}

# 确定目标客户端地址
# 如果设置了 SSH_SOCKET 或不是通过 SSH 运行，使用 localhost
# 否则从 SSH_CLIENT 环境变量提取客户端 IP
# 注意：SSH_SOCKET 在 nsshc.sh 中配置
if test -n "$SSH_SOCKET" || test -z "$SSH_CLIENT"; then
    client=localhost
else
    IFS=' ' read -r client _ <<< "$SSH_CLIENT"
fi

echo "💡 nclients => $client $NVIM_HELPER_PORT: $*"

socat="$NVIM_HOME/prebuilts/bin/socat - TCP:$client:$NVIM_HELPER_PORT"

# 根据命令类型构建命令负载
case "$1" in
    # 输入法切换 - 带命令前缀传递
    "im-select")
        printf '%s:%s' "$1" "${@:2}"
        ;;
    # 剪贴板复制 - 处理标准输入 (-) 或参数
    "pbcopy")
        if [ "$2" == "-" ]; then
            printf 'pbcopy:%s' "$(cat)"
        else
            printf 'pbcopy:%s' "${@:2}"
        fi
        ;;
    # 默认：复制所有参数到远程剪贴板
    *)
        printf 'pbcopy:%s' "$@"
        ;;
esac | eval "$socat" & disown
# 脱离后台进程，立即返回不等待
