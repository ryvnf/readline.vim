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
let s:wordchars = '[[:upper:][:lower:][:digit:]]'

" buffer to hold the previously deleted text
let s:yankbuf = ""

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" internal functions
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" get mapping to transpose chars
function! s:transpose_chars()
  let l:s = getcmdline() . " " " space so cursor can be at end
  let l:x = strchars(l:s[:getcmdpos() - 1]) - 1
  let l:n = strchars(l:s)
  let l:cmd = ""
  if l:x == 0 || l:n < 2
    return ""
  endif
  if l:x == l:n - 1
    let l:cmd .= "\<left>"
    let l:x -= 1
  endif
  return l:cmd . "\<bs>\<right>\<c-v>" . strcharpart(l:s, l:x - 1, 1)
endfunction

" get mapping to move to position x
function! s:move_to(x)
  let l:cmd = ""
  let l:y = strchars((getcmdline() . " ")[:getcmdpos() - 1]) - 1
  if l:y < a:x
    while l:y < a:x
      let l:cmd .= "\<right>"
      let l:y += 1
    endwhile
  else
    while a:x < l:y
      let l:cmd .= "\<left>"
      let l:y -= 1
    endwhile
  endif
  return l:cmd
endfunction

" get mapping to delete to position x
function! s:delete_to(x)
  let l:cmd = ""
  let l:s = getcmdline() . " " " space so cursor can be at end
  let l:x = a:x
  let l:y = strchars(l:s[:getcmdpos() - 1]) - 1
  let s:yankbuf = ""
  if l:y < l:x
    while l:y < l:x
      let l:cmd .= "\<del>"
      let s:yankbuf .= "\<c-v>" . strcharpart(l:s, l:y, 1)
      let l:y += 1
    endwhile
  else
    while l:x < l:y
      let l:cmd .= "\<bs>"
      let s:yankbuf .= "\<c-v>" . strcharpart(l:s, l:x, 1)
      let l:x += 1
    endwhile
  endif
  return l:cmd
endfunction

" get mapping to make word uppercase
function! s:upcase_word()
  let l:cmd = ""
  let l:s = getcmdline() . " " " space so cursor can be at end
  let l:x = s:forward_word()
  let l:y = strchars(l:s[:getcmdpos() - 1]) - 1
  let s:yankbuf = ""
  while l:y < l:x
    let l:cmd .= "\<del>\<c-v>" . toupper(strcharpart(l:s, l:y, 1))
    let l:y += 1
  endwhile
  return l:cmd
endfunction

" get mapping to make word lowercase
function! s:downcase_word()
  let l:cmd = ""
  let l:s = getcmdline() . " " " space so cursor can be at end
  let l:x = s:forward_word()
  let l:y = strchars(l:s[:getcmdpos() - 1]) - 1
  let s:yankbuf = ""
  while l:y < l:x
    let l:cmd .= "\<del>\<c-v>" . tolower(strcharpart(l:s, l:y, 1))
    let l:y += 1
  endwhile
  return l:cmd
endfunction

" get mapping to make word capitalized
function! s:capitalize_word()
  let l:cmd = ""
  let l:s = getcmdline() . " " " space so cursor can be at end
  let l:x = s:forward_word()
  let l:y = strchars(l:s[:getcmdpos() - 1]) - 1
  let s:yankbuf = ""
  while l:y < l:x
    let l:c = strcharpart(l:s, l:y, 1)
    let l:y += 1
    if l:c =~ s:wordchars
      let l:cmd .= "\<del>\<c-v>" . toupper(strcharpart(l:s, l:y - 1, 1))
      break
    else
      let l:cmd .= "\<right>"
    endif
  endwhile
  while l:y < l:x
    let l:cmd .= "\<del>\<c-v>" . tolower(strcharpart(l:s, l:y, 1))
    let l:y += 1
  endwhile
  return l:cmd
endfunction

" get mapping to yank (paste) the previously deleted text
function! s:yank()
  return s:yankbuf
endfunction

" get word start position behind cursor
function! s:back_word()
  let l:s = getcmdline() . " " " space so cursor can be at end
  let l:x = strchars(l:s[:getcmdpos() - 1]) - 1
  while l:x > 0 && strcharpart(l:s, l:x - 1, 1) !~ s:wordchars
    let l:x -= 1
  endwhile
  while l:x > 0 && strcharpart(l:s, l:x - 1, 1) =~ s:wordchars
    let l:x -= 1
  endwhile
  return l:x
endfunction

" get longword start position behind cursor
function! s:back_longword()
  let l:s = getcmdline() . " " " space so cursor can be at end
  let l:x = strchars(l:s[:getcmdpos() - 1]) - 1
  while l:x > 0 && strcharpart(l:s, l:x - 1, 1) =~ '[[:space:]]'
    let l:x -= 1
  endwhile
  while l:x > 0 && strcharpart(l:s, l:x - 1, 1) !~ '[[:space:]]'
    let l:x -= 1
  endwhile
  return l:x
endfunction

" get word end position in front of cursor
function! s:forward_word()
  let l:s = getcmdline() . " " " space so cursor can be at end
  let l:n = strchars(l:s)
  let l:x = strchars(l:s[:getcmdpos() - 1]) - 1
  while l:x < l:n && strcharpart(l:s, l:x, 1) !~ s:wordchars
    let l:x += 1
  endwhile
  while l:x < l:n && strcharpart(l:s, l:x, 1) =~ s:wordchars
    let l:x += 1
  endwhile
  return l:x
endfunction
