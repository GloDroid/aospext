# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2023 Roman Stratiienko (r.stratiienko@gmail.com)

AOSPEXT_PROJECT_NAME := MMRADIO

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_MMRADIO)),)

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SHARED_LIBRARIES := \
    libbase \
    libbinder_ndk \
    libcutils \
    liblog \
    libutils \
    android.hardware.radio-V1-ndk \
    android.hardware.radio.config-V1-ndk \
    android.hardware.radio.data-V1-ndk \
    android.hardware.radio.messaging-V1-ndk \
    android.hardware.radio.modem-V1-ndk \
    android.hardware.radio.network-V1-ndk \
    android.hardware.radio.sim-V1-ndk \
    android.hardware.radio.voice-V1-ndk \

LOCAL_SHARED_LIBRARIES += \
    libglib-2.0 \
    libgio-2.0 \
    libgobject-2.0 \
    libmm-glib \

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    bin:hw/android.hardware.mm-radio-service:hw:android.hardware.mm-radio-service: \
    etc:init/android.hardware.radio.rc:init:android.hardware.mmradio.rc: \
    etc:vintf/manifest/android.hardware.radio.xml:vintf/manifest:android.hardware.mmradio.xml: \
    $(BOARD_MMRADIO_EXTRA_TARGETS)

# Build first ARCH only
LOCAL_MULTILIB := first
include $(LOCAL_PATH)/cargo_cross.mk
AOSPEXT_TARGETS_DEP:=$(CARGO_GEN_FILES_TARGET)
AOSPEXT_PROJECT_INSTALL_DIR:=$(dir $(AOSPEXT_TARGETS_DEP))/install
AOSPEXT_PROJECT_OUT_INCLUDE_DIR:=
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_MMRADIO
