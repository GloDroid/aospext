# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_FFMPEGCODEC2)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := FFMPEGCODEC2
AOSPEXT_BUILD_SYSTEM := meson

LOCAL_SHARED_LIBRARIES := \
    android.hardware.media.c2@1.2 \
    libavcodec \
    libavutil \
    libavformat \
    libavservices_minijail \
    libbase \
    libbinder \
    libcodec2_hidl@1.2 \
    libcodec2_soft_common \
    libcodec2_vndk \
    libhidlbase \
    liblog \
    libstagefright_foundation \
    libswresample \
    libswscale \
    libutils \
    libcutils \

AOSPEXT_GEN_PKGCONFIGS := cutils drm hardware hidlbase log sync ui utils

MESON_BUILD_ARGUMENTS := \

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    bin:hw/android.hardware.media.c2@1.2-service-ffmpeg:hw:android.hardware.media.c2@1.2-service-ffmpeg: \
    etc:init/android.hardware.media.c2@1.2-service-ffmpeg.rc:init:android.hardware.media.c2@1.2-service-ffmpeg.rc: \
    etc:vintf/manifest/android.hardware.media.c2@1.2-service-ffmpeg.xml:vintf/manifest:android.hardware.media.c2@1.2-service-ffmpeg.xml: \
    etc:media_codecs_ffmpeg_c2.xml::media_codecs_ffmpeg_c2.xml: \
    $(BOARD_FFMPEGCODEC2_EXTRA_TARGETS)

# HWC3

# Build first ARCH only
LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_FFMPEGCODEC2
