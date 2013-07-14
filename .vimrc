set autoindent
set shiftwidth=4
set background=dark
set backspace=indent,eol,start
set hidden

" Change C-u and C-w to set an undo point first
" http://vim.wikia.com/wiki/Recover_from_accidental_Ctrl-U
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

" Centralize .swp files to avoid having them backed up, stored in version
" control, etc.  Fall back to "same directory" or system temp dirs.
" Priority is to paths that persist across reboots.
set directory=/var/tmp/vim-edgewood,.,/var/tmp,/tmp

" turn on filetype, including indentation and plugins
filetype on
filetype plugin on
filetype indent on

if has('autocmd')
  " secure editing of gpg encrypted files
  au BufNewFile,BufReadPre *.gpg :set secure viminfo= noswapfile nobackup nowritebackup history=0 binary
  au BufReadPost *.gpg :%!gpg -d 2>/dev/null
  au BufWritePre *.gpg :%!gpg -e -r $KEY 2>/dev/null
  au BufWritePost *.gpg u
endif

" Mutt rc files in ~/.mutt/* instead of ~/.muttrc
au BufNewFile,BufRead */.mutt{ng,}/*   :setf muttrc

"===================================================================
" THE NECESSARY STUFF"
" THe three lines below are necessary for VimOrganizer to work right
" =================================================================
filetype plugin indent on
" and then put these lines in vimrc somewhere after the line above
au! BufRead,BufWrite,BufWritePost,BufNewFile *.org 
au BufEnter *.org            call org#SetOrgFileType()
