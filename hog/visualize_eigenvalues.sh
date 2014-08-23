#!/bin/bash
# This script visualizes the cumulative eigen-values associated with the
# eigen-faces we inferred earlier.
#
# The shape of this plot gives us an indication of how much variance there is in
# the data and how well the eigen-face decomposition works: the fewer principal
# components (here: eigen-faces) we need to explain most of the variance in the
# data, the better.
#
# The first argument to the script is the location where the visualization will
# be stored, the second argument is a directory with eigen-face files that
# follow the naming convention described in the project ReadMe.
#
# Usage:
#   visualize_eigenvalues.sh output eigenface-dir


###############################################################################
#  Application logic (you shouldn't need to change anything past this point)  #
###############################################################################


parse_eigenvalues() {
    local datadir="$1"
    local tmppath="$(mktemp)"

    ls "${datadir}"/*.png \
    | cut -d'#' -f2 \
    | sort -rn \
    > "${tmppath}"

    echo "${tmppath}"
}

plot_eigenvalues() {
    local eigenvalues="$1"
    local outpath="$2"

    gnuplot -e "
        set terminal ${outpath##*.};
        set output '${outpath}';
        set xlabel 'number of principal components';
        set ylabel 'percent variance explained';
        set yrange [0:1];
        unset key;
        plot '${eigenvalues}' smooth cumulative;
    "
}

main() {
    # parse arguments
    local outpath="$1"
    local datadir="$2"

    # enable strict mode
    set -o errexit
    set -o nounset
    set -o pipefail

    # plot the eigenvalues
    eigenvalues="$(parse_eigenvalues ${datadir})"
    plot_eigenvalues "${eigenvalues}" "${outpath}"

    # cleanup
    rm "${eigenvalues}"
}

main "$@"
