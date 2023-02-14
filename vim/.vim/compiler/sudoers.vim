" Vim compiler file
" Compiler:     Sudoers
" Maintainer:   Jordi Funollet <jordi.f@ati.es>
" Last Change:  2010 Oct 8

if exists('current_compiler')
  finish
endif
let current_compiler = 'sudoers'

if exists(":CompilerSet") != 2          " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

if has('win32') || has('win16') || has('win95') || has('win64')
    setlocal shellpipe=>%s
else
    setlocal shellpipe=>%s\ 2>&1
endif

CompilerSet makeprg=visudo\ -c\ -f\ %

