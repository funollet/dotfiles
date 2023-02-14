" Vim compiler file
" Compiler:     Puppet
" Maintainer:   Jordi Funollet <jordi.f@ati.es>
" Last Change:  2010 Apr 20

if exists('current_compiler')
  finish
endif
let current_compiler = 'puppet'

if exists(":CompilerSet") != 2          " older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

if has('win32') || has('win16') || has('win95') || has('win64')
    setlocal shellpipe=>%s
else
    setlocal shellpipe=>%s\ 2>&1
endif

" CompilerSet makeprg=puppet\ --color=false\ --parseonly\ --ignoreimport\ %
CompilerSet makeprg=puppet\ apply\ --color=false\ --noop\ %

CompilerSet errorformat=err:\ Could\ not\ parse\ for\ environment\ production:\ %m\ at\ %f:%l\ on\ node\ %*\\s

