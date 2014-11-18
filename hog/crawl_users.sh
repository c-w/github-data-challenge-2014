#!/bin/bash
# Simple crawler for a GitHub API that is paginated using the ?since parameter.
#
# This script retrieves $2 pages of results from the API starting at page $1.
# The locations to which crawled results are dumped and the API to crawl can be
# set by fiddling with the variables in the configuration section below.
#
# Usage:
#   crawl_users.sh 338 10  # fetches 10 batches of results starting at page 338
#   crawl_users.sh 338     # fetches 1 batch of results starting at page 338
#   crawl_users.sh         # fetches 1 batch of results starting at page 0


###############################################################################
#      Configuration (all paths are relative to the git-repository root)      #
###############################################################################
GITHUB_USER='c-w'         # your GitHub username (used as user-agent)
GITHUB_API='users'        # the GitHub API to query
GITHUB_OAUTH='oauth.txt'  # location of your GitHub OAuth token
DATA_OUT='data/users'     # directory to which to dump the crawled results


###############################################################################
#  Application logic (you shouldn't need to change anything past this point)  #
###############################################################################


REPO_ROOT="$(readlink -f $(git rev-parse --show-toplevel))"
DATA_OUT="${REPO_ROOT}/${DATA_OUT}"
GITHUB_API="https://api.github.com/${GITHUB_API}?since="
GITHUB_OAUTH="$(cat ${REPO_ROOT}/${GITHUB_OAUTH})"

log() {
    local now="$(date +%F%T)"
    local message="$@"

    echo "[${now}] ${message}" 2>&1
}

fetch_users_since() {
    local next_chunk="$1"
    local outpath="$2"
    local curl_log="$(mktemp /tmp/$(basename $0)-XXXXXX.curl.log)"

    # query the api for the next chunk of data
    curl \
        --request "GET" \
        --dump-header "${curl_log}" \
        --user "${GITHUB_OAUTH}:x-oauth-basic" \
        --header "User-Agent: ${GITHUB_USER}" \
        --header "Accept: application/vnd.github.v3+json" \
        --url "${GITHUB_API}${next_chunk}" \
        --silent \
    | python -m json.tool \
    | gzip \
    > "${outpath}"

    # find the value of ${next_chunk} for the next request
    next_chunk=$(grep "${GITHUB_API}" "${curl_log}" \
    | sed "s@.*${GITHUB_API}\([0-9]\+\).*@\1@")

    rm "${curl_log}"
    echo "${next_chunk}"
}

main() {
    # parse arguments
    [ -n "$1" ] && next_chunk="$1" || next_chunk='0'
    [ -n "$2" ] && num_chunks="$2" || num_chunks='1'
    log "fetching ${num_chunks} chunks starting from ${next_chunk}"

    # enable strict mode
    set -o errexit
    set -o nounset
    set -o pipefail

    # setup
    mkdir -p "${DATA_OUT}"

    # fetch some data
    for i in $(seq ${num_chunks}); do
        outpath="${DATA_OUT}/${next_chunk}.json.gz"
        log "fetching chunk ${next_chunk} to ${outpath} (${i}/${num_chunks})"

        next_chunk="$(fetch_users_since ${next_chunk} ${outpath})"

        log "the next chunk is ${next_chunk}"
    done
}

main "$@"
