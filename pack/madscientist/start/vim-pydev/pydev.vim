" Filename: pydev.vim
" Description: Useful functions for Python development
" Maintainer: mark.grzovic@gmail.com 
" Created: 2020-03-23 Mon 09:27 AM CDT
" Last Change: 2020-03-26 Thu 08:38 AM CDT

let s:save_cpo = &cpo
set cpo&vim

" Stop reading the script if the user does not want it loaded.
" See :help usr_41.txt and search for NOT LOADING
" Uncomment 'let' statement to disable the script
" let g:unload_pydev = 1
if exists("g:unload_pydev")
  finish
endif

" Check to see if plugin is already loaded. If it is reload the script.
" See :help usr_41.txt and search for PACKAGING
if exists("g:loaded_pydev")
  delfunction PYD_DocString
"   delfunction PYD_RunPyCode
  delfunction PYD_RunPyFile
"   delfunction PYD_StartIPyInterp
  delfunction PYD_SetEnv
"   delcommand Ipython
  delcommand SetEnv
endif
let g:loaded_pydev = 1

" ========== Local variables ==========
" Set the directory name for temporary files
let s:tmpdir = $HOME . "/.vim/tmp"
let s:envdir = $HOME . "/PythonScripts/environments"

" ========== Mappings ==========
" Add documentation string
nnoremap <localleader>d :call PYD_DocString()<cr>
" Run current file through interpreter
nnoremap <f5> :call PYD_RunPyFile()<cr>

" ========== Ex Commands ==========
" Activate python environment
command -nargs=1 SetEnv call PYD_SetEnv(<args>)

" ========== Functions ==========
function! PYD_DocString()
  let l:fname = expand("%:t")
  execute "normal! 3i\""
  execute "normal! o"
  execute "normal! 79i-"
  execute "normal! oFilename:" l:fname . "\r"
  execute "normal iMaintainer: @@\r"
  execute "normal iCreated: ttime\r"
  execute "normal iLast Change: ttime\r"
  execute "normal! oDescription: \r"
  execute "normal! mx"
  execute "normal! oInputs: \r- None\r"
  execute "normal! oOutputs: \r- None\r"
  execute "normal! oNotes: \r- None\r"
  execute "normal! 79i-"
  execute "normal! o"
  execute "normal! 3i\""
  execute "normal! 'xk2e"
endfunction

function! PYD_RunPyFile()
  " Save user shell variables
  let l:save_shell = &shell
  let l:save_shellpipe = &shellpipe
  let l:save_shellcmdflag = &shellcmdflag
  let l:save_shellxquote = &shellxquote
  let l:save_shellslash = &shellslash
  " Set shell variables we need to execute function
  set shell&vim
  set shellpipe&vim
  set shellcmdflag&vim
  set shellxquote&vim
  set shellslash&vim
  " Set filename, window number, and log filename
  let l:winnr = winnr()
  if has("gui_win32") || has("gui_win64")
    let l:fname = substitute(expand("%:p"), "/", "\\", "")
    let l:output = s:tmpdir . "\\" . strftime("%Y%m%d") . "_output.log"
  else
    let l:fname = expand("%:p")
    let l:output = s:tmpdir . "/" . strftime("%Y%m%d") . "_output.log"
  endif
  " Open log file if it is not already open
  if bufloaded(l:output)
    execute "wincmd l"
  else
    execute "vsplit" l:output
  endif
  " Append separation block
  execute "normal! Go\r"
  execute "normal! 79i="
  execute "normal! oDate: "
  execute "normal Attime\r"
  execute "normal! 79i-"
  execute "normal! o"
  execute "normal! oInput: runfile(" l:fname ")\r"
  " Run code and write output to log file
  if exists("g:envname")
    let l:cmd1 = 'source ' . s:envdir . "/" . g:envname . "/bin/activate"
    let l:cmd2 = 'ipython ' . l:fname
    let l:cmd = l:cmd1 . '; ' . l:cmd2
    echom l:cmd1
    echom l:cmd2
    echom l:cmd
    " Activate the environment; then run code
"     silent let l:stdout = systemlist(l:cmd)
    silent let l:stdout = system(l:cmd)
    let l:index = stridx(strtrans(l:stdout), '^G')-1
    let @f = strpart(l:stdout, l:index)
    execute "put f"
    execute "?Input"
    execute "normal! 2j"
    execute "normal! 5dd"
  else
    echom "ERROR: environment is not set."
  endif
  " Make the original buffer window the active window
  execute l:winnr . "wincmd w"
  " Reset shell variables to user settings
  let &shell = l:save_shell
  let &shellpipe = l:save_shellpipe
  let &shellcmdflag = l:save_shellcmdflag
  let &shellxquote = l:save_shellxquote
  let &shellslash = l:save_shellslash
endfunction

function! PYD_SetEnv(envname)
  " Set environment variable
  let g:envname = a:envname
  echom "Python environment set to:" g:envname
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
