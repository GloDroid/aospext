# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2023 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_COMPUTELIBRARY)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := COMPUTELIBRARY
AOSPEXT_BUILD_SYSTEM := cmake

LOCAL_SHARED_LIBRARIES := libc

CMAKE_ARGUMENTS := \
    -DARM_COMPUTE_OPENMP=NO \

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:libarm_compute.so::libarm_compute: \
    lib:libarm_compute_graph.so::libarm_compute_graph: \
    lib:libarm_compute_sve.so::libarm_compute_sve: \
    lib:libarm_compute_sve2.so::libarm_compute_sve2: \
    $(BOARD_COMPUTELIBRARY_EXTRA_TARGETS)

AOSPEXT_TARGETS_SO_DEPS := libarm_compute=libarm_compute_graph:libarm_compute_sve:libarm_compute_sve2

LOCAL_EXPORT_C_INCLUDE_DIRS := $(BOARD_COMPUTELIBRARY_SRC_DIR)/include $(BOARD_COMPUTELIBRARY_SRC_DIR)

# Build first ARCH only
LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_COMPUTELIBRARY
