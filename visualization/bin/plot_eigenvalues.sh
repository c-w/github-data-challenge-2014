#!/bin/bash
# This script visualizes the cumulative eigen-values associated with the
# eigen-faces we inferred earlier.
#
# The shape of this plot gives us an indication of how much variance there is in
# the data and how well the eigen-face decomposition works: the fewer principal
# components (here: eigen-faces) we need to explain most of the variance in the
# data, the better.
#
# Usage:
#   plot_eigenvalues.sh


###############################################################################
#      Configuration (all paths are relative to the git-repository root)      #
###############################################################################
EIGENFACES_DIR='visualization/eigenfaces'
EIGENFACES_EXT='png'
PLOT_OUT='visualization/eigenvalues.png'


###############################################################################
#  Application logic (you shouldn't need to change anything past this point)  #
###############################################################################


REPO_ROOT="$(readlink -f $(git rev-parse --show-toplevel))"
EIGENFACES_DIR="${REPO_ROOT}/${EIGENFACES_DIR}"
PLOT_OUT="${REPO_ROOT}/${PLOT_OUT}"

parse_eigenvalues() {
    local tmppath="$(mktemp)"

    ls "${EIGENFACES_DIR}"/*.${EIGENFACES_EXT} \
    | sed "s&.${EIGENFACES_EXT}$&&" \
    | sed "s@^${EIGENFACES_DIR}/@@" \
    | sort -rn \
    > "${tmppath}"

    echo "${tmppath}"
}

plot_eigenvalues() {
    local eigenvalues="$1"
    local num_eigenvalues="$(wc -l ${eigenvalues} | cut -f1 -d' ')"

    gnuplot -e "
        set terminal ${EIGENFACES_EXT};
        set output '${PLOT_OUT}';
        set xlabel 'number of principal components';
        set ylabel 'percent variance explained';
        set yrange [0:100];
        set xrange [1:${num_eigenvalues}];
        unset key;
        plot '${eigenvalues}' smooth cumulative;
    "
}

main() {
    # enable strict mode
    set -o errexit
    set -o nounset
    set -o pipefail

    # plot the eigenvalues
    eigenvalues="$(parse_eigenvalues)"
    plot_eigenvalues "${eigenvalues}"

    # cleanup
    rm "${eigenvalues}"
}

main "$@"
