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
		let comment_regex = '^\s*\('
		for i in ['leftAlt', 'right', 'mid']
			if has_key(s:CommenterDelims, i)
				let comment_regex = comment_regex . escape(s:CommenterDelims[i], '/*') . '\|'
			endif
		endfor
	let comment_regex = comment_regex[:-3] . '\)'
	endif
	
	while match(getline(line(".+1")), '\*') != -1
		normal k
	endwhile

	" start selecting
	normal V6j
		
	" find the last commented line
endfunction

function! SelectInnerComment()

	" TODO: What happens if a , or : is used in a comment-indicator?
	let comment_indicators=map(split(&com, ","),	'split(v:val, ":")[-1]')

	" Creates a regular expression that matches y line that starts with a
	" comment indicator.
	"
	" TODO: Handle the "f" flag and the "b" flag.
	let comment_regex= '^\s*' . s:CommenterDelims['left']

	" bail if not a comment
	if match(getline("."), comment_regex) == -1
		return 
	endif

	" find the first commented line
	while line(".") - 1 && match(getline(line(".") - 1), comment_regex) > -1
		normal k
	endwhile

	" start selecting
	normal ^2lv$h

	" find the last commented line
	while line(".") < line("$") &&	match(getline(line(".") + 1), comment_regex) > -1
		normal j$h
	endwhile
endfunction

vnoremap ac :<C-U> call SelectComment()<CR>
omap ac :normal vac<CR>

" TODO: In the case that a comment has different start and end delimeters from
" its extension character, we should exclude those lines.
vnoremap ic :<C-U> call SelectInnerComment()<CR>
omap ic :normal vic<CR>
