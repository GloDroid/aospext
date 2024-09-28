# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2023 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_LLVM)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := LLVM
AOSPEXT_BUILD_SYSTEM := cmake

LOCAL_SHARED_LIBRARIES := libc

CMAKE_ARGUMENTS := \
    -DLLVM_LIBDIR_SUFFIX=[PLACE_FOR_LIBDIR_SUFFIX] \
    -DCMAKE_BUILD_TYPE=Debug    \
    -DLLVM_LINK_LLVM_DYLIB=ON   \
    -DLLVM_VERSION_SUFFIX=      \
    -DLLVM_BUILD_EXAMPLES=OFF   \
    -DLLVM_INCLUDE_EXAMPLES=OFF \
    -DLLVM_INCLUDE_TESTS=OFF    \

CMAKE_SRC_SUBDIR := llvm

LLVM_VERSION := $(shell cat $(BOARD_LLVM_SRC_DIR)/llvm/CMakeLists.txt | grep -o 'LLVM_VERSION_MAJOR [0-9]\+' | grep -o '[0-9][0-9]*' | head -1)

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:libLLVM-$(LLVM_VERSION).so::libLLVM-$(LLVM_VERSION): \
    $(BOARD_LLVM_EXTRA_TARGETS)

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

endif # BOARD_BUILD_AOSPEXT_LLVM
