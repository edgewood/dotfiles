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

export LESS="--ignore-case"	# smartcase: lowercase search ignores case, uppercase doesn't
export LESSHISTFILE=~/.cache/less.hst

export RSYNC_RSH=ssh

if [ "$REMOTE" = "1" ]; then
  . ~/.Xdisplay
fi

alias keychain='/usr/bin/keychain --dir $HOME/.cache/keychain'
alias rjckey='/usr/bin/keychain --dir $HOME/.cache/keychain/rjc'
alias ghkey='/usr/bin/keychain --dir $HOME/.cache/keychain/gh'

if tty >/dev/null; then
  if [ "$(pwd)" = "$HOME/projects/raleighjaycees.org" ]; then
    alias ssh='ssh-add -l >/dev/null || ssh-add ~/.ssh/raleighjaycees; /usr/bin/ssh'
    eval $(rjckey --noinherit --timeout 60 --quiet --nogui --eval --noask)
  else
    alias ssh='ssh-add -l >/dev/null || ssh-add; /usr/bin/ssh'
    eval $(keychain --timeout $((60 * 5)) --quiet --nogui --eval --noask)
  fi
fi

git() {
    cmd="$1"
    case "$cmd" in
	fetch|pull|push)
	    # ssh-agent is running
	    if [ -n "$SSH_AGENT_PID" ]; then
		# ssh-agent is the GH agent, but doesn't hold GH identity
		if grep -q "$SSH_AGENT_PID" ~/.cache/keychain/gh/${HOSTNAME}-sh &&
		  ! ssh-add -l | grep -q github; then
		    ssh-add ~/.ssh/github
		fi
	    fi
	    ;;
	*);;
    esac
    /usr/bin/git "$@"
}

export EDITOR=vim

## History control

export HISTCONTROL=erasedups:ignorespace
export HISTFILESIZE=50000
export HISTSIZE=1000

# window-specific history
histbase="$HOME/.cache/bash_history"
mkdir -p "$histbase"

if [ -n "$WINDOW" ]; then
    export HISTFILE="$histbase/history.$WINDOW"
else
    export HISTFILE="$histbase/history"
fi

# save history immediately
shopt -s histappend
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

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
    # Complete projects and contexts, removing newlines
    COMPREPLY=$(compgen -W "$(echo $(todo lsprj) $(todo lsc))" -- "${word}");

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
