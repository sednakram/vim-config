" Filename: pydev.vim
" Description: Useful functions for Python development
" Maintainer: mark.grzovic@gmail.com 
" Created: 2020-03-23 Mon 09:27 AM CDT
" Last Change: 2020-10-30 Fri 03:23 PM CDT

let s:save_cpo = &cpo
set cpo&vim

" Stop reading the script if Vim does not have a terminal
if !has("terminal")
  echom "Terminal is disabled. Pydev is not available."
  finish
endif

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
  delfunction PYD_PythonFile_docstring
  delfunction PYD_IPythonRepl_runline
  delfunction PYD_IPythonRepl_runblock
  delfunction PYD_IPythonRepl_runfile
  delfunction PYD_IPythonRepl_setenv
  delfunction PYD_IPythonRepl_start
  delfunction PYD_IPythonRepl_stop
  delfunction PYD_IPythonRepl_restart
  delcommand SetEnv
  delcommand Ipython
  delcommand StartIpython
  delcommand RestartIpython
endif
let g:loaded_pydev = 1

" ========== Local variables ==========
" Set the directory name for temporary files
let s:tmpdir = $HOME . "/.vim/tmp"
let s:envdir = $HOME . "/PythonScripts/environments"
let s:term = "IPython"

" ========== Mappings ==========
" Add documentation string
nnoremap <localleader>d :call PYD_PythonFile_docstring()<cr>
" Run current file through interpreter
nnoremap <f5> :call PYD_IPythonRepl_runfile()<cr>
" Run one line through interpreter
nnoremap <f9> :call PYD_IPythonRepl_runline()<cr>

" ========== Ex Commands ==========
" Activate python environment
command -nargs=1 SetEnv call PYD_IPythonRepl_setenv(<args>)
" Start an IPython interpreter
command -nargs=? StartIpython call PYD_IPythonRepl_start(<args>)
" Restart IPython REPL
command -nargs=? RestartIpython call PYD_IPythonRepl_restart(<args>)
" Run one or more lines of code
command -nargs=? -range Ipython <line1>,<line2>call PYD_IPythonRepl_runblock(<args>)

" ========== Functions ==========
" Python file functions {{{
function PYD_PythonFile_docstring()
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
" }}}


" IPython REPL functions {{{

" Set the python environment
function PYD_IPythonRepl_setenv(envname)
  " TODO: 2020-10-29 Thu 01:31 PM CDT
  " TODO: check if environment exists on system
  " Set environment variable
  let g:envname = a:envname
  echom "Python environment set to:" g:envname
endfunction

" Build the command for opening Bash terminalIPython REPL
function PYD_BuildTermCommandFor_python(...)
  return {"command": ["bash", "--login"],
    \ "options": {"term_name": s:term, "vertical": 1, "norestore": 1}
    \ }
endfunction

" Start the IPython REPL
function PYD_IPythonRepl_start(...)
  if exists("g:envname")
    " TODO: 2020-10-30 Fri 02:23 PM CDT
    " TODO: Replace with term_getstatus()
    " Get current window number
    let l:winnr = winnr()
    let l:cmd = join(["source ", s:envdir, "/", g:envname, "/bin/activate\<cr>"], "")
    if exists("g:ipython_repl_running")
      " Activate the python environment
      call term_sendkeys(buffer_number(s:term), l:cmd)
      " Start the IPython REPL
      call term_sendkeys(buffer_number(s:term),
        \ "ipython --matplotlib=tk\<cr>")
    else
      let l:pyd = PYD_BuildTermCommandFor_python()
      " Start the bash terminal
      call term_start(l:pyd.command, l:pyd.options)
      " Activate the python environment
      " if it is one string it works???
      call term_sendkeys(buffer_number(s:term), l:cmd)
      " Start the IPython REPL
      call term_sendkeys(buffer_number(s:term),
        \ "ipython --matplotlib=tk\<cr>")
      let g:ipython_repl_running = 1
    endif
    execute l:winnr . "wincmd w"
  else
    echom "ERROR: environment is not set."
  endif
endfunction

" Stop the IPython REPL
function PYD_IPythonRepl_stop(...)
  if exists("g:ipython_repl_running")
    " Exit IPython
    call term_sendkeys(buffer_number(s:term),
      \ "quit()\<cr>")
    " Deactivate the environment
    call term_sendkeys(buffer_number(s:term),
      \ "deactivate\<cr>")
  else
    echom "ERROR: IPython REPL is not running."
  endif
endfunction

" Restart the IPython REPL
function PYD_IPythonRepl_restart(...)
  call PYD_IPythonRepl_stop()
  call PYD_IPythonRepl_start()
endfunction
" }}}


" Run Python code {{{

" Run one line through IPython REPL using <f9>
" TODO: 2020-10-29 Thu 08:10 PM CDT
" TODO: make sure terminal is in insert mode
" See :h term_getstatus()
function PYD_IPythonRepl_runline(...)
  let l:linenum = getcurpos()[1]
  let l:line = getline(l:linenum)
  if exists("g:envname")
    " Check to see if the Ipython interpreter is started
    if exists("g:ipython_repl_running")
      call term_sendkeys(buffer_number(s:term),
        \ l:line . "\<cr>")
    else
      call PYD_IPythonRepl_start()
      call term_sendkeys(buffer_number(s:term),
        \ l:line . "\<cr>")
    endif
  else
    echom "ERROR: Python environment is not set."
  endif
endfunction

" Run several lines of code
" usage - :44,45Ipython
"         :Ipython
"         :.,$Ipython
function PYD_IPythonRepl_runblock(...) range abort
  if exists("g:envname")
    " Check to see if the Ipython interpreter is started
    if exists("g:ipython_repl_running")
      execute a:firstline . "," . a:lastline . "yank p"
      call term_sendkeys(buffer_number(s:term),
        \ @p . "\<cr>")
    else
      call PYD_IPythonRepl_start()
      execute a:firstline . "," . a:lastline . "yank p"
      call term_sendkeys(buffer_number(s:term),
        \ @p . "\<cr>")
    endif
  else
    echom "ERROR: Python environment is not set."
  endif
endfunction

" Run the entire python file
function PYD_IPythonRepl_runfile(...)
  execute "%call PYD_IPythonRepl_runblock()"
endfunction
" }}}

let &cpo = s:save_cpo
unlet s:save_cpo
