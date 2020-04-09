" My Vimrc file
" Last Change: 2020-03-26 Thu 11:23 AM CDT
" Maintainer: mark.grzovic@gmail.com
" License: www.opensource.org/licenses/bsd-2-clause.php

" Use Vim settings, rather than Vi settings.
" This must be first b/c it changes other options as a side effect.
set nocompatible

" ========== GLOBAL SETTINGS ==========
" ---------- General Configurations ----------

set history=1000          " Store lots of cmdline history.
set textwidth=79          " Lines longer than 79 will be broken.
set visualbell            " Turn off that annoying bell.
set backspace=indent,eol,start " Enable normal use of backspace
set nowrap                " Turn off line wrapping.
syntax on                 " Turn on syntax highlighting.
filetype on               " Turn on filetype detection
set fileformat=unix       " Use Unix formatting.
set encoding=utf-8        " Use UTF-8 encoding.
source ~/.vim/pack/madscientist/start/vim-yakuake/yakuake.vim

" ---------- Colorscheme Config ----------

" set background=dark
" colorscheme solarized

" ---------- Line Numbering Config ----------

set number                " Enable line numbering.
set norelativenumber      " Disable relative line numbers.

" ---------- Indentation Configurations ----------

set autoindent            " Align indent of newline with previous line.
set shiftwidth=2          " Number of spaces to use for autoindent.
set tabstop=2             " A hard tab displays as 2 columns.
set expandtab             " Insert spaces instead of tabs.
set softtabstop=2         " Insert/delete 2 spaces when using tab/backspace.
set shiftround            " Round indent to multiple of shiftwidth.

" ---------- Split Window Config ----------

set splitright            " Open new file to right of current file
set splitbelow            " Open new file below current file

" ---------- Search Configurations ----------

set hlsearch              " Highlight searches.
set incsearch             " Show partial matches
set ignorecase            " Ignore case when searching...
set smartcase             " ...unless we type a capital.

" ---------- Statusline Config ----------

set showcmd               " Enable command completion.
set wildmenu              " Enable command completion list.
source ~/.vim/pack/madscientist/start/vim-mystatusline/mystatusline.vim

" ---------- Backup/Swap file Config ----------

set backupdir=~/.vim/tmp            " Location for backups.
set directory=~/.vim/swp            " Location for swap files.

" ---------- Windows Config ----------

if has("gui_win32") || has("gui_win64")
  set shell=C:/Git/bin/bash.exe
  set shellpipe=|
  set shellredir=>
  set shellcmdflag=--login\ -c      " -c for bash.exe shell, --login to use bashrc settings
  set shellxquote=\"
  set shellslash         " Use forward slash instead of backslash
endif

" ========== MAPPINGS ==========

set timeoutlen=3000       " Set time out to 3s

" Set Leader variable first
let mapleader = "\\"
let maplocalleader = ","

" ---------- Useful mappings ----------

" Remap <esc> key to make it easier to return to normal mode.
inoremap jk <Esc>
inoremap JK <esc>

" Remap Y to be more logical
nnoremap Y y$

" Remap H and L to make line navigation easier
nnoremap H 0
nnoremap L $

" Map spacebar to enable folding
nnoremap <space> za

" Remap split window navigation key combinations to make
"  it easier to navigate.
nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

" Turn off last search highlights
nnoremap <Leader>h :nohlsearch<CR>

" Toggle relative numbering
nnoremap <Leader>rn :set relativenumber!<CR>

" Enable easy edit of Vimrc
nnoremap <Leader>ev :vsplit $MYVIMRC<CR>
nnoremap <Leader>sv :write<CR> :source $MYVIMRC<CR>
" Enable easy edit of plugin files
" nnoremap <Leader>ep :vsplit ~/.vim/plugin/
" nnoremap <Leader>sp :write<CR> :source ~/.vim/plugin/

" Mappings from 'Learn Vimscript the Hard Way'
" Move line down
nnoremap <Leader>- ddp
" Move line up
nnoremap <Leader>_ ddkP
" Uppercase current word
nnoremap <C-U> vawU
inoremap <C-U> <Esc>vawU
" Add quotes around word or selection
nnoremap <Leader>" viw<esc>a"<esc>hbi"<esc>lel
nnoremap <Leader>' viw<esc>a'<esc>hbi'<esc>lel
vnoremap <Leader>" <esc>a"<esc>v`<<esc>i"<esc>

" ---------- Disabled mappings ----------

" Map <esc> key to do nothing
inoremap <Esc> <nop>

" Disable 0 and $
nnoremap 0 <nop>
nnoremap $ <nop>

" Map arrow keys to do nothing in normal mode
nnoremap <Up> <nop>
nnoremap <Down> <nop>
nnoremap <Left> <nop>
nnoremap <Right> <nop>

" Map arrow keys to do nothing in insert mode
inoremap <Up> <nop>
inoremap <Down> <nop>
inoremap <Left> <nop>
inoremap <Right> <nop>

" ========== ABBREVIATIONS ==========
" ---------- Common misspellings ----------

iabbrev adn and
iabbrev waht what
iabbrev tehn then

" ---------- Useful abbreviations ----------

iabbrev @@ mark.grzovic@gmail.com 
iabbrev ccopy Copyright 2018 Mark Grzovic, all rights reserved.
iabbrev ttime <C-R>=strftime("%Y-%m-%d %a %I:%M %p %Z")<CR>
iabbrev tdate <c-r>=strftime("%Y-%m-%d %a")<cr>

" ========== AUTOCOMMANDS ==========
" ---------- Html ----------

augroup filetype_html
  autocmd!
  " Wrap text between start and end tags
  autocmd FileType html nnoremap <buffer> <localleader>f Vatzf
augroup END

" ---------- Javascript ----------

augroup filetype_javascript
  autocmd!
  " Comment line
  autocmd Filetype javascript nnoremap <buffer> <localleader>c I//<esc>
augroup END

" ---------- Matlab ----------

augroup filetype_matlab
  autocmd!
  " Comment line
  autocmd Filetype matlab nnoremap <buffer> <localleader>c I% <esc>
augroup END

" ---------- Python ----------

augroup filetype_python
  autocmd!
  autocmd FileType python source ~/.vim/pack/madscientist/start/vim-pydev/pydev.vim
  autocmd FileType python setlocal shiftwidth=4
  autocmd FileType python setlocal tabstop=4
  autocmd FileType python setlocal softtabstop=4
  " Enable folding
  autocmd FileType python setlocal foldmethod=indent
  autocmd FileType python setlocal foldlevel=99
  " Comment line
  autocmd FileType python nnoremap <buffer> <localleader>c 0i# <esc>
  " Uncomment line
  autocmd FileType python nnoremap <buffer> <localleader>uc 02x
  " Add todo note
  autocmd FileType python iabbrev <buffer> todo # TODO: <C-R>=strftime("%Y-%m-%d %a %I:%M %p %Z")<cr><cr># TODO:
  " Insert python file prefix
  autocmd FileType python iabbrev <buffer> ppref #!/usr/bin/env python3<cr># -*- coding: utf-8 -*-<cr>
  " Popular import statements
  autocmd FileType python iabbrev <buffer> ilog import logging
  autocmd FileType python iabbrev <buffer> iplt import matplotlib.pyplot as plt
  autocmd FileType python iabbrev <buffer> inp import numpy as np
  autocmd FileType python iabbrev <buffer> ios import os
  autocmd FileType python iabbrev <buffer> ipd import pandas as pd
  " Flag unnecessary whitespace
"   autocmd BufRead,BufNewFile *.py match BadWhitespace /\s\+$/
augroup END

" ---------- Text ----------

augroup filetype_text
  autocmd!
  autocmd FileType text setlocal noautoindent
augroup END

" ---------- Vimscript ----------

augroup filetype_vimscript
  autocmd!
  " Comment line
  autocmd FileType vim nnoremap <buffer> <localleader>c 0i" <esc>
  " Uncomment line
  autocmd FileType vim nnoremap <buffer> <localleader>uc 02x
  " Add todo note
  autocmd FileType vim iabbrev <buffer> todo " TODO: <C-R>=strftime("%Y-%m-%d %a %I:%M %p %Z")<cr><cr>" TODO:
  " Enable folding
augroup END
