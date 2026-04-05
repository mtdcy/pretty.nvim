#!/usr/bin/env bash
# vim:ft=bash
# ==============================================================================
# nvim-helpers.sh - Neovim 辅助服务
# ==============================================================================
# 为 Neovim 提供辅助功能的后台服务：
# - 输入法切换 (im-select)
# - 剪贴板同步 (pbcopy)
#
# 用法：启动此脚本运行辅助服务，监听 18643 端口
# 服务通过 netcat 接收命令并处理
# ==============================================================================

set -eo pipefail

# 确保 UTF-8 编码
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 运行时目录和端口配置
: "${XDG_RUNTIME_DIR:=$(getconf DARWIN_USER_TEMP_DIR)}"
: "${NVIM_HELPER_PORT:=18643}"

# PID 文件、日志文件、输入法状态文件
NVIM_HELPER_PIDFILE="$XDG_RUNTIME_DIR/nvim.helpers.pid"
NVIM_HELPER_LOGFILE="$XDG_RUNTIME_DIR/nvim.helpers.log"
NVIM_HELPER_ABCFILE="$XDG_RUNTIME_DIR/nvim.helpers.abc.txt"

# 验证 NVIM_HOME 环境变量已设置
test -n "$NVIM_HOME" || {
    echo "❌ NVIM_HOME not set"
    exit 1
}

# 重定向标准输出和错误到日志文件
exec 1> >(tee -a "$NVIM_HELPER_LOGFILE") 2>&1

# 平台特定的剪贴板和 netcat 配置
if [ "$(uname)" = "Darwin" ]; then
    pbcopy="pbcopy"  # macOS 原生剪贴板
    # 使用系统 netcat 监听辅助端口
    netcat="/usr/bin/nc -l $NVIM_HELPER_PORT"
else
    pbcopy="xclip -selection clipboard -encoding UTF-8"  # Linux 通过 xclip 剪贴板
    netcat="nc -l $NVIM_HELPER_PORT"
fi

# 检查服务是否已运行（PID 文件存在且进程存活）
if test -f "$NVIM_HELPER_PIDFILE"; then
    if xargs ps -p $(cat "$NVIM_HELPER_PIDFILE"); then
        echo "💡 nvim.helpers has started"
        exit
    fi
fi

# 启动辅助服务
echo "✅ start nvim.helpers $$ @ $NVIM_HELPER_PORT"

# 注册退出清理处理器，移除 PID 文件
trap 'rm -f $NVIM_HELPER_PIDFILE' EXIT
# 写入当前进程 PID 到文件
echo "$$" > "$NVIM_HELPER_PIDFILE"

# 在 ABC 和之前的输入法布局之间切换
# 注意：目前仅支持 macOS (im-select 工具)
do_im_switch() {
    # TODO: 添加 Linux 输入法支持
    im_switch="im-select"
    case "$*" in
        # 切换到 ABC 布局并保存当前布局
        abc=true)
	    "$im_switch" > "$NVIM_HELPER_ABCFILE"
            "$im_switch" "com.apple.keylayout.ABC"
	    echo "💡 $(cat "$NVIM_HELPER_ABCFILE") => $($im_switch)"
            ;;
        # 恢复之前的输入法布局
        *)
	    "$im_switch" "$(cat "$NVIM_HELPER_ABCFILE")"
	    echo "✅ $(cat "$NVIM_HELPER_ABCFILE")"
            ;;
    esac
}

# 处理来自 netcat 的输入命令
# 格式：<命令类型>:<上下文>
do_process() {
    IFS=':' read -r kind context
    
    echo "✅ $kind: [$context]"

    case "$kind" in
        # 处理输入法切换
        "im-select")
            do_im_switch "$context"
            ;;
        # 处理剪贴板复制
        "pbcopy")
            echo "$context" | "$pbcopy"
            ;;
        # 默认：复制 命令类型：上下文 到剪贴板
        *)
            echo "$kind:$context" | "$pbcopy"
            ;;
    esac
}

# 主服务循环：持续监听命令并处理
while true; do
    eval "$netcat" | do_process || {
        echo "❌ nvim.helpers failed, exit"
        exit 1
    }
done
