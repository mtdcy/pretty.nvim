" =============================================================================
" pretty.nvim - 主配置文件
" =============================================================================
" 作者：Chen Fang (mtdcy.chen@gmail.com)
" 版权：2023 (c) Chen Fang
" 说明：pretty.nvim 的入口文件，负责加载所有模块配置
" =============================================================================

" =============================================================================
" 基础设置 (Minimal Setup)
" =============================================================================

" Leader 键设置为分号
let mapleader = ';'

" 不备份文件
set nobackup
set nowritebackup

" 切换 buffer 时不提示保存（隐藏 buffer）
set hidden

" 禁用 Vi 兼容模式（启用 Vim 增强功能）
set nocompatible

" 在屏幕底部显示命令
set showcmd

" 设置 backspace 键行为（可删除缩进、换行符、起始位置）
set backspace=indent,eol,start

" 禁用括号匹配高亮（避免干扰）
set noshowmatch

" 搜索选项
set hlsearch          " 高亮搜索词
set incsearch         " 增量搜索（实时显示匹配）
set smartcase         " 智能大小写（有大写字母时区分大小写）

" 更新频率（毫秒），影响插件响应速度
set updatetime=200

" =============================================================================
" 加载初始化模块
" =============================================================================
" 按顺序加载各个功能模块

" 通用设置（路径、环境变量、工具函数） - 第一个加载
source <sfile>:h/init/common.vim

" UI 配置（主题、界面优化）
source <sfile>:h/init/ui.vim

" 窗口管理（窗口分割、导航）
source <sfile>:h/init/windows.vim

" LSP 配置（nvim-lspconfig or ale）
source <sfile>:h/init/ale.vim

" 补全配置（deoplete、neosnippet）
source <sfile>:h/init/cmp.lua

" AI 集成（CodeCompanion）

" 文件搜索（Finder - Lua）
source <sfile>:h/init/finder.lua

" 美化
source <sfile>:h/init/cmdline.lua

" =============================================================================
" 快捷键配置
" =============================================================================

" 编辑配置文件
nnoremap <leader>se :edit $MYVIMRC<cr>

" 重载配置文件并执行刷新操作
nnoremap <leader>ss :source $MYVIMRC<cr>:if exists('*PrettyReload') \| call PrettyReload() \| endif<cr>
