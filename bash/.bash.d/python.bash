# virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
if [ -f /usr/bin/virtualenvwrapper.sh ] ; then
    . /usr/bin/virtualenvwrapper.sh
fi

# pipenv creates virtualenv in the project directory,
# instead of under ~/.virtualenvs/
export PIPENV_VENV_IN_PROJECT=1
