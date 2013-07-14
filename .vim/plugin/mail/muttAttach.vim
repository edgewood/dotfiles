" To install, copy into existing ~/.vim/after/ftplugin/mail.vim,
" or save it into ~/.vim/plugin/mail/ and edit ~/.vim/after/ftplugin/mail.vim
" to have this line: "runtime mail/muttAttach.vim"
"
" Script: muttAttach.vim
" Author: Ed Blackman
" Email:  ed@edgewood.to
"
" This file was modified from a version from Brian Medley
" <freesoftware@4321.tv>, which was modified from Cedric Duval's version.
" http://cedricduval.free.fr/download/vimrc/mail
"
" Description:
" This function creates a file-write hook that looks for key words that
" indicate the user wishes to attach a file, and prompts for the file,
" then causes it to be attached using the Mutt Attach: pseudo-header.
"
" If the user responds to the prompt with 'none', add the X-Attached: none
" header to indicate that other attachment processing scripts shouldn't
" expect to find an attachment despite the prescence of key words.

" ------------------------------------------------
"                 Check Attachments
" ------------------------------------------------

if !exists("CheckAttach")
function! CheckAttach()
    let check='attach,patch'
    let oldPos=getpos('.')
    let ans=1
    let val = join(split(escape(check,' \.+*'), ','),'\|')
    1
    let s:ignorecase_save=&ignorecase
    set ignorecase
    " iterate over lines with matches
    while search('\%('.val.'\)','W') > 0
      " consider only non-quoted lines
      if match(getline(line('.')), "^>") < 0
	let ans=input("Attach file?: (leave empty to abort): ", "", "file")
	while (ans != '')
		normal magg}-
		if ans != 'none'
		   call append(line('.'), 'Attach: '.ans)
	        else
		   call append(line('.'), 'X-Attached: '.ans)
		endif
		redraw
	    let ans=input("Attach another file?: (leave empty to abort): ", "", "file")
	endwhile
	" one match is enough: move to end of file to break search loop
	normal G$
      endif
    endwhile
    exe ":write ". expand("<amatch>")
    let &ignorecase=s:ignorecase_save
    call setpos('.', oldPos)
endfu

augroup script
    au!
    au BufWriteCmd,FileWriteCmd */mutt-* :call CheckAttach()
augroup END
endif
