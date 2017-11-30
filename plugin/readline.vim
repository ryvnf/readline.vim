" ============================================================================
" File:         plugin/readline.vim
" Description:  Readline-style mappings for command mode
" Author:       Elias Astrom <github.com/ryvnf>
" Last Change:  2017 Nov 30
" Licence:      The VIM-LICENSE.  This Plugin is  distributed under the same
"               conditions as VIM itself.
" ============================================================================

" navigation
cnoremap <c-a> <home>
cnoremap <c-e> <end>
cnoremap <c-b> <left>
cnoremap <c-f> <right>
cnoremap <expr> <m-b> <sid>move_to(<sid>back_word())
cnoremap <expr> <m-f> <sid>move_to(<sid>forward_word())

" deletion
cnoremap <expr> <c-d> getcmdpos() <= strlen(getcmdline()) ? "\<del>" : ""
cnoremap <expr> <m-d> <sid>delete_to(<sid>forward_word())
cnoremap <expr> <m-bs> <sid>delete_to(<sid>back_word())
cnoremap <expr> <c-w> <sid>delete_to(<sid>back_longword())
cnoremap <expr> <c-u> <sid>delete_to(0)
cnoremap <expr> <c-k> <sid>delete_to(strlen(getcmdline()))

" other
cnoremap <expr> <c-t> <sid>transpose()
cnoremap <m-*> <c-a>
cnoremap <c-x><c-e> <c-f>

" ESCAPE as META
cmap <esc>b <m-b>
cmap <esc>f <m-f>
cmap <esc>d <m-d>
cmap <esc><bs> <m-bs>
cmap <esc>* <m-*>

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
    while l:i != 0
      let l:cmd .= "\<del>"
      let l:i -= 1
    endwhile
  else
    while l:i != 0
      let l:cmd .= "\b"
      let l:i += 1
    endwhile
  endif
  return l:cmd
endfunction

" get position of previous word
function! s:back_word()
  let l:s = getcmdline()
  let l:i = getcmdpos() - 1
  while l:i > 0 && l:s[l:i - 1] !~ '\a'
    let l:i -= 1
  endwhile
  while l:i > 0 && l:s[l:i - 1] =~ '\a'
    let l:i -= 1
  endwhile
  return l:i
endfunction

" get position of previous longword
function! s:back_longword()
  let l:s = getcmdline()
  let l:i = getcmdpos() - 1
  while l:i > 0 && l:s[l:i - 1] =~ '\s'
    let l:i -= 1
  endwhile
  while l:i > 0 && l:s[l:i - 1] !~ '\s'
    let l:i -= 1
  endwhile
  return l:i
endfunction

" get position of next word
function! s:forward_word()
  let l:s = getcmdline()
  let l:n = strlen(l:s)
  let l:i = getcmdpos() - 1
  while l:i < l:n && l:s[l:i - 1] !~ '[:alnum:]'
    let l:i += 1
  endwhile
  while l:i < l:n && l:s[l:i - 1] =~ '[:alnum:]'
    let l:i += 1
  endwhile
  return l:i
endfunction
