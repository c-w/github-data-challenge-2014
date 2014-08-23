#!/usr/bin/env python2
"""Simple crawler that fetches avatars.

This script uses previously crawled information about GitHub users in JSON to
fetch the avatars of the users.

Usage:
    crawl_avatars.py files...  # fetches all the avatars in the files
"""


###############################################################################
#      Configuration (all paths are relative to the git-repository root)      #
###############################################################################
DATA_OUT = 'data/avatars'   # directory to which to dump the crawled results


###############################################################################
#  Application logic (you shouldn't need to change anything past this point)  #
###############################################################################


import datetime
import errno
import gzip
import json
import os
import requests
import subprocess
import sys


def _urlretrieve(url, filename, adapt_filename=True):
    """Fetches some remote content to disk.

    Arguments:
        url (str): the remote content to fetch
        filename (str): the local path to which to fetch the remote content
        adapt_filename (bool): if True, make sure that the filename has an
            extension that is consistent with the remote file's content-type
            HTTP header

    """
    response = requests.get(url, stream=True)
    response.raise_for_status()

    file_type = '.' + response.headers['content-type'].split('/')[1]
    if adapt_filename and not filename.endswith(file_type):
        filename = filename + file_type

    _makedirs(os.path.dirname(filename))

    with open(filename, 'wb') as local_file:
        for chunk in response.iter_content(chunk_size=1024):
            if chunk:
                local_file.write(chunk)
                local_file.flush()

    return filename


def _makedirs(dirname):
    """Wrapper around os.makedirs that ignores already existing directories.

    """
    try:
        os.makedirs(dirname)
    except OSError as ex:
        if ex.errno != errno.EEXIST:
            raise


def _gitrepo():
    """Returns the path to the current git repository.

    """
    gitcmd = 'git rev-parse --show-toplevel'
    return subprocess.check_output(gitcmd.split()).strip()


def _log(message, channel=sys.stderr):
    """Writes a time-stamped message to stderr.

    """
    now = datetime.datetime.now().strftime('%F%T')
    channel.write('[%s] %s\n' % (now, message.rstrip('\n')))


def fetch_avatars(path, data_out=os.path.join(_gitrepo(), DATA_OUT)):
    """Fetches all the avatars defined in some json.gz file.

    """

    with gzip.open(path) as gzip_file:
        users = json.load(gzip_file)

    for i, user in enumerate(users, start=1):
        avatar_url = user['avatar_url']
        login = user['login']
        filename = _urlretrieve(avatar_url, os.path.join(data_out, login))
        _log('fetched avatar to %s (%d/%d)' % (filename, i, len(users)))


def _main():
    """Command line interface to script.

    """
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('files', nargs='+', help='the json.gz files to crawl')
    args = parser.parse_args()

    for path in args.files:
        fetch_avatars(path)

if __name__ == '__main__':
    _main()
