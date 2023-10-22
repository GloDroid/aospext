#!/bin/bash -e

# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)

COMPILER=$( basename -- "$0"; )
LOCAL_PATH=$( dirname -- "$0"; )
BASE_DIR=$( cd -- "${LOCAL_PATH}/.."; pwd; )

extract_flags() {
    # $1 - Flag files prefix (sharedlib or exec)
    CC=$(cat ${LOCAL_PATH}/$1.cc)
    CXX=$(cat ${LOCAL_PATH}/$1.cxx)
    CFLAGS=$(cat ${LOCAL_PATH}/$1.cflags)
    CPPFLAGS=$(cat ${LOCAL_PATH}/$1.cppflags)
    LINK_ARGS=$(cat ${LOCAL_PATH}/$1.link_args)
}

if [[ " $@ " =~ .*\ -shared\ .* ]]; then
    extract_flags sharedlib
else
    extract_flags exec
fi

if [ "${COMPILER}" == "wrap_c" ]; then
    ARGS="${CC} $@"
elif [ "${COMPILER}" == "wrap_cxx" ]; then
    ARGS="${CXX} $@"
elif [ "${COMPILER}" == "wrap_rust_ld" ]; then
    ARGS="${CC} $@ ${LINK_ARGS} -Wl,--unresolved-symbols=ignore-all"
    # Filter-out libraries, since we're not using NDK but adding .so directly
    ARGS="${ARGS//-lc++_shared/}"
    ARGS="${ARGS//-lc/}"
    ARGS="${ARGS//-ldl/}"
    ARGS="${ARGS//-lgcc/}"
    ARGS="${ARGS//-llog/}"
    ARGS="${ARGS//-lm/}"
    ARGS="${ARGS//-lunwind/}"
else
    echo "Unknown compiler: ${COMPILER}"
    exit 1
fi

ARGS="${ARGS/\[C_ARGS\]/${CFLAGS}}"
ARGS="${ARGS/\[CPP_ARGS\]/${CPPFLAGS}}"
ARGS="${ARGS/\[C_LINK_ARGS\]/${LINK_ARGS}}"
ARGS="${ARGS/\[CPP_LINK_ARGS\]/${LINK_ARGS}}"

# Remove duplicate placeholders (can occur when meson is building cmake subproject)
ARGS="${ARGS//\[C_ARGS\]/}"
ARGS="${ARGS//\[CPP_ARGS\]/}"
ARGS="${ARGS//\[C_LINK_ARGS\]/}"
ARGS="${ARGS//\[CPP_LINK_ARGS\]/}"

ARGS="${ARGS//\[BASE_DIR\]/${BASE_DIR}}"

# run compiler with arguments
${ARGS}
