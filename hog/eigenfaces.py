#!/usr/bin/env python2
"""Eigenface decomposition script.

Usage:
    eigenfaces.py images...  # extracts eigenfaces from the images
"""


###############################################################################
#      Configuration (all paths are relative to the git-repository root)      #
###############################################################################
DATA_OUT = 'data/eigenfaces'   # directory to which to dump the results
NUM_EIGENFACES = 50            # number of eigenfaces to output


###############################################################################
#  Application logic (you shouldn't need to change anything past this point)  #
###############################################################################


from skimage import io
from sklearn.decomposition import RandomizedPCA
import datetime
import errno
import numpy as np
import os
import subprocess
import sys


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


def _load_image_as_vector(path):
    """Loads an image from a path as a vector of pixels. This means that an
    image that is w pixels wide and h pixels heigh will be loaded as a 1x(w*h)
    vector.

    """
    image = io.imread(path)
    width, height = image.shape
    return (width, height), image.reshape(1, (width * height))


def _normalize(matrix):
    """Normalizes a matrix to have zero mean and unit standard deviation.

    """
    return (matrix - matrix.mean()) / matrix.std()


def compute_eigenfaces(image_paths, n_eigenfaces=NUM_EIGENFACES):
    """Finds the eigenfaces of a set of images.

    """
    _log('loading %d images' % len(image_paths))
    images = np.array([io.imread(path) for path in image_paths])
    _, width, height = images.shape
    image_matrix = _normalize(np.vstack([image.reshape(1, width * height)
                                         for image in images]))

    _log('computing %d eigenfaces' % n_eigenfaces)
    pca = RandomizedPCA(n_components=n_eigenfaces).fit(image_matrix)
    eigenfaces = pca.components_.reshape((n_eigenfaces, width, height))
    return eigenfaces


def _imsave(path, matrix):
    """Wrapper around skimage.io.imsave that makes sure that the image location
    is writeable.

    """
    _makedirs(os.path.dirname(path))
    return io.imsave(path, matrix)


def plot_eigenfaces(image_paths, data_out=os.path.join(_gitrepo(), DATA_OUT)):
    """Visualizes the eigenfaces of a set of images.

    """
    eigenfaces = compute_eigenfaces(image_paths)
    for i, eigenface in enumerate(eigenfaces, start=1):
        outpath = os.path.join(data_out, 'eigenface_%d.png' % i)
        _log('saving eigenface %d to %s' % (i, outpath))
        _imsave(outpath, eigenface * 255)


def _main():
    """Command line interface to script.

    """
    import argparse
    parser = argparse.ArgumentParser(description=__doc__.split('Usage:')[0])
    parser.add_argument('files', nargs='+', help='the image files to reduce')
    args = parser.parse_args()

    plot_eigenfaces(args.files)

if __name__ == '__main__':
    _main()
