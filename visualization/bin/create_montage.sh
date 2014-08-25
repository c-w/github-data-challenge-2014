#!/bin/bash
# Script to collate eigenfaces into one pretty overall visualization.
#
# Usage:
#   create_montage.sh   # creates a montage of all the eigenfaces


###############################################################################
#      Configuration (all paths are relative to the git-repository root)      #
###############################################################################
EIGENFACES_DIR='visualization/eigenfaces'
EIGENFACES_EXT='png'
MONTAGE_LAYOUT='5x4'
MONTAGE_PADDING='+4+4'
MONTAGE_TITLE='Eigenfaces of GitHub'
MONTAGE_LABELS='%t%%'
MONTAGE_OUT='visualization/montage.png'


###############################################################################
#  Application logic (you shouldn't need to change anything past this point)  #
###############################################################################


REPO_ROOT="$(readlink -f $(git rev-parse --show-toplevel))"
EIGENFACES_DIR="${REPO_ROOT}/${EIGENFACES_DIR}"
MONTAGE_OUT="${REPO_ROOT}/${MONTAGE_OUT}"

create_montage() {
    montage \
        -polaroid 0 \
        -geometry "${MONTAGE_PADDING}" \
        -tile "${MONTAGE_LAYOUT}" \
        -title "${MONTAGE_TITLE}" \
        -label "${MONTAGE_LABELS}" \
        $(ls "${EIGENFACES_DIR}"/*.${EIGENFACES_EXT} | sort -rn) \
        "${MONTAGE_OUT}"
}

main() {
    # enable strict mode
    set -o errexit
    set -o nounset
    set -o pipefail

    # collate eigenfaces
    create_montage
}

main "$@"
