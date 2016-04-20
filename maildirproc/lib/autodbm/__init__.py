# Adapted from TMDA/Util.py and TMDA/FilterParser.py in TMDA
# svn://svn.code.sf.net/p/tmda/code/trunk
#
# Original code is Copyright (C) 2001-2007 Jason R. Mastaler <jason@mastaler.com>
# Original authors: Tim Legant <tim@catseye.net> and
#                   Jason R. Mastaler <jason@mastaler.com>
# Adaptation for standalone use is copyright 2014 Ed Blackman <ed@edgewood.to>
#
# License: GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

__all__ = ['open']

import dbm
import os
import builtins

def open(basename, flag = 'r', mode = 0o666):
    dbname = __autobuild_db(basename, '.db', '.last_built', __build_dbm, mode)

    return dbm.open(dbname, flag, mode)


def __cache_dir():
    cache_home = os.environ.get('XDG_CACHE_HOME', os.path.expanduser("~/.cache"))
    cache_dir = os.path.join(cache_home, 'autodbm')

    if not os.path.exists(cache_dir):
        os.makedirs(cache_dir)

    return cache_dir


def __db_name(filename, extension):
    _, dbmname = os.path.split(filename)

    return os.path.join(__cache_dir(), dbmname + extension)


def __surrogate_name(filename, extension):
    _, surname = os.path.split(filename)

    return os.path.join(__cache_dir(), surname + extension)


def __autobuild_db(basename, extension, surr_ext, build_func, mode):
    """
    Automatically build a DBM database if it's out-of-date.
    """
    dbname = __db_name(basename, extension)
    surrogate = __surrogate_name(basename, surr_ext)

    try:
        txt_mtime = os.path.getmtime(basename)
    except OSError:
        raise
    else:
        # If the db doesn't exist, that's not an error.
        try:
            db_mtime = os.path.getmtime(surrogate)
        except OSError:
            db_mtime = 0
        if db_mtime <= txt_mtime:
            build_func(basename, mode)
            if os.path.exists(surrogate):
                os.utime(surrogate, None)
            else:
                os.close(os.open(surrogate, os.O_CREAT, 0o600))
    return dbname


def __build_dbm(filename, mode):
    """Build a DBM file from a text file."""
    def uncommented(file):
        """Generator that strips comments and blank lines while reading a file."""
        with builtins.open(file, encoding='utf-8') as f:
            for line in f:
                # remove inline comments
                line = line.strip().expandtabs().split('#')[0].strip()
                # skip blank lines
                if line == '':
                    pass
                else:
                    yield line
    import glob
    import tempfile
    _, dbmname = os.path.split(filename)
    dbmname += '.db'
    tempfile.tempdir = __cache_dir()
    tmpname = tempfile.mktemp()
    db = dbm.open(tmpname, 'n', mode)
    for line in uncommented(filename):
        linef = line.split(None, 1) # split on whitespace into two pieces
        key = linef[0]
        try:
            value = linef[1]
        except IndexError:
            value = ''
        db[key] = value
    db.close()
    for f in glob.glob(tmpname + '*'):
        (tmppath, tmpname) = os.path.split(tmpname)
        newf = f.replace(tmpname, dbmname)
        newf = os.path.join(tmppath, newf)
        os.rename(f, newf)

