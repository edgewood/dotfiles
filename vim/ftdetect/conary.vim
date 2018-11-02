
fun! s:DetectCvcCheckin()
    if match(getline(3), "Enter your change log message.") == 0
	setlocal ft=cvc
    endif
endfun

autocmd BufNewFile,BufRead /tmp/tmp* call s:DetectCvcCheckin()
