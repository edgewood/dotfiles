# .bashrc

# Source global definitions.  Do this first so my aliases override globals.
if [ -f /etc/bashrc ]; then
	. /etc/bash.bashrc
fi

export PATH=$PATH:$HOME/bin

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary, update the values
# of LINES and COLUMNS.
shopt -s checkwinsize

# Set prompt

prompt_command() {
    local last_rc="$?"

    # save history immediately
    history -a

    # "(venv) " or ""
    export PS1="${VIRTUAL_ENV:+(${VIRTUAL_ENV##*/}) }"

    # non-printing escape sequences for xterm title
    case "$TERM" in
	screen)
	    # [screen <screen number>: <$title or screen title>] user@host
	    # http://wiki.tldp.org/Xterm-Title for escapes including non-printing
	    # http://aperiodic.net/screen/man:string_escapes for 005 suffixes
	    PS1+="\[\e]0;[screen \005n: ${title:-\005t}] \u@\h\007\]";;
	*)
	    ;;
    esac

    # user@host currdir
    PS1+="[\u@\h \W]"

    # last return code with red chevron if rc is non-zero
    if [ "$last_rc" != 0 ]; then
	# append a red chevron bit with status code
	PS1+="\[\e[0;41;38;5;48;5;155m\]▶"
	PS1+="\[\e[0;41m\] $last_rc \[\e[0m\]"
    fi

    # "$ "
    PS1+="\$ "
}

PROMPT_COMMAND="prompt_command"

# User specific aliases and functions
alias ls='ls --color=tty'
#alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias home='cd ~; clear'
alias bc='\bc ~/.bcrc'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# make 'dirs' easier to parse for a 'pushd x' by printing one-based index
alias dirs="\dirs -p | awk '{print NR-1 \"\t\" \$0}'"

aliases_d="${XDG_CONFIG_HOME:-$HOME/.config}/bash/aliases.d"
if [ -d "$aliases_d" ]; then
  for i in "$aliases_d"/*.aliases; do
    if [ -r $i ]; then
      . $i
    fi
  done
  unset i
fi
unset aliases_d

# smartcase: lowercase search ignores case, uppercase doesn't
# highlight search
# interpret ANSI escapes
# no bell
export LESS="--ignore-case --HILITE-SEARCH --RAW-CONTROL-CHARS --QUIET"
export LESSHISTFILE=~/.cache/less.hst

export RSYNC_RSH=ssh

if [ "$REMOTE" = "1" ]; then
  . ~/.Xdisplay
fi

if tty >/dev/null; then
  case "$(pwd)" in
    */projects/raleighjaycees.org*)
      key=~/.ssh/raleighjaycees
      timeout=300
      ;;
    *)
      key=~/.ssh/id_ecdsa
      timeout=3600
      ;;
  esac

  ssh_add() {
    ssh-add -l | grep "$key" >/dev/null || ssh-add -t "$timeout" "$key" "$@"
  }
  alias ssh='ssh_add /usr/bin/ssh'
  alias ansible-playbook='ssh_add /usr/bin/ansible-playbook'
fi

git() {
    cmd="$1"
    case "$cmd" in
	fetch|pull|push)
	    # ssh-agent is running
	    if [ -n "$SSH_AGENT_PID" ]; then
		# in a Github repo, but agent doesn't hold GH key
		if grep -q github $(git rev-parse --show-toplevel)/.git/config &&
		  ! ssh-add -l | grep -q github; then
		    ssh-add -t 300 ~/.ssh/github
		fi
	    fi
	    ;;
	*);;
    esac
    /usr/bin/git "$@"
}

export EDITOR=vim

# if view isn't vim, and vim exists, alias it
if readlink -f $(which view) | grep -q '\<vim\>'; then
    :
elif [ -f "$(which vim)" ]; then
    alias view=$(which vim)
fi

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
    COMPREPLY=($(compgen -W "add addto append archive command del depri do
    help list listall listcon listfile listpri listproj move prepend pri replace
    report" -- "${word}"))
  else
    # Complete projects and contexts, removing newlines
    COMPREPLY=($(compgen -W "$(echo $(todo lsprj) $(todo lsc))" -- "${word}"))

    # No match, try projects and contexts from 'listall'
    allprjcon=$(. $HOME/.todo/config; export TODO_FILE=$DONE_FILE; todo lsprj; todo lsc)

    COMPREPLY=($(compgen -W "$(echo $allprjcon)" -- "${word}"))
  fi
}

complete -F _mycomplete_todo $todo
complete -F _mycomplete_todo t

# prevent Mono from creating $HOME/.wapi
export MONO_DISABLE_SHM=1
