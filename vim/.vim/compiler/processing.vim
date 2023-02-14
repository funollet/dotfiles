" Vim compiler file
" Compiler:     Processing
" Maintainer:   Jordi Funollet <jordi.f@ati.es>
" Last Change:  2013 Jan 8

if exists('current_compiler')
  finish
endif
let current_compiler = 'processing'

if exists(":CompilerSet") != 2          " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

if has('win32') || has('win16') || has('win95') || has('win64')
    setlocal shellpipe=>%s
else
    setlocal shellpipe=>%s\ 2>&1
endif

autocmd BufWritePost <buffer> make

"eruby templates syntax validation
" >>> pim.erb: syntax error near line 1 <<<
" >>> pim.erb: syntax error near line 2 <<<
" >>> pim.erb: syntax error near line 2 <<<
" parse error in pim.erb near line 1
CompilerSet makeprg=processing-java\ --output=/tmp/processing\ --sketch=%:p:h\ --run\ --force


CompilerSet errorformat=\(%n\ of %*\): %l:%c: %m
" (4 of 4): 26:4: Syntax error, maybe a missing semicolon?
"
" CompilerSet errorformat=-:%l:%m
" -:3: syntax error, unexpected '<', expecting $end
"    <% pam ; _erbout.concat "\n"
"     ^

