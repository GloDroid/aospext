# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2023 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_FLATBUFFERS)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := FLATBUFFERS
AOSPEXT_BUILD_SYSTEM := cmake

LOCAL_SHARED_LIBRARIES := libc liblog

CMAKE_ARGUMENTS := \
    -DFLATBUFFERS_BUILD_TESTS=OFF    \
    -DFLATBUFFERS_BUILD_SHAREDLIB=ON \

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:libflatbuffers.so::libflatbuffers: \
    $(BOARD_FLATBUFFERS_EXTRA_TARGETS)

LOCAL_EXPORT_C_INCLUDE_DIRS := $(BOARD_FLATBUFFERS_SRC_DIR)/include

# Build first ARCH only
LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_FLATBUFFERS
