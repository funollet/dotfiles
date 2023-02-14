" Vim syntax file loader
" Language:    Twill
" Maintainer:  Andy Chambers
" Last Change: 2006 November 15
" Version:     1.0
" Remark:      Like shell (just with added keywords)

if version < 600
    syntax clear
elseif exists("b:current_syntax")
    finish
endif

" twill is mostly like shell with some extra keywords
runtime! syntax/sh.vim.

syn keyword twillCommand go back reload follow
syn keyword twillCommand code find notfind url title
syn keyword twillCommand echo redirect_output reset_output save_html.
syn keyword twillCommand submit formvalue fv formaction fa formclear formfile
syn keyword twillCommand save_cookies load_cookies clear_cookies show_cookies
syn keyword twillCommand debug show showlinks showforms showhistory
syn keyword twillCommand setglobal setlocal reset_browser extend_with getinput
syn keyword twillCommand tidy_ok exit run runfile agent sleep.
syn keyword twillCommand getpassword add_auth config

syn match twillString /".*"/

" Define the default highlighting.
" For version 5.x and earlier, only when not done already.
" For version 5.8 and later, only when an item doesn't have highlighting yet.
if version >= 508 || !exists("did_twill_syn_inits")
  if version < 508
    let did_twill_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink twillCommand Keyword
  HiLink twillString String

  delcommand HiLink
endif

let b:current_syntax = "twill"

