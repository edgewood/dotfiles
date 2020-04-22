# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.

# Get the aliases and functions
# Source bashrc only if running bash. Might not be on old systems.
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi
if [ -f ~/.config/gpodder/rc ]; then
	. ~/.config/gpodder/rc
fi

# clear ssh-agent keys on login
ssh-add -D

# Create temp directory and check ~/tmp link
usertemp="/tmp/tmp-$USER"
if [ ! -d "$usertemp" ]; then
    mkdir -p "$usertemp"
    chmod 700 "$usertemp"
    touch "$usertemp/.nobackup"
fi

if [ "$( readlink ~/tmp )" != "../../tmp/tmp-$USER" ]; then
    rm -f ~/tmp
    ln -s "../../tmp/tmp-$USER" ~/tmp
fi
unset usertemp

# create temp directory for vim swap files that persists across reboots
# requires 'set directory=/var/tmp/vim-$USER,'... in .vimrc
usertemp="/var/tmp/vim-$USER"
if [ ! -d "$usertemp" ]; then
    mkdir -p "$usertemp"
    chmod 700 "$usertemp"
    touch "$usertemp/.nobackup"
fi
unset usertemp

# User specific environment and startup programs
# include SAS U-drive bin if it exists
if [ -d "/u/edblac/bin" ]; then
    PATH="/u/edblac/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# add locally-installed Go in PATH if it exists
if [ -d "/usr/local/go/bin" ]; then
    PATH="$PATH:/usr/local/go/bin"
fi

export PATH
export MAILPATH=

# Disable XON/XOFF flow control in GUI environments
if [ -n "$DISPLAY" ]; then
  stty start ''
  stty stop ''
fi

# point to locate databases inside encrypted space
LOCATE_PATH="$(find ~/.cache/mlocate/ -name \*.db -printf "%p:" 2>/dev/null)"
LOCATE_PATH=${LOCATE_PATH%:}	# delete trailing ':'

if [ -n "$LOCATE_PATH" ]; then
  export LOCATE_PATH
else
  unset LOCATE_PATH
fi

# awscli: set environment variables to emulate use of XDG
# https://github.com/aws/aws-cli/issues/2433
if [ -x /usr/bin/aws ] || [ -x /usr/bin/s3cmd ]; then
  export AWS_SHARED_CREDENTIALS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}"/aws/credentials
  export AWS_CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}"/aws/config
  # s3cmd uses the old AWS variable to find the credentials file
  # https://github.com/s3tools/s3cmd/issues/1027
  export AWS_CREDENTIAL_FILE="$AWS_SHARED_CREDENTIALS_FILE"
fi
