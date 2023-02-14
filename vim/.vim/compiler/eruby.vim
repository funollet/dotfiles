" Vim compiler file
" Compiler:     Eruby
" Maintainer:   Jordi Funollet <jordi.f@ati.es>
" Last Change:  2010 Oct 8

if exists('current_compiler')
  finish
endif
let current_compiler = 'eruby'

if exists(":CompilerSet") != 2          " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

if has('win32') || has('win16') || has('win95') || has('win64')
    setlocal shellpipe=>%s
else
    setlocal shellpipe=>%s\ 2>&1
endif

" eruby templates syntax validation
" >>> pim.erb: syntax error near line 1 <<<
" >>> pim.erb: syntax error near line 2 <<<
" >>> pim.erb: syntax error near line 2 <<<
" parse error in pim.erb near line 1
CompilerSet makeprg=erb\ -xT\ -\ %\ \\\|\ ruby\ -c \ 2>&1\ \\\|\ grep\ ^- 

CompilerSet errorformat=-:%l:%m
" -:3: syntax error, unexpected '<', expecting $end
"    <% pam ; _erbout.concat "\n"
"     ^

