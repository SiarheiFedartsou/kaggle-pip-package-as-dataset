#!/bin/bash
set -e

usage() { echo "Usage: $0 [-p <pip_package_name> or -r <requirements.txt>] [-t <title>]" 1>&2; exit 1; }

while getopts ":r:t:p:" o; do
    case "${o}" in
        r)
            REQUIREMENTS_TXT=${OPTARG}
            $(test -f ${REQUIREMENTS_TXT}) || usage
            REQUIREMENTS_TXT=$(realpath ${REQUIREMENTS_TXT})
            ;;
        t)
            TITLE=${OPTARG}
            ;;
        p)
            PACKAGE_NAME=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))


if [[ -z "${REQUIREMENTS_TXT}" && -z "${PACKAGE_NAME}" ]]; then
    usage
fi

if [[ "${REQUIREMENTS_TXT}" && "${PACKAGE_NAME}" ]]; then
    echo "Got requirements file and package name at the same time." 1>&2
    usage
fi

if [[ "${REQUIREMENTS_TXT}" && -z ${TITLE} ]]; then
    echo "Title is mandatory if using requirements file" 1>&2
    usage
fi


# https://gist.github.com/oneohthree/f528c7ae1e701ad990e6
function slugify() {
    echo "$1" | iconv -t ascii//TRANSLIT | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z
}

# https://stackoverflow.com/questions/3679296/only-get-hash-value-using-md5sum-without-filename
function md5() {
   echo $(md5sum $1 | awk '{ print $1 }')
}

TITLE=${TITLE:-$PACKAGE_NAME}
SLUG=$(slugify ${TITLE})
if [[ ${PACKAGE_NAME} ]]; then
    DATASET_DIR=package-${PACKAGE_NAME}
else
    DATASET_DIR=package-$(md5 ${REQUIREMENTS_TXT})
fi

function cleanup {
  rm -rf "${DATASET_DIR}"
}
trap cleanup EXIT


mkdir -p "${DATASET_DIR}"
pushd "${DATASET_DIR}"
if [[ ${PACKAGE_NAME} ]]; then
    pip download ${PACKAGE_NAME}
else
    pip download -r ${REQUIREMENTS_TXT}
fi
kaggle datasets init
sed -i "s/INSERT_TITLE_HERE/${TITLE}/g" dataset-metadata.json
sed -i "s/INSERT_SLUG_HERE/${SLUG}/g" dataset-metadata.json
kaggle datasets create
popd
