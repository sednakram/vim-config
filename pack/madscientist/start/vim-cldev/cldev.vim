" -------------------------------------------------------------------------------
" Filename: cldev.vim
" Maintainer: mark.grzovic@gmail.com 
" Created: 2020-10-07 Wed 12:18 PM CDT
" Last Change: 2020-10-07 Wed 12:18 PM CDT
" Description: 
" -------------------------------------------------------------------------------

let s:save_cpo = &cpo
set cpo&vim

" Stop reading the script if the user does not want it loaded.
" See :help usr_41.txt and search for NOT LOADING
" Uncomment 'let' statement to disable the script
" let g:unload_pydev = 1
if exists("g:unload_cldev")
  finish
endif

" Check to see if plugin is already loaded. If it is reload the script.
" See :help usr_41.txt and search for PACKAGING
if exists("g:loaded_cldev")
  delfunction CLD_StartLispRepl
  delfunction CLD_StopLispRepl
  delfunction CLD_RestartLispRepl
  delcommand Sbcl
  delcommand RestartSbcl
endif
let g:loaded_cldev = 1

" ========== Local variables ==========
" Set the directory name for temporary files
let s:tmpdir = $HOME . "/.vim/tmp"
let s:wrkdir = $HOME . "/LispScripts"

" ========== Mappings ==========

" ========== Ex Commands ==========
" Start an SBCL REPL
command -nargs=? Sbcl call CLD_StartLispRepl(<args>)
command -nargs=? RestartSbcl call CLD_RestartLispRepl(<args>)

" ========== Functions ==========
function CLD_StartLispRepl(...)
  " Check to see if yakuake.vim is loaded
  if exists("g:loaded_yakuake")
    execute "Yrun \"sbcl\""
  else
    execute "silent !konsole --workdir" s:wrkdir "-e /bin/bash -c \"sbcl\" &"
  endif
endfunction

function CLD_StopLispRepl(...)
  if exists("g:loaded_yakuake")
    execute "Yrun \"(quit)\""
  else
    echom "ERROR: Stopping REPL through Vim is not supported."
  endif
endfunction

function CLD_RestartLispRepl(...)
  call CLD_StopLispRepl()
  call CLD_StartLispRepl()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
