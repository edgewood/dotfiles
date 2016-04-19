" color trailing spaces to easily see where format=flowed lines will wrap and
" not wrap
syntax match lineEndWrap / $/
hi WrapLines term=bold,underline cterm=bold,underline gui=bold,underline

if &background == "dark"
  hi WrapLines ctermfg=White ctermbg=Black guifg=Black guibg=White
else
  hi WrapLines ctermfg=Black ctermbg=White guifg=Black guibg=White
endif

hi def link lineEndWrap WrapLines

" color nonbreaking space
syntax match nbsp " " containedIn=ALL " quotes has nbsp - ^KNS
highlight link nbsp Underlined
