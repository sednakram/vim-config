" My cursor configuration settings
" Maintainer: mark.grzovic@gmail.com 
" Created: 2020-03-23 Mon 08:19 AM CDT
" Last Change: 2020-04-01 Wed 09:43 AM CDT

if exists("g:loaded_mycursor")
  finish
endif
let g:loaded_mycursor = 1

let s:save_cpo = &cpo
set cpo&vim

let &t_ti.="\e[1 q"
let &t_SI.="\e[5 q"
let &t_EI.="\e[1 q"
let &t_te.="\e[0 q"

let &cpo = s:save_cpo
unlet s:save_cpo
