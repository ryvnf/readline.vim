" ============================================================================
" File:         plugin/readline.vim
" Description:  Readline-style mappings for command mode
" Author:       Elias Astrom <github.com/ryvnf>
" Last Change:  2017 Nov 30
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
cnoremap <expr> <m-b> <sid>move_to(<sid>prev_word('[[:alnum:]]'))
cmap <esc>b <m-b>

" move forward to end of word
cnoremap <expr> <m-f> <sid>move_to(<sid>next_word('[[:alnum:]]'))
cmap <esc>f <m-f>

" delete char under cursor
cnoremap <expr> <c-d> getcmdpos() <= strlen(getcmdline()) ? "\<del>" : ""

" delete back to start of word
cnoremap <expr> <m-bs> <sid>delete_to(<sid>prev_word('[[:alnum:]]'))
cmap <esc><bs> <m-bs>

" delete back to start of white-space delimeted word
cnoremap <expr> <c-w> <sid>delete_to(<sid>prev_word('[^[:space:]]'))

" delete forward to end of word
cnoremap <expr> <m-d> <sid>delete_to(<sid>next_word('[[:alnum:]]'))
cmap <esc>d <m-d>

" delete to start of line
cnoremap <expr> <c-u> <sid>delete_to(0)

" delete to end of line
cnoremap <expr> <c-k> <sid>delete_to(strlen(getcmdline()))

" transpose characters before cursor
cnoremap <expr> <c-t> <sid>transpose()

" yank (paste) previously deleted text
cnoremap <expr> <c-y> <sid>yank()

" list all completion matches
cnoremap <m-?> <c-d>
cmap <esc>? <m-?>

" insert all completion matches
cnoremap <m-*> <c-a>
cmap <esc>* <m-*>

" open cmdline-window
cnoremap <c-x><c-e> <c-f>

"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" internal functions
"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" buffer to hold the previously deleted text
let s:yankbuf = ""

" create mapping to transpose chars
function! s:transpose()
  let l:i = getcmdpos() - 1
  let l:s = getcmdline()
  let l:n = strlen(l:s)
  let l:cmd = ""
  if l:i == 0 || l:n < 2
    return ""
  endif
  if l:i == l:n
    let l:cmd .= "\<left>"
    let l:i -= 1
  endif
  return l:cmd . "\b\<right>" . l:s[l:i - 1]
endfunction

" create mapping to move to position x
function! s:move_to(x)
  let l:cmd = ""
  let l:i = a:x - (getcmdpos() - 1)
  if l:i > 0
    while l:i != 0
      let l:cmd .= "\<right>"
      let l:i -= 1
    endwhile
  else
    while l:i != 0
      let l:cmd .= "\<left>"
      let l:i += 1
    endwhile
  endif
  return l:cmd
endfunction

" create mapping to delete to position x
function! s:delete_to(x)
  let l:cmd = ""
  let l:i = a:x - (getcmdpos() - 1)
  if l:i > 0
    let s:yankbuf = getcmdline()[getcmdpos():a:x]
    while l:i != 0
      let l:cmd .= "\<del>"
      let l:i -= 1
    endwhile
  else
    let s:yankbuf = getcmdline()[a:x:getcmdpos()]
    while l:i != 0
      let l:cmd .= "\b"
      let l:i += 1
    endwhile
  endif
  return l:cmd
endfunction

" create mapping to yank (paste) the previously deleted text
function! s:yank()
  return s:yankbuf
endfunction

" get position of previous longword
function! s:prev_word(wordchars)
  let l:s = getcmdline()
  let l:i = getcmdpos() - 1
  while l:i > 0 && l:s[l:i - 1] !~ a:wordchars
    let l:i -= 1
  endwhile
  while l:i > 0 && l:s[l:i - 1] =~ a:wordchars
    let l:i -= 1
  endwhile
  return l:i
endfunction

" get position of next word
function! s:next_word(wordchars)
  let l:s = getcmdline()
  let l:n = strlen(l:s)
  let l:i = getcmdpos() - 1
  while l:i < l:n && l:s[l:i] !~ a:wordchars
    let l:i += 1
  endwhile
  while l:i < l:n && l:s[l:i] =~ a:wordchars
    let l:i += 1
  endwhile
  return l:i
endfunction
