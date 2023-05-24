# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2023 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_DAV1D)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := DAV1D
AOSPEXT_BUILD_SYSTEM := meson

LOCAL_SHARED_LIBRARIES := libc

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    bin:dav1d::dav1d:                      \
    lib:libdav1d.so::libdav1d:             \
    $(BOARD_DAV1D_EXTRA_TARGETS)

AOSPEXT_EXPORT_INSTALLED_INCLUDE_DIRS := vendor/include

LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
TMP_AOSPEXT_TARGET_FIRST:=$(AOSPEXT_INTERNAL_BUILD_TARGET)

ifdef TARGET_2ND_ARCH
LOCAL_MULTILIB := 32
include $(LOCAL_PATH)/aospext_cross_compile.mk
TMP_AOSPEXT_TARGET_32:=$(AOSPEXT_INTERNAL_BUILD_TARGET)
endif

LOCAL_MULTILIB := first
AOSPEXT_INTERNAL_BUILD_TARGET:=$(TMP_AOSPEXT_TARGET_FIRST)
include $(LOCAL_PATH)/aospext_gen_targets.mk

ifdef TARGET_2ND_ARCH
LOCAL_MULTILIB := 32
AOSPEXT_INTERNAL_BUILD_TARGET:=$(TMP_AOSPEXT_TARGET_32)
include $(LOCAL_PATH)/aospext_gen_targets.mk
endif

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_DAV1D
