" ============================================================================
" File:         plugin/readline.vim
" Description:  Readline-style mappings for command mode
" Author:       Elias Astrom <github.com/ryvnf>
" Last Change:  2017 Dec 31
" Version:	1.4
" Licence:      The VIM LICENSE
" ============================================================================

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" mappings
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" avoid closing the cmdline by accident
cnoremap <esc> <c-v><esc>

" abort currently typed command
cnoremap <c-g> <nop>
cnoremap <esc><c-g> <nop>
cnoremap <c-x><c-g> <nop>

" move to next char
cnoremap <c-b> <left>

" move to previous char
cnoremap <c-f> <right>

" move back to start of word
cnoremap <expr> <esc>b <sid>back_word()
cnoremap <expr> <esc>B <sid>back_word()

" move forward to end of word
cnoremap <expr> <esc>f <sid>forward_word()
cnoremap <expr> <esc>F <sid>forward_word()

" move to start of line
cnoremap <c-a> <home>

" move to end of line
cnoremap <c-e> <end>

" delete char under cursor
cnoremap <expr> <c-d> getcmdpos() <= strlen(getcmdline()) ? "\<del>" : ""

" delete back to start of word
cnoremap <expr> <esc><bs> <sid>rubout_word()

" delete back to start of space delimited word
cnoremap <expr> <c-w> <sid>rubout_longword()

" delete forward to end of word
cnoremap <expr> <esc>d <sid>delete_word()
cnoremap <expr> <esc>D <sid>delete_word()

" delete to start of line
cnoremap <expr> <c-u> <sid>rubout_line()
cnoremap <expr> <c-x><bs> <sid>rubout_line()

" delete to end of line
cnoremap <expr> <c-k> <sid>delete_line()

" transpose characters before cursor
cnoremap <expr> <c-t> <sid>transpose_chars()

" transpose words before cursor
cnoremap <expr> <esc>t <sid>transpose_words()
cnoremap <expr> <esc>T <sid>transpose_words()

" yank (paste) previously deleted text
cnoremap <expr> <c-y> <sid>yank()

" make word uppercase
cnoremap <expr> <esc>u <sid>upcase_word()
cnoremap <expr> <esc>U <sid>upcase_word()

" make word lowercase
cnoremap <expr> <esc>l <sid>downcase_word()
cnoremap <expr> <esc>L <sid>downcase_word()

" make word capitalized
cnoremap <expr> <esc>c <sid>capitalize_word()
cnoremap <expr> <esc>C <sid>capitalize_word()

" comment out line and execute it
cnoremap <expr> <esc># <c-b>"<cr>

" list all completion matches
cnoremap <esc>? <c-d>
cnoremap <esc>= <c-d>

" insert all completion matches
cnoremap <esc>* <c-a>

" open cmdline-window
cnoremap <c-x><c-e> <c-f>

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" internal variables
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" [:alnum:] and [:alpha:] only matches ASCII characters. But we can use the
" fact that [:upper:] and [:lower:] will match non-ASCII characters to create
" a pattern that will match alphanumeric characters from all encodings.
let s:wordchars = '[[:upper:][:lower:][:digit:]]'

" buffer to hold the previously deleted text
let s:yankbuf = ''

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" internal functions
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" get mapping to move one word forward
function! s:forward_word()
  let x = s:getcur()
  return s:move_to(s:next_word(x), x)
endfunction

" get mapping to move one word back
function! s:back_word()
  let x = s:getcur()
  return s:move_to(s:prev_word(x), x)
endfunction

" get mapping to rubout word behind cursor
function! s:rubout_word()
  let x = s:getcur()
  return s:delete_to(s:prev_word(x), x)
endfunction

" get mapping to rubout space delimeted word behind of cursor
function! s:rubout_longword()
  let x = s:getcur()
  return s:delete_to(s:prev_longword(x), x)
endfunction

" get mapping to delete word in front of cursor
function! s:delete_word()
  let x = s:getcur()
  return s:delete_to(s:next_word(x), x)
endfunction

" get mapping to delete to end of line
function! s:delete_line()
  return s:delete_to(strchars(getcmdline()), s:getcur())
endfunction

" get mapping to rubout to start of line
function! s:rubout_line()
  return s:delete_to(0, s:getcur())
endfunction

" get mapping to make word uppercase
function! s:upcase_word()
  let cmd = ""
  let s = getcmdline()
  let x = s:getcur()
  let y = s:next_word(x)
  while x < y
    let cmd .= "\<del>" . toupper(strcharpart(s, x, 1))
    let x += 1
  endwhile
  return substitute(cmd, '[[:cntrl:]]', "\<c-v>&", 'g')
endfunction

" get mapping to make word lowercase
function! s:downcase_word()
  let cmd = ""
  let s = getcmdline()
  let x = s:getcur()
  let y = s:next_word(x)
  while x < y
    let cmd .= "\<del>" . tolower(strcharpart(s, x, 1))
    let x += 1
  endwhile
  return substitute(cmd, '[[:cntrl:]]', "\<c-v>&", 'g')
endfunction

" get mapping to make word capitalized
function! s:capitalize_word()
  let cmd = ""
  let s = getcmdline()
  let x = s:getcur()
  let y = s:next_word(x)
  while x < y
    let c = strcharpart(s, x, 1)
    let x += 1
    if c =~ s:wordchars
      let cmd .= "\<del>" . toupper(strcharpart(s, x - 1, 1))
      break
    else
      let cmd .= "\<right>"
    endif
  endwhile
  while x < y
    let cmd .= "\<del>" . tolower(strcharpart(s, x, 1))
    let x += 1
  endwhile
  return substitute(cmd, '[[:cntrl:]]', "\<c-v>&", 'g')
endfunction

" get mapping to yank (paste) the previously deleted text
function! s:yank()
  return substitute(s:yankbuf, '[[:cntrl:]]', "\<c-v>&", 'g')
endfunction

" get mapping to transpose chars before cursor position
function! s:transpose_chars()
  let s = getcmdline()
  let n = strchars(s)
  let x = s:getcur()
  if x == 0 || n < 2
    return ""
  endif
  let cmd = ""
  if x == n
    let cmd .= "\<left>"
    let x -= 1
  endif
  return cmd . "\b\<right>" .
  \ substitute(strcharpart(s, x - 1, 1), '[[:cntrl:]]', "\<c-v>&", '')
endfunction

" get mapping to transpose words before cursor position
function! s:transpose_words()
  let s = getcmdline()
  let x = s:getcur()
  let end2 = s:next_word(x)
  if strcharpart(s, x, 1) == ""
    let x -= 1
  endif
  let beg2 = s:prev_word(end2)
  let beg1 = s:prev_word(beg2)
  let end1 = s:next_word(beg1)
  if beg1 == beg2 || beg2 < end1
    return ""
  endif
  let str1 = strcharpart(s, beg1, end1 - beg1)
  let str2 = strcharpart(s, beg2, end2 - beg2)
  let len1 = strchars(str1)
  let len2 = strchars(str2)
  return s:move_to(end2, x) . repeat("\b", len2) . str1 .
  \ s:move_to(end1, beg2 + len1) . repeat("\b", len1) .
  \ substitute(str2, '[[:cntrl:]]', "\<c-v>&", 'g') .
  \ s:move_to(end2, beg1 + len2)
endfunction

" Get mapping to move cursor to position. Argument x is the position to move
" to. Argument y is the current cursor position (note that this _must_ be in
" sync with the real cursor position).
function! s:move_to(x, y)
  let cmd = ""
  let y = a:y
  if y < a:x
    while y < a:x
      let cmd .= "\<right>"
      let y += 1
    endwhile
  else
    while a:x < y
      let cmd .= "\<left>"
      let y -= 1
    endwhile
  endif
  return cmd
endfunction

" Get mapping to delete from cursor to position. Argument x is the position to
" delete to. Argument y represents the current cursor position (note that this
" _must_ be in sync with the real cursor position).
function! s:delete_to(x, y)
  let cmd = ""
  let s = getcmdline()
  let y = a:y
  if y < a:x
    let s:yankbuf = strcharpart(s, y, a:x - y)
    while y < a:x
      let cmd .= "\<del>"
      let y += 1
    endwhile
  else
    let s:yankbuf = strcharpart(s, a:x, y - a:x)
    while a:x < y
      let cmd .= "\b"
      let y -= 1
    endwhile
  endif
  return cmd
endfunction

" Get start position of previous word. Argument x is the position to search
" from.
function! s:prev_word(x)
  let s = getcmdline()
  let x = a:x
  while x > 0 && strcharpart(s, x - 1, 1) !~ s:wordchars
    let x -= 1
  endwhile
  while x > 0 && strcharpart(s, x - 1, 1) =~ s:wordchars
    let x -= 1
  endwhile
  return x
endfunction

" Get start position of previous space delimeted word. Argument x is the
" position to search from.
function! s:prev_longword(x)
  let s = getcmdline()
  let x = a:x
  while x > 0 && strcharpart(s, x - 1, 1) !~ '\S'
    let x -= 1
  endwhile
  while x > 0 && strcharpart(s, x - 1, 1) =~ '\S'
    let x -= 1
  endwhile
  return x
endfunction

" Get end position of next word. Argument x is the position to search from.
function! s:next_word(x)
  let s = getcmdline()
  let n = strchars(s)
  let x = a:x
  while x < n && strcharpart(s, x, 1) !~ s:wordchars
    let x += 1
  endwhile
  while x < n && strcharpart(s, x, 1) =~ s:wordchars
    let x += 1
  endwhile
  return x
endfunction

" Get the current cursor position on the edit line. This differs from
" getcmdpos in that it counts chars intead of bytes and starts counting at 0.
function! s:getcur()
  return strchars((getcmdline() . " ")[:getcmdpos() - 1]) - 1
endfunction
