" ============================================================================
" File:         plugin/readline.vim
" Description:  Readline-style mappings for command mode
" Author:       Elias Astrom <github.com/ryvnf>
" Last Change:  2017 Dec 25
" Licence:      The VIM-LICENSE.  This Plugin is distributed under the same
"               conditions as VIM itself.
" ============================================================================

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" mappings
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" move to start of line
cnoremap <c-a> <home>

" move to end of line
cnoremap <c-e> <end>

" move to next char
cnoremap <c-b> <left>

" move to previous char
cnoremap <c-f> <right>

" move back to start of word
cnoremap <expr> <esc>b <sid>move_to(<sid>back_word())
cmap <esc>B <esc>b

" move forward to end of word
cnoremap <expr> <esc>f <sid>move_to(<sid>forward_word())
cmap <esc>F <esc>f

" delete char under cursor
cnoremap <expr> <c-d> getcmdpos() <= strlen(getcmdline()) ? "\<del>" : ""

" delete back to start of word
cnoremap <expr> <esc><bs> <sid>delete_to(<sid>back_word())

" delete back to start of space delimited word
cnoremap <expr> <c-w> <sid>delete_to(<sid>back_longword())

" delete forward to end of word
cnoremap <expr> <esc>d <sid>delete_to(<sid>forward_word())
cmap <esc>D <esc>d

" delete to start of line
cnoremap <expr> <c-u> <sid>delete_to(0)

" delete to end of line
cnoremap <expr> <c-k> <sid>delete_to(strlen(getcmdline()))

" transpose characters before cursor
cnoremap <expr> <c-t> <sid>transpose_chars()

" transpose words before cursor
cnoremap <expr> <esc>t <sid>transpose_words()
cmap <esc>T <esc>t

" yank (paste) previously deleted text
cnoremap <expr> <c-y> <sid>yank()

" make word uppercase
cnoremap <expr> <esc>u <sid>upcase_word()
cnoremap <esc>D <esc>d

" make word lowercase
cnoremap <expr> <esc>l <sid>downcase_word()
cnoremap <esc>L <esc>l

" make word capitalized
cnoremap <expr> <esc>c <sid>capitalize_word()
cnoremap <esc>C <esc>c

" list all completion matches
cnoremap <esc>? <c-d>

" insert all completion matches
cnoremap <esc>* <c-a>

" open cmdline-window
cnoremap <c-x><c-e> <c-f>

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" internal variables
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" [:alnum:] and [:alpha:] only matches ASCII characters.  But we can use the
" fact that [:upper:] and [:lower:] will match non-ASCII characters to create
" a pattern which will match alphanumeric characters from all encodings.
let s:wordchars = "[[:upper:][:lower:][:digit:]]"

" buffer to hold the previously deleted text
let s:yankbuf = ""

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" internal functions
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" get mapping to transpose chars before cursor position
function! s:transpose_chars()
  let l:s = getcmdline()
  let l:n = strchars(l:s)
  let l:x = strchars((l:s . " ")[:getcmdpos() - 1]) - 1
  if l:x == 0 || l:n < 2
    return ""
  endif
  let l:cmd = ""
  if l:x == l:n
    let l:cmd .= "\<left>"
    let l:x -= 1
  endif
  return l:cmd . "\b\<right>" .
  \ substitute(strcharpart(l:s, l:x - 1, 1), "[[:cntrl:]]", "\<c-v>&")
endfunction

" get mapping to transpose words before cursor position
function! s:transpose_words()
  let l:s = getcmdline()
  let l:x = strchars((l:s . " ")[:getcmdpos() - 1]) - 1
  let l:end2 = s:forward_word(l:x)
  if strcharpart(l:s, l:x, 1) == ""
    let l:x -= 1
  endif
  let l:beg2 = s:back_word(l:end2)
  let l:beg1 = s:back_word(l:beg2)
  let l:end1 = s:forward_word(l:beg1)
  if l:beg1 == l:beg2 || l:beg2 < l:end1
    return ""
  endif
  let l:str1 = strcharpart(l:s, l:beg1, l:end1 - l:beg1)
  let l:str2 = strcharpart(l:s, l:beg2, l:end2 - l:beg2)
  let l:len1 = strchars(l:str1)
  let l:len2 = strchars(l:str2)
  return s:move_to(l:end2, l:x) . repeat("\b", l:len2) .  l:str1 .
  \ s:move_to(end1, l:beg2 + l:len1) . repeat("\b", l:len1) .
  \ substitute(l:str2, "[[:cntrl:]]", "\<c-v>&", "g") .
  \ s:move_to(end2, l:beg1 + l:len2)
endfunction

" Get mapping to move cursor to position. The first argument is the position
" to move to. If the second argument option is used, then it is used as the
" current cursor position.
function! s:move_to(...)
  let l:cmd = ""
  if a:0 == 1
    let l:y = strchars((getcmdline() . " ")[:getcmdpos() - 1]) - 1
  else
    let l:y = a:2
  endif
  if l:y < a:1
    while l:y < a:1
      let l:cmd .= "\<right>"
      let l:y += 1
    endwhile
  else
    while a:1 < l:y
      let l:cmd .= "\<left>"
      let l:y -= 1
    endwhile
  endif
  return l:cmd
endfunction

" get mapping to delete to position
function! s:delete_to(x)
  let l:cmd = ""
  let l:s = getcmdline()
  let l:x = a:x
  let l:y = strchars((l:s . " ")[:getcmdpos() - 1]) - 1
  let s:yankbuf = ""
  if l:y < l:x
    while l:y < l:x
      let l:cmd .= "\<del>"
      let s:yankbuf .= strcharpart(l:s, l:y, 1)
      let l:y += 1
    endwhile
  else
    while l:x < l:y
      let l:cmd .= "\b"
      let s:yankbuf .= strcharpart(l:s, l:x, 1)
      let l:x += 1
    endwhile
  endif
  return l:cmd
endfunction

" Get word start position behind cursor. If an argument is specified, it will
" be used as the current cursor position.
function! s:back_word(...)
  let l:s = getcmdline()
  if a:0 == 0
    let l:x = strchars((l:s . " ")[:getcmdpos() - 1]) - 1
  else
    let l:x = a:1
  end
  while l:x > 0 && strcharpart(l:s, l:x - 1, 1) !~ s:wordchars
    let l:x -= 1
  endwhile
  while l:x > 0 && strcharpart(l:s, l:x - 1, 1) =~ s:wordchars
    let l:x -= 1
  endwhile
  return l:x
endfunction

" Get longword start position behind cursor. If an argument is specified, it
" will be used as the current cursor position.
function! s:back_longword(...)
  let l:s = getcmdline()
  if a:0 == 0
	let l:x = strchars((l:s . " ")[:getcmdpos() - 1]) - 1
  else
	let l:x = a:1
  end
  while l:x > 0 && strcharpart(l:s, l:x - 1, 1) =~ "[[:space:]]"
    let l:x -= 1
  endwhile
  while l:x > 0 && strcharpart(l:s, l:x - 1, 1) !~ "[[:space:]]"
    let l:x -= 1
  endwhile
  return l:x
endfunction

" Get word end position in front of cursor. If an argument is specified, then
" it will be used as the current cursor position.
function! s:forward_word(...)
  let l:s = getcmdline()
  let l:n = strchars(l:s)
  if a:0 == 0
	let l:x = strchars((l:s . " ")[:getcmdpos() - 1]) - 1
  else
	let l:x = a:1
  end
  while l:x < l:n && strcharpart(l:s, l:x, 1) !~ s:wordchars
    let l:x += 1
  endwhile
  while l:x < l:n && strcharpart(l:s, l:x, 1) =~ s:wordchars
    let l:x += 1
  endwhile
  return l:x
endfunction

" get mapping to make word uppercase
function! s:upcase_word()
  let l:cmd = ""
  let l:s = getcmdline()
  let l:x = s:forward_word()
  let l:y = strchars((l:s . " ")[:getcmdpos() - 1]) - 1
  let s:yankbuf = ""
  while l:y < l:x
    let l:cmd .= "\<del>" . toupper(strcharpart(l:s, l:y, 1))
    let l:y += 1
  endwhile
  return l:cmd
endfunction

" get mapping to make word lowercase
function! s:downcase_word()
  let l:cmd = ""
  let l:s = getcmdline()
  let l:x = s:forward_word()
  let l:y = strchars((l:s . " ")[:getcmdpos() - 1]) - 1
  let s:yankbuf = ""
  while l:y < l:x
    let l:cmd .= "\<del>" . tolower(strcharpart(l:s, l:y, 1))
    let l:y += 1
  endwhile
  return l:cmd
endfunction

" get mapping to make word capitalized
function! s:capitalize_word()
  let l:cmd = ""
  let l:s = getcmdline()
  let l:x = s:forward_word()
  let l:y = strchars((l:s . " ")[:getcmdpos() - 1]) - 1
  let s:yankbuf = ""
  while l:y < l:x
    let l:c = strcharpart(l:s, l:y, 1)
    let l:y += 1
    if l:c =~ s:wordchars
      let l:cmd .= "\<del>" . toupper(strcharpart(l:s, l:y - 1, 1))
      break
    else
      let l:cmd .= "\<right>"
    endif
  endwhile
  while l:y < l:x
    let l:cmd .= "\<del>" . tolower(strcharpart(l:s, l:y, 1))
    let l:y += 1
  endwhile
  return l:cmd
endfunction

" get mapping to yank (paste) the previously deleted text
function! s:yank()
  return s:yankbuf
endfunction
