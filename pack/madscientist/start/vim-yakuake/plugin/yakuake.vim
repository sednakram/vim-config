" Filename: yakuake.vim
" Description: Script to add useful functions for code development.
" Maintainer: mark.grzovic@gmail.com 
" Created: 2020-04-03 Fri 02:57 PM CDT
" Last Change: 2020-04-06 Mon 10:27 AM CDT

let s:save_cpo = &cpo
set cpo&vim

" Uncomment 'let' statement to disable the script
" let g:unload_yakuake = 1
if exists("g:unload_yakuake")
  finish
endif

if exists("g:loaded_yakuake")
  delfunction YAK_SplitWindow
  delfunction YAK_GetTermIds
  delfunction YAK_RunCommand
  delcommand Ysplit
  delcommand Yrun
endif
let g:loaded_yakuake = 1

" ========== Local variables ==========
let s:pre = "qdbus org.kde.yakuake"
let s:sessid = system(s:pre . " /yakuake/sessions activeSessionId")

" ========== Mappings ==========

" ========== Ex Commands ==========
" Split terminal session horizontally or vertical
command -nargs=1 Ysplit call YAK_SplitWindow(<args>)
" Run command in another terminal
command -nargs=1 Yrun call YAK_RunCommand(<args>)

" ========== Functions ==========
" Split terminal session
function! YAK_SplitWindow(splittype)
  if a:splittype ==? "h"
    let l:cmd = "/yakuake/sessions org.kde.yakuake.splitSessionTopBottom"
  elseif a:splittype ==? "v"
    let l:cmd = "/yakuake/sessions org.kde.yakuake.splitSessionLeftRight"
  endif
  execute "silent !" . s:pre l:cmd s:sessid
endfunction

function! YAK_GetTermIds()
  let l:tmp = system(s:pre . " /yakuake/sessions org.kde.yakuake.terminalIdsForSessionId" . " " . s:sessid)
  let l:termids = strpart(l:tmp, 0, strlen(l:tmp)-1)
  let l:index = stridx(l:termids, ",")
  let s:term1 = strpart(l:termids, 0, l:index)
  let s:term2 = strpart(l:termids, l:index+1)
  echom "Term One:" s:term1
  echom "Term Two:" s:term2
endfunction

function! YAK_RunCommand(command)
  let l:tmp = system(s:pre . " /yakuake/sessions org.kde.yakuake.terminalIdsForSessionId" . " " . s:sessid)
  let l:termids = strpart(l:tmp, 0, strlen(l:tmp)-1)
  let l:index = stridx(l:termids, ",")
  let s:term1 = strpart(l:termids, 0, l:index)
  let s:term2 = strpart(l:termids, l:index+1)
  let l:curterm = system(s:pre . " /yakuake/sessions org.kde.yakuake.activeTerminalId")[:-2]
  if l:curterm ==? s:term1
    let l:cmd = s:pre . " /yakuake/sessions runCommandInTerminal " . s:term2 . " \"" . a:command . "\""
  elseif l:curterm ==? s:term2
    let l:cmd = s:pre . " /yakuake/sessions runCommandInTerminal " . s:term1 . " \"" . a:command . "\""
  endif
  call system(l:cmd)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
