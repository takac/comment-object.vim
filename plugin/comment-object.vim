let s:delimiterMap = {
			\ 'java': { 'left': '//', 'leftAlt': '/*', 'rightAlt': '*/', 'mid' : '*' },
			\ 'vim': { 'left': '"' },
			\ }

autocmd BufEnter * call SetUpForNewFiletype(&filetype, 0)

function! SetUpForNewFiletype(filetype, forceReset)
	let ft = a:filetype
	
	if has_key(s:delimiterMap, ft)
		let s:CommenterDelims = s:delimiterMap[ft]
	endif

endfunction

function! SelectComment()
	let comment_regex = '\v^\s*('
	for i in ['left', 'leftAlt', 'right', 'rightAlt', 'mid']
		if has_key(s:CommenterDelims, i)
			let comment_regex = comment_regex . escape(s:CommenterDelims[i], '/*') . '|'
		endif
	endfor
	let comment_regex = comment_regex[:-2] . ')'
	
	echom comment_regex

	" bail if not a comment
	if match(getline("."), comment_regex) == -1
		return 
	endif


	"work out what type of comment we are in
	"left = //
	"leftAlt = /*
	if match(getline("."), s:CommenterDelims['left']) > -1
		let comment_start = '\v^\s*(' . escape(s:CommenterDelims['left'], '/*') . ')'
		let comment_regex = comment_start
	else
		let comment_regex = '\v^\s*('
		for i in ['leftAlt', 'rightAlt', 'mid']
			if has_key(s:CommenterDelims, i)
				let comment_regex = comment_regex . escape(s:CommenterDelims[i], '/*') . '|'
			endif
		endfor
	let comment_regex = comment_regex[:-2] . ')'
	endif

	while getline(line(".") - 1) =~ comment_regex 
		normal k
	endwhile

	" start selecting
	normal V
	
	" find the last commented line
	while line(".") < line("$") && getline(line(".") + 1) =~ comment_regex
	 	normal j
	endwhile
endfunction

function! SelectInnerComment(visual)

	let start_pos = getpos(".")

	let comment_inline = '\/\/'
	let comment_start = '\/\*'
	let comment_end = '\*\/\s*$'

	if(a:visual)
		normal! gv
	else 
		normal! v
	endif

	let comment_type = 0
	let comment_line_start = ''
	let comment_line_end = ''

	if getline(".") =~ comment_inline
		normal! g^
		call search(comment_inline . '\zs')
		let comment_type = 0
	else
		let comment_type = 1
		normal! g^
	endif

	if comment_type
		if getline(".") !~ comment_start
			while getline(line(".")) !~ comment_start
				if getline(line(".")-1) =~ comment_end
					call setpos(".",start_pos)
					return 
				endif
				normal! k
			endwhile
			let comment_line_start = line(".") 
			normal! ^3l
		else
			if getline(".") =~ comment_end
				normal! 3l
			else
				normal! 3l
			endif
		endif
	else
		while getline(line(".")-1) =~ comment_inline
			normal! k
		endwhile
		normal! g^
		call search(comment_inline . '\zs')
	endif

	normal! o

	
	if comment_type
		if getline(".") !~ comment_end
			while getline(line(".")) !~ comment_end
				normal! j
			endwhile
			let comment_line_end = line(".") 
		else
			if getline(".") =~ comment_start
				echom "do noth"
			else
				echo "noenA"
			endif
		endif
	else
		while getline(line(".")+1) =~ comment_inline
			normal! j
		endwhile
	endif
	
	if comment_type
		if line(".") == comment_line_start
			if line(".") == comment_line_end
				echom "do nothing"
			endif
		else
			normal! $3h
		endif
		if comment_line_start < comment_line_end - 3
		endif
	else
		normal! $h
	endif

endfunction

vnoremap ac :<C-U> call SelectComment()<CR>
omap ac :normal vac<CR>

vnoremap ic :<C-U> call SelectInnerComment(1)<CR>
omap ic :call SelectInnerComment(0)<CR>
