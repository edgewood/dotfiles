import atexit
import os
import readline

# Command line history:
histfile = os.path.expanduser("~/.cache/pdb_history")

try:
    readline.read_history_file(histfile)
except IOError:
    pass


def savehist(histfile=histfile):
    import os
    import readline

    histfilesize = os.environ.get('HISTFILESIZE') \
        or os.environ.get('HISTSIZE') or '500'
    if histfilesize:
        try:
            histfilesize = int(histfilesize)
        except ValueError:
            pass
        else:
            readline.set_history_length(histfilesize)
    readline.write_history_file(histfile)

atexit.register(savehist)

# http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/498182
import pdb
import rlcompleter
pdb.Pdb.complete = rlcompleter.Completer().complete

# Cleanup any variables that could otherwise clutter up the namespace.
del atexit, os, pdb, readline, rlcompleter, savehist
