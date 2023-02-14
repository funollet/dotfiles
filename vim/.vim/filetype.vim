if exists("did\_load\_filetypes")
 finish
endif

au! BufRead,BufNewFile sudoers       set ft=sudoers
au! BufRead,BufNewFile monitrc*      set ft=conf
au! BufRead,BufNewFile *.mkd         set ft=markdown
au! BufRead,BufNewFile *.md          set ft=markdown
au! BufRead,BufNewFile *.twill       set ft=twill
au! BufRead,BufNewFile *.json        set ft=json
au! BufRead,BufNewFile haproxy*      set ft=haproxy
au! BufRead,BufNewFile Jenkinsfile   set ft=groovy
au! BufNewFile,BufRead template.yml  set ft=yaml.cloudformation

au! BufNewFile,BufRead /*etc/nagios{,2,3,plugins}/*.cfg,*sample-config/template-object/*.cfg{,.in},/var/lib/nagios/objects.cache,/usr/local/nagios*/* set ft=nagios
au! BufRead,BufNewFile /etc/nginx/*  set ft=nginx
au! BufRead,BufNewFile $HOME/workingon/cheat/*  set ft=markdown
