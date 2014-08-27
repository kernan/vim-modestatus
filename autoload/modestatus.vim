function! modestatus#statusline(nr)
	let active = a:nr == winnr()
	let bufnum = winbufnr(a:nr)

	let buftype = getbufvar(bufnum, '&buftype')
	let bufname = bufname(bufnum)
	" TODO(2014-08-26) Change buffer names based on dictionary values.

	function! Color(active, num, content)
		if a:active
			return '%' . a:num . '*' . a:content . '%*'
		else
			return a:content
		endif
	endfunction

	let statusline = ''
	" TODO(2014-08-26) Paste
	" TODO(2014-08-26) Spellcheck
	if active
		" line percent
		let statusline .= ' '
		let statusline .= modestatus#util#pad_before(
			\   '(' . string(float2nr(round((line('.') * 1.0) / (line('$') * 1.0) * 100.0))),
			\ 4) . '%%)'
		" line:column
		let statusline .= ' '
		let statusline .= modestatus#util#pad_before(line('.'), strlen(line('$'))) .
			\ ':' . modestatus#util#pad_after(virtcol('.'), 3)
		" mode
		let statusline .= ' '
		let statusline .= Color(active, 2, '‹' . g:modestatus#mode_map[mode()] . '›')
	endif
	" filename
	let statusline .= ' '
	let statusline .= Color(active, 1, '%f')
	" modified
	let modified = getbufvar(bufnum, '&modified')
	let statusline .= Color(active, 3, modified ? ' +' : '')
	" readonly
	let readonly = getbufvar(bufnum, '&readonly')
	let statusline .= Color(active, 3, readonly ? ' ‼' : '')
	" filetype and encoding
	let statusline .= ' '
	let filetype = getbufvar(bufnum, '&filetype')
	let encoding = getbufvar(bufnum, '&encoding')
	let filetype = len(filetype) ? filetype . ',' : ''
	let statusline .= len(filetype) || len(encoding) ? '[' . filetype . encoding . ']' : ''
	" errors
	let statusline .= ' '
	let statusline .= Color(active, 8, modestatus#loclist#errors(a:nr))
	let statusline .= Color(active, 9, modestatus#loclist#warnings(a:nr))
	let statusline .= '%='
	return statusline
endfunction

function! modestatus#update()
	for nr in range(1, winnr('$'))
		call setwinvar(nr, '&statusline', '%!modestatus#statusline(' . nr . ')')
	endfor
endfunction