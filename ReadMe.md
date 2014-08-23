# Humans of GitHub (HoG)

## Introduction

This entry to the [Third Annual GitHub Data
Challenge](https://github.com/blog/1864-third-annual-github-data-challenge)
offers a visual exploration of the question *who uses GitHub*. In the past,
GitHub's user-base has been analyzed by exploring various social graphs inferred
using the site's [API](https://developer.github.com/v3/). Our approach adds a
human component to user-data mining by *putting a face to the name*. We propose
a visualization that uses the GitHub [Users
API](https://developer.github.com/v3/users/) to infer eigen-faces for the
"Humans of GitHub". Using these characteristic dimensions of the face-space, we
further explore whether there are any strong patterns in the avatars of GitHub
users.


## Dependencies

- Python 2.7: scipy, sklearn, skimage, PIL, matplotlib, requests
- cURL
- ImageMagick
