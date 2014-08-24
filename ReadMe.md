# Humans of GitHub (HoG)

## Introduction

This repository is an entry to the [Third Annual GitHub Data
Challenge](https://github.com/blog/1864-third-annual-github-data-challenge).

We use the GitHub [Users API](https://developer.github.com/v3/users/) in order
to acquire a large collection of user avatars. User avatars! A pointed
expression of individualism; A mirror into the users' soul. We then use
dimensionality reduction techniques in order to explore if there are any
similarities or re-occurring patterns in the user avatars, thus answering the
eternal question of *Who really uses GitHub?* Who are the Humans of GitHub? Cats
with eight tentacles?  Unicorns? Ninjas? This visualization finally brings
answers!

## Usage

[Eigenfaces](http://jeremykun.com/2011/07/27/eigenfaces/) are a straight-forward
and highly interpretable way to find structure and patterns in large collections
of images.  So that's the first technique we are going to use to explore the
"Humans of GitHub".

We need to do four simple things to get GitHub user eigen-faces.

But before we get started, we first need to do some admin work. You'll want to
create an [OAuth
Token](https://help.github.com/articles/creating-an-access-token-for-command-line-use)
and copy it into a file named *oauth.txt* in the top-level directory of this
repository. Then, have a peek around the scripts in the *hog/* directory (no,
nothing to do with pigs - that's short for "Humans of GitHub", you silly).
There are some configuration options at the top of each script that you'll want
to review and adapt if you deem it necessary.

Now we're ready to rock and create some eigen-faces!

1. Now, we crawl the /users API and grab some meta-data about people on
   GitHub. Amongst others, this meta-data contains a link to every user's avatar
   that we'll use to get some image data in a minute. The following snippet
   downloads 5000 batches of JSON user information (starting from the first)
   from the API and stores them gzipped on disk at *data/users*. Every batch
   contains information about 100 users, so this will give us a sizeable
   data-set to work with.

    `./hog/crawl_users.sh 0 5000`

2. We then use the previoulsy acquired meta-information to collect a large
   number of avatars of GitHub users. The following snippet retrieves the avatar
   of ever user we queried from the API and stores it at *data/avatars*.

    `./hog/crawl_avatars.py data/users/*.json.gz`

3. Next up, we apply some preprocessing to make sure that all avatars are roughly
   comparable. The following snippet converts all avatars to PNG, rescales them
   to 100x100 pixels and converts them to grayscale. The first operation really
   just is convenience to not have to deal with multiple image formats later.
   The later two operations make the rest of the eigen-face inference problem
   more tractable by reducing the dimensionality of our data-set. The script
   also filters out any GitHub auto-generated avatars. Note: the avatars are
   edited in-place i.e. the original full-size and full-color avatars are
   removed in favor of their new low-pixel grayscale versions.

    `./hog/preprocess_avatars.sh data/avatars/*`

4. Finally, we can use Principal Component Analysis to perform eigen-face
   decomposition! The following snippet loads every 100x100 image in our
   data-set as a 10000x1-dimensional vector, bunches them together into a matrix
   and applies PCA. The top-50 principal components are then unrolled into
   images and output to *data/eigenfaces*. The eigen-faces adhere to the
   following naming convention: *eigenface#0.[0-9]+#.png* where the numbers
   indicate the percentage of variance explained by the principal component
   corresponding to the eigen-face. This naming convention allows us to analyze
   the principal components we acquired through PCA, for example by graphing how
   many eigen-faces we need to explain 95% of the variance in the data.

    `./hog/eigenfaces.py data/avatars/*.png`

    `./hog/visualize_eigenvalues.sh eigenvalues.png data/eigenfaces`

## Dependencies

- Python 2.7: sklearn, skimage, numpy, requests
- cURL
- ImageMagick
- GNUplot
