apt-ins ()
{
   local status=$(dpkg -l $1 2>/dev/null | grep -e '^ii')
   if [ -z "$status" ]; then
      echo "NOT INSTALLED"
   else
      echo "INSTALLED:"
      echo "$status"
   fi
}

export PATH=$PATH:$HOME/.local/bin

alias ':c'=clear

# proper bell sound for Emacs
# ref: <https://www.gnu.org/software/emacs/manual/html_node/efaq/Turning-the-volume-down.html>
xset b 2 1 200

# tar
alias untar='tar -zxvf '

alias lh='ls -lh'
# TMP workspace
alias ':WB'="cd $HOME/Workbench"
alias ':T'="cd /tmp"

# Git
alias g="git"

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

# create a new directory and enter it
function mkd() {
   mkdir -p "$@" && cd "$_";
}

# `o` with no arguments opens the current directory, otherwise opens the given location
function o() {
   if [ $# -eq 0 ]; then
      open .;
   else
      open "$@";
   fi;
}
