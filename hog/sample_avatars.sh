#!/bin/bash
# Script to create a random sample of the avatars.
#
# Usage:
#   sample_avatars.sh 8000 avatar...  # sample 8000 random avatars


###############################################################################
#      Configuration (all paths are relative to the git-repository root)      #
###############################################################################
SAMPLE_DIR='data/sample'  # directory to which to move sampled avatars


###############################################################################
#  Application logic (you shouldn't need to change anything past this point)  #
###############################################################################


REPO_ROOT="$(readlink -f $(git rev-parse --show-toplevel))"
SAMPLE_DIR="${REPO_ROOT}/${SAMPLE_DIR}"

log() {
    local now="$(date +%F%T)"
    local message="$@"

    echo "[${now}] ${message}" 2>&1
}

reset() {
    local directory="$1"

    rm --force --recursive "${directory}" 2>/dev/null
    mkdir --parents "${directory}"
}

sample_image() {
    local image="$1"

    ln --symbolic \
        "$(readlink --canonicalize ${image})" \
        "${SAMPLE_DIR}/$(basename ${image})"
}

main() {
    # parse arguments
    local sample_size="$1" && shift
    local images="$@"

    # enable strict mode
    set -o errexit
    set -o nounset
    set -o pipefail

    # setup
    reset "${SAMPLE_DIR}"

    # sample some avatars
    local num_samples=0
    for image in $(echo "${images}" | sort --random-sort); do
        sample_image "${image}" && num_samples=$((num_samples + 1))
        log "sampled ${num_samples} avatars"
        [ "${num_samples}" -ge "${sample_size}" ] && break
    done
}

main "$@"
