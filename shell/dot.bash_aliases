# Bash aliases, etc.

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

alias c=clear

# tar
alias untar='tar -zxvf '

# TMP workspace
alias ':WS'='mkdir -p /tmp/myworkspace && cd /tmp/myworkspace'

# aliasing to Python3
alias py=python3
alias ipy=ipython3

function ..() { cd '..'; }
function ...() { cd '../..'; }

# pylint
function Pyl() {
    echo "*** Pylint3 Analysis ***"
    pylint3 -fcolorized \
	    --suggestion-mode=yes -j4 \
	    --rcfile=~/.pylintrc "$1"
    echo "*** End of Pylint3 Analysis ***"
}
