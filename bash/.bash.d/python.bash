
export PYTHONPATH=~/code/lib/python/:

# virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
if [ -f /usr/bin/virtualenvwrapper.sh ] ; then
    . /usr/bin/virtualenvwrapper.sh
fi
