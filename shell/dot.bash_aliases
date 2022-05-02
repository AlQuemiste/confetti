# Bash aliases, etc.

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

alias c=clear

# proper bell sound for Emacs
# ref: <https://www.gnu.org/software/emacs/manual/html_node/efaq/Turning-the-volume-down.html>
xset b 2 1 200

# tar
alias untar='tar -zxvf '

# TMP workspace
alias ':WB'="cd $HOME/Workbench"

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

function pkginstall ()
# check package status (installed or not installed) and install it via
# apt-get, if not installed.
{
  status=$(dpkg -l "$1" 2>/dev/null | grep -e "^ii")
  if [ ! -z "$status" ]; then
     apt-get install "$1"
  else
     echo "Package '$1' is already installed:"
     echo "$status"
  fi
}
