# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2023 Roman Stratiienko (r.stratiienko@gmail.com)

AOSPEXT_PROJECT_NAME := RSHWCOMPOSER

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_RSHWCOMPOSER)),)

LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SHARED_LIBRARIES := libbinder libbinder_ndk liblog

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    bin:hw/android.hardware.composer.hwc3-service.rs:hw:android.hardware.composer.hwc3-service.rs: \
    etc:init/android.hardware.composer.hwc3-rs.rc:init:android.hardware.composer.hwc3-rs.rc: \
    etc:vintf/manifest/android.hardware.composer.hwc3-rs.xml:vintf/manifest:android.hardware.composer.hwc3-rs.xml: \

# Build first ARCH only
LOCAL_MULTILIB := first
include $(LOCAL_PATH)/cargo_cross.mk
AOSPEXT_TARGETS_DEP:=$(CARGO_GEN_FILES_TARGET)
AOSPEXT_PROJECT_INSTALL_DIR:=$(dir $(AOSPEXT_TARGETS_DEP))/install
AOSPEXT_PROJECT_OUT_INCLUDE_DIR:=
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_RSHWCOMPOSER
