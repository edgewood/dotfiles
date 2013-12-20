# .bashrc

# Source global definitions.  Do this first so my aliases override globals.
if [ -f /etc/bashrc ]; then
	. /etc/bash.bashrc
fi

export PATH=$PATH:$HOME/bin
export PS1='[${debian_chroot:+($debian_chroot)}\u@\h \W]\$ '

if [ $TERM != linux ]; then
  export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
fi

# User specific aliases and functions
alias ls='ls --color=tty'
#alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias home='cd ~; clear'
alias bc='\bc ~/.bcrc'

export RSYNC_RSH=ssh

if [ "$REMOTE" = "1" ]; then
  . ~/.Xdisplay
fi

if tty >/dev/null; then
  . $HOME/bin/keychainStartup

  # background process startup
  if ! ps -fC python | grep -q EyeFiServer.py; then
    ( cd "$HOME/projects/EyeFiServer/Release 2.0"; detach python EyeFiServer.py -c edgewood.ini )
  fi
fi

export EDITOR=vim

## History control

export HISTCONTROL=erasedups
export HISTFILESIZE=50000
export HISTSIZE=1000

# use a separate file for screen windows 1 and 2
rjchist="$HOME/projects/rjchistory.txt"

[ "$WINDOW" = "1" -a -e "$rjchist" ] && { HISTFILE="$rjchist"; }
[ "$WINDOW" = "2" -a -e "$rjchist" ] && { HISTFILE="$rjchist"; }

## Completions

# todo

# use the name you invoke todo.sh with on the command line (eg, replace with t
# if you alias todo to t
todo=todo

# bash completions for todo
_mycomplete_todo()
{
  local cmd=${COMP_CWORD} #Where in the command are we?
  local word=${COMP_WORDS[COMP_CWORD]} #What have we got so far?
  if ((cmd==1)); then
    # Complete list of functions
    # FIXME:Generate automatically
    COMPREPLY=$(compgen -W "add addto append archive command del depri do
    help list listall listcon listfile listpri listproj move prepend pri replace
    report" -- "${word}");
  else
    # Complete projects and contexts
    COMPREPLY=$(compgen -W "$(todo lsprj) $(todo lsc)" -- "${word}");

    # No match, try to turn text into an item number
    if [ -z "$COMPREPLY" ]; then
      IFS=$'\n' # Split on carriage return only
      # FIXME:A more "raw" todo ls would be better here
      COMPREPLY=$(todo -p ls | grep "${word}")
      unset IFS; # Restore default value

      if ((${#COMPREPLY[@]}==1)); then
        # Only one project matched, so replace text with item number
        local -a item=${COMPREPLY[0]};
        COMPREPLY=${item[0]};
      fi
    fi
  fi
}

complete -F _mycomplete_todo $todo
complete -F _mycomplete_todo t

# prevent Mono from creating $HOME/.wapi
export MONO_DISABLE_SHM=1
