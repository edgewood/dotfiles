# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# Create temp directory and check ~/tmp link
if [ ! -d "/tmp/tmp-$USER" ]; then
    mkdir -p "/tmp/tmp-$USER"
    chmod 700 "/tmp/tmp-$USER"
    touch "/tmp/tmp-$USER/.nobackup"
fi

if [ "$( readlink ~/tmp )" != "../../tmp/tmp-$USER" ]; then
    rm -f ~/tmp
    ln -s "../../tmp/tmp-$USER" ~/tmp
fi

# User specific environment and startup programs
PATH=$PATH:$HOME/bin
ENV=$HOME/.bashrc

export ENV PATH

export MAILPATH=

# Disable XON/XOFF flow control in GUI environments
if [ -n "$DISPLAY" ]; then
  stty start ''
  stty stop ''
fi

# point to locate databases inside encrypted space
LOCATE_PATH=""
for p in "$HOME"/.cache/mlocate/*.db; do
  LOCATE_PATH="$LOCATE_PATH:$p"
done
LOCATE_PATH=${LOCATE_PATH##:}	# delete leading : chars

export LOCATE_PATH
