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
IMAGE_HEIGHT = 100             # height of the images/eigenfaces
IMAGE_WIDTH = 100              # width of the images/eigenfaces


###############################################################################
#  Application logic (you shouldn't need to change anything past this point)  #
###############################################################################


from skimage import io
from sklearn.decomposition import RandomizedPCA
import datetime
import errno
import gzip
import numpy as np
import os
import subprocess
import sys
try:
    import cPickle as pickle
except ImportError:
    import pickle


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


def _reshape(image, height, width):
    """Best effort attempt to resize an image into a 1xwidth*height dimensional
    vector. If necessary, the image will be padded horizontally or vertically
    or extra dimensions will be removed.

    """
    desired_shape = (height, width)
    if image.shape != desired_shape:
        actual_height, actual_width = image.shape[:2]
        if len(image.shape) == 3:
            image = image[:, :, 0]
        elif actual_height < height:
            padding = np.zeros((height - actual_height, width))
            image = np.vstack([image, padding])
        elif actual_width < width:
            padding = np.zeros((height, width - actual_width))
            image = np.hstack([image, padding])
        else:
            raise ValueError('unhandled resizing case: ' + str(image.shape))
    return image.reshape(1, height * width)


def compute_eigenfaces(image_paths, n_eigenfaces=NUM_EIGENFACES,
                       width=IMAGE_WIDTH, height=IMAGE_HEIGHT):
    """Finds the eigenfaces of a set of images.

    """
    images = (io.imread(path) for path in image_paths)
    image_matrix = np.vstack([_reshape(image, height, width)
                              for image in images])

    _log('computing %d eigenfaces using %d images'
         % (n_eigenfaces, len(image_matrix)))
    pca = RandomizedPCA(n_components=n_eigenfaces).fit(image_matrix)
    eigenfaces = pca.components_.reshape((n_eigenfaces, height, width))
    eigenvalues = pca.explained_variance_ratio_
    return zip(eigenfaces, eigenvalues), pca


def _imsave(path, matrix):
    """Wrapper around skimage.io.imsave that makes sure that the image location
    is writeable.

    """
    _makedirs(os.path.dirname(path))
    return io.imsave(path, matrix)


def _serialize(obj, path):
    """Serializes an object to disk (pickle, compressed). NB: This method
    ensures that the serialization location is writeable.

    """
    _makedirs(os.path.dirname(path))
    with gzip.open(path, 'wb') as gzip_file:
        pickle.dump(obj, gzip_file)


def plot_eigenfaces(image_paths, data_out=os.path.join(_gitrepo(), DATA_OUT)):
    """Visualizes the eigenfaces of a set of images. Also saves the PCA model
    that created the eigenfaces for future reference.

    """
    eigenfaces, pca = compute_eigenfaces(image_paths)
    for i, (eigenface, eigenvalue) in enumerate(eigenfaces, start=1):
        outpath = os.path.join(data_out, 'eigenface#%s#.png' % eigenvalue)
        _log('saving eigenface %d to %s' % (i, outpath))
        _imsave(outpath, eigenface * 255)

    outpath = os.path.join(data_out, 'pca.pickle.gz')
    _log('saving PCA model to %s' % outpath)
    _serialize(pca, outpath)


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
