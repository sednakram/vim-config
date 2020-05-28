" Filename: pydev.vim
" Description: Useful functions for Python development
" Maintainer: mark.grzovic@gmail.com 
" Created: 2020-03-23 Mon 09:27 AM CDT
" Last Change: 2020-04-10 Fri 10:55 AM CDT

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
  delfunction PYD_RunPyLine
  delfunction PYD_RunPyLines
  delfunction PYD_RunPyFile
  delfunction PYD_StartIPyInterp
  delfunction PYD_SetEnv
  delcommand Ipython
  delcommand SetEnv
  delcommand Rpython
endif
let g:loaded_pydev = 1

" NEW Functionality
" TODO: 2020-03-30 Mon 07:38 AM CDT
" TODO: Write function to run a 'cell' of code when <shift-cr> is pressed.
"   Ex: a 'cell' is denoted by #%%
" Yrun=> for item in range(10):\nprint('An iteration!')\n
" getline(lnum, end) list
" get(list, idx)
" get(list, idx1) . '\n' . get(list, idx2) . '\n'
" TODO: 2020-03-30 Mon 07:42 AM CDT
" TODO: Write an Ex command for running Python code.
"   Ex: :Python --> run current line
"   Ex: :%Python --> run the entire file
"   Ex: :12,15Python --> run lines 12 to 15
"   Ex: :.,$Python --> run from current line to the end of the file
"   Ex: :Python 20 --> run 20 lines starting with the current line
"   Ex: :5Python 10 --> run 10 lines starting with line 5
" I would like the same instance of the interpreter so I could keep the same
" variables loaded. Important things to keep in the interpreter: imports,
" variables, functions, classes.
" As an alternative I could create a temporary file that
" would contain every line of code run. And if line 12 is reran after editing
" the function would write over line 12 in temporary file.

" ========== Local variables ==========
" Set the directory name for temporary files
let s:tmpdir = $HOME . "/.vim/tmp"
let s:envdir = $HOME . "/PythonScripts/environments"

" ========== Mappings ==========
" Add documentation string
nnoremap <localleader>d :call PYD_DocString()<cr>
" Run current file through interpreter
nnoremap <f5> :call PYD_RunPyFile()<cr>
" Run one line through interpreter
nnoremap <f9> :call PYD_RunPyLine()<cr>

" ========== Ex Commands ==========
" Activate python environment
command -nargs=1 SetEnv call PYD_SetEnv(<args>)
" Start an IPython interpreter
command -nargs=? Ipython call PYD_StartIPyInterp(<args>)
" Run one or more lines of code
command -nargs=? -range Rpython <line1>,<line2>call PYD_RunPyLines(<args>)

" ========== Functions ==========
function PYD_DocString()
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

function PYD_RunPyFile()
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
  let l:fname = expand("%:p")
  let l:output = s:tmpdir . "/" . strftime("%Y%m%d") . "_output.log"
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
    let l:cmd1 = "source " . s:envdir . "/" . g:envname . "/bin/activate"
    let l:cmd2 = "ipython --colors=\'NoColor\' " . l:fname
    let l:cmd = l:cmd1 . '; ' . l:cmd2
    " Activate the environment; then run code
    execute "$read !" . l:cmd
"     silent let l:stdout = system(l:cmd)
"     let l:index = stridx(strtrans(l:stdout), '^G')-1
"     let @f = strpart(l:stdout, l:index)
"     execute "put f"
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

function PYD_RunPyLine()
  let l:linenum = getcurpos()[1]
  let l:line = getline(l:linenum)
  if exists("g:envname")
    " Check to see if the Ipython interpreter is started
    if exists("g:loaded_ipython")
      Yrun l:line
    else
      call PYD_StartIPyInterp()
      Yrun l:line
    endif
  else
    echom "ERROR: environment is not set."
  endif
endfunction

function PYD_RunPyLines(...) range abort
  let l:lines = getline(a:firstline, a:lastline)
  let l:cmd = ''
  echom a:firstline . ' ' . get(l:lines, 0)
  for n in l:lines
    if len(l:lines) == 1
      let l:cmd = l:cmd . n
      break
    else
      let l:cmd = l:cmd . n . '\n'
    endif
  endfor
  echom l:cmd
  if exists("g:envname")
    " Check to see if the Ipython interpreter is started
    if exists("g:loaded_ipython")
      Yrun l:cmd
    else
      call PYD_StartIPyInterp()
      Yrun l:cmd
    endif
  else
    echom "ERROR: environment is not set."
  endif
endfunction

function PYD_SetEnv(envname)
  " Set environment variable
  let g:envname = a:envname
  echom "Python environment set to:" g:envname
endfunction

function PYD_StartIPyInterp(...)
  if exists("g:envname")
    " Check to see if yakuake.vim is loaded
    if exists("g:loaded_yakuake")
      if exists("a:1")
        execute "Yrun \"source " . s:envdir . "/" . g:envname . "/bin/activate; ipython -i --matplotlib=tk " . a:1 . "\""
      else
        execute "Yrun \"source " . s:envdir . "/" . g:envname . "/bin/activate; ipython --matplotlib=tk\""
      endif
      let g:loaded_ipython = 1
    else
      let l:cmd = "source " . s:envdir . "/" . g:envname . "/bin/activate; ipython"
      execute "silent !konsole --workdir " . s:envdir . " -e /bin/bash -c \"" . l:cmd . "\" &"
    endif
  else
    echom "ERROR: environment is not set."
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
