# Useful bash aliases
# used by .bashrc

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

# proper bell sound for Emacs
# ref: <https://www.gnu.org/software/emacs/manual/html_node/efaq/Turning-the-volume-down.html>
xset b 2 1 200

# useful aliases
alias lh="ls -lh"
alias c=clear

# apt
alias 'apt-up'="sudo apt update && apt list --upgradable"

# tar
alias untar='tar -zxvf '

# TMP workspace
alias ':WB'="cd $HOME/Workbench"
alias ':T'="cd /tmp"

# git
alias g=git

# aliasing to Python3
alias p=python3
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
function mkcd() {
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