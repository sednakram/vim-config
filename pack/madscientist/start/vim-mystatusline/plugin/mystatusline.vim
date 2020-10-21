" Statusline Configuration
" Maintainer: mark.grzovic@gmail.com 
" Created: 2020-03-23 Mon 08:36 AM CDT
" Last Change: 2020-03-23 Mon 08:36 AM CDT

if exists("g:loaded_mystatusline") || &cp
  finish
endif
let g:loaded_mystatusline = 1

let s:save_cpo = &cpo
set cpo&vim

if !exists("g:currentmode")
  let g:currentmode = {
    \'n' : ' NORMAL ',
    \'no': 'NORM-OP ',
    \'v' : ' VISUAL ',
    \'V' : 'VIS-LINE',
    \'^V': 'VIS-BLCK',
    \'s' : ' SELECT ',
    \'S' : 'SEL-LINE',
    \'^S': 'SEL-BLCK',
    \'i' : ' INSERT ',
    \'R' : 'REPLACE ',
    \'Rv': 'REP-VIRT',
    \'c' : 'COMMAND ',
    \'cv': 'VM EX-MD',
    \'ce': 'EX-MODE ',
    \'r' : ' PROMPT ',
    \'rm': 'MORE... ',
    \'r?': 'CONFIRM ',
    \'!' : ' SHELL  '
    \}
endif

set laststatus=2                                     " Always show statusline
set statusline=
set statusline=%<                                    " Truncate after path
set statusline+=\ BUF#%n\                            " Display buffer number
set statusline+=%2*[
set statusline+=\ %{g:currentmode[strtrans(mode())]} " Display current mode
set statusline+=\ ]%*
set statusline+=\ %t                                 " Filename and path
set statusline+=%=                                   " Switch to the right side
set statusline+=\%11((%M%Y%R)%)                      " Modified, filetype, read-only
set statusline+=\%12((L%l,C%c)%)                     " Current line and col number
set statusline+=\%13((TL%L,%P)%)                     " Total number of lines
" May want to try set statusline+=\ %{strpart(%F, 0, 30)}

let &cpo = s:save_cpo
unlet s:save_cpo
