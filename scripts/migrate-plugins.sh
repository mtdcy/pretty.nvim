#!/bin/bash
# 从 pretty.nvim 迁移插件到 pretty.rebuild
# 按时间顺序迁移（从旧到新）

set -e

SRC_DIR="$HOME/workspace/pretty.nvim"
DST_DIR="$HOME/workspace/pretty.rebuild"

cd "$DST_DIR"

# 插件列表（按时间顺序：旧→新）
declare -a COMMITS=(
    "f79d1dcfd"  # nvim-notify
    "ad5f24c58"  # noice.nvim
    "c8968a283"  # vista.vim
    "6024a2243"  # nvim-cmp
    "6936e9e1b"  # cmp-omni
    "8e3a1ad50"  # cmp-buffer
    "c9cf1eaab"  # cmp-path
    "4737b7740"  # cmp-cmdline
    "e2c47e83f"  # cmp-rg
)

echo "🚀 开始迁移插件到 pretty.rebuild..."
echo ""

for commit in "${COMMITS[@]}"; do
    # 获取提交信息
    COMMIT_MSG=$(git -C "$SRC_DIR" log -1 --pretty=format:"%s" "$commit")
    
    echo "📦 $COMMIT_MSG"
    
    # 获取提交添加的文件列表
    FILES=$(git -C "$SRC_DIR" show "$commit" --name-only --pretty=format: | grep -v "^$" || true)
    
    if [ -z "$FILES" ]; then
        echo "  ⚠️  没有文件"
        continue
    fi
    
    # 复制每个文件
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            src_file="$SRC_DIR/$file"
            dst_file="$DST_DIR/$file"
            
            if [ -f "$src_file" ]; then
                # 创建目录
                mkdir -p "$(dirname "$dst_file")"
                cp "$src_file" "$dst_file"
                echo "  + $file"
            else
                echo "  ⚠️  文件不存在：$file"
            fi
        fi
    done <<< "$FILES"
    
    # 添加并提交
    git -C "$DST_DIR" add -A
    git -C "$DST_DIR" commit -m "$COMMIT_MSG" && echo "  ✅ 提交完成" || echo "  ⚠️  无变更"
    
    echo ""
done

echo "✅ 所有插件迁移完成！"
echo ""
echo "📊 迁移统计："
git -C "$DST_DIR" log --oneline | wc -l | xargs echo "  总提交数:"
