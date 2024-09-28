# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2023 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_ARMNN)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := ARMNN
AOSPEXT_BUILD_SYSTEM := cmake

LOCAL_SHARED_LIBRARIES := libc liblog libflatbuffers

CMAKE_ARGUMENTS := \
    -DBUILD_SHARED_LIBS=ON            \
    -DBUILD_ARMNN_DESERIALIZER=ON     \
    -DBUILD_ARMNN_SERIALIZER=ON       \
    -DFLATBUFFERS_INCLUDE_PATH=.      \
    -DFLATBUFFERS_LIBRARY=flatbuffers \
    -DBUILD_TESTS=OFF                 \
    -DBUILD_UNIT_TESTS=OFF            \

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:libarmnn.so::libarmnn: \
    lib:libarmnnDeserializer.so::libarmnnDeserializer: \
    lib:libarmnnSerializer.so::libarmnnSerializer: \
    bin:armnn-tests::armnn-tests: \
    $(BOARD_ARMNN_EXTRA_TARGETS)

AOSPEXT_TARGETS_SO_DEPS := libarmnn=libarmnnDeserializer:libarmnnSerializer

LOCAL_EXPORT_C_INCLUDE_DIRS := $(BOARD_ARMNN_SRC_DIR)/include $(BOARD_ARMNN_SRC_DIR)/third-party $(BOARD_ARMNN_SRC_DIR)/third-party/half/ $(BOARD_ARMNN_SRC_DIR)/src/armnnUtils/

# Build first ARCH only
LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_ARMNN
