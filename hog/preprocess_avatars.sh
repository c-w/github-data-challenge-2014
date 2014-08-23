#!/bin/bash
# Simple script tp pre-process the avatars.
#
# Takes the previously downloaded avatars and applies pre-processing: size
# reduction, color conversion, etc.
#
# Usage:
#   preprocess_avatars.sh avatar...  # pre-processes the avatars


###############################################################################
#      Configuration (all paths are relative to the git-repository root)      #
###############################################################################
IMAGE_SIZE='100x100'      # size to which to convert the avatars
IMAGE_TYPE='png'          # the image type to which to conver the avatars
IMAGE_COLOR='gray'        # the colorspace to which to transform the avatars


###############################################################################
#  Application logic (you shouldn't need to change anything past this point)  #
###############################################################################


log() {
    local now="$(date +%F%T)"
    local message="$@"

    echo "[${now}] ${message}" 2>&1
}

convert_image() {
    local image_orig="$1"
    local filename="${image_orig%.*}"
    local image_out="${filename}.${IMAGE_TYPE}"

    convert "${image_orig}" \
        -resize "${IMAGE_SIZE}" \
        -colorspace "${IMAGE_COLOR}" \
        "${image_out}"
    rm "${image_orig}"

    echo "${image_out}"
}

main() {
    # parse arguments
    local images="$@"

    # enable strict mode
    set -o errexit
    set -o nounset
    set -o pipefail

    # convert images
    for image_orig in ${images}; do
        local image_out="$(convert_image ${image_orig})"
        log "converted ${image_orig} to ${image_out}"
    done
}

main "$@"
