
augroup events
    autocmd!

    " window events
    autocmd VimEnter     * echom "== VimEnter"      . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd VimLeave     * echom "== VimLeave"      . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd VimLeavePre  * echom "== VimLeavePre"   . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd ExitPre      * echom "== ExitPre"       . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd QuitPre      * echom "== QuitPre"       . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd WinEnter     * echom "== WinEnter "     . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd WinLeave     * echom "== WinLeave "     . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd WinNew       * echom "== WinNew "       . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd WinClosed    * echom "== WinClosed "    . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')

    " buffer events
    autocmd BufNew       * echom "== BufNew "       . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufAdd       * echom "== BufAdd "       . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufEnter     * echom "== BufEnter "     . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufLeave     * echom "== BufLeave "     . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufRead      * echom "== BufRead "      . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufReadPre   * echom "== BufReadPre "   . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufReadPost  * echom "== BufReadPost "  . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufWrite     * echom "== BufWrite "     . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufWritePre  * echom "== BufWritePre "  . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufWritePost * echom "== BufWritePost " . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufDelete    * echom "== BufDelete "    . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufUnload    * echom "== BufUnload "    . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufWipeout   * echom "== BufWipeout "   . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufHidden    * echom "== BufHidden "    . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufNewFile   * echom "== BufNewFile "   . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufFilePre   * echom "== BufFilePre "   . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufFilePost  * echom "== BufFilePost "  . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')

    autocmd BufWinEnter  * echom "== BufWinEnter "  . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')
    autocmd BufWinLeave  * echom "== BufWinLeave "  . ' amatch:' . expand('<amatch>') . ' afile:' . expand('<afile>')

    " block other events, why
    "autocmd BufWriteCmd  * echom "== BufWriteCmd "  . bufname()
    "autocmd BufReadCmd   * echom "== BufReadCmd "   . bufname()
augroup END
