# enable auto-completion <https://zsh.sourceforge.io/Doc/Release/Completion-System.html#Completion-System>

autoload -Uz compinit && compinit

# bind keys
# NOTE: use `cat` to discover key codes
# <https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Zsh-Line-Editor>
bindkey  "^[[H"   beginning-of-line  # Home
bindkey  "^[[F"   end-of-line  # End
bindkey  "^[[1;3D" backward-word  # Alt + Right-Arrow
bindkey  "^[[1;3C" forward-word   # Alt + Right-Arrow
