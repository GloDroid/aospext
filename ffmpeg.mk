# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_FFMPEG)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := FFMPEG
AOSPEXT_BUILD_SYSTEM := ffmpeg

LIBDRM_VERSION = $(shell cat external/libdrm/meson.build | grep -o "\<version\>\s*:\s*'\w*\.\w*\.\w*'" | grep -o "\w*\.\w*\.\w*" | head -1)

FFMPEG_DEFINITIONS := \
    --disable-static \
    --enable-shared \
    --disable-avdevice \
    --disable-postproc \
    --disable-avfilter \
    $(BOARD_FFMPEG_EXTRA_CONFIGURE_OPTIONS)

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:libavcodec.so::libavcodec:               \
    lib:libavformat.so::libavformat:             \
    lib:libavutil.so::libavutil:                 \
    lib:libswresample.so::libswresample:         \
    lib:libswscale.so::libswscale:               \

include $(CLEAR_VARS)

LOCAL_SHARED_LIBRARIES := libc
AOSPEXT_GEN_PKGCONFIGS :=

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_DAV1D)),)
DAV1D_VERSION = $(shell cat $(BOARD_DAV1D_SRC_DIR)/meson.build | grep -o "\<version\>\s*:\s*'\w*\.\w*\.\w*'" | grep -o "\w*\.\w*\.\w*" | head -1)
LOCAL_SHARED_LIBRARIES += libdav1d
AOSPEXT_GEN_PKGCONFIGS += dav1d:$(DAV1D_VERSION)
FFMPEG_DEFINITIONS += --enable-libdav1d
endif

ifneq ($(filter true, $(BOARD_FFMPEG_ENABLE_REQUEST_API)),)
LOCAL_SHARED_LIBRARIES += libdrm libudev
AOSPEXT_GEN_PKGCONFIGS += libdrm libudev
FFMPEG_DEFINITIONS += --enable-libdrm --enable-libudev --enable-v4l2-request
LOCAL_C_INCLUDES := $(BOARD_FFMPEG_KERNEL_HEADERS_DIR)
endif

AOSPEXT_EXPORT_INSTALLED_INCLUDE_DIRS := vendor/include

#-------------------------------------------------------------------------------

LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

endif # BOARD_BUILD_FFMPEG
