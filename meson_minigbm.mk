# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_MINIGBM)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := MINIGBM
AOSPEXT_BUILD_SYSTEM := meson

LOCAL_HEADER_LIBRARIES := libnativebase_headers
LOCAL_SHARED_LIBRARIES := libcutils libdrm libhardware libhidlbase liblog libnativewindow libsync
LOCAL_STATIC_LIBRARIES := libarect
AOSPEXT_GEN_PKGCONFIGS := cutils drm hardware hidlbase log nativewindow sync arect

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 30; echo $$?), 0)
LOCAL_SHARED_LIBRARIES += libgbm_mesa
else
LOCAL_SHARED_LIBRARIES += libgbm
endif

MESON_BUILD_ARGUMENTS := \

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:hw/gralloc.minigbm_gd.so:hw:gralloc.minigbm_gd: \
    lib:libminigbm_gralloc_gd.so::libminigbm_gralloc_gd: \
    lib:libgbm_mesa_wrapper.so::libgbm_mesa_wrapper: \
    $(BOARD_MINIGBM_EXTRA_TARGETS)

# Gralloc4
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 30; echo $$?), 0)

LOCAL_SHARED_LIBRARIES += android.hardware.graphics.mapper@4.0 android.hardware.graphics.allocator@4.0 libgralloctypes libbase libutils
AOSPEXT_GEN_PKGCONFIGS += android.hardware.graphics.mapper@4.0 android.hardware.graphics.allocator@4.0 gralloctypes base utils
AOSPEXT_GEN_TARGETS += \
    bin:hw/android.hardware.graphics.allocator@4.0-service.minigbm_gd:hw:android.hardware.graphics.allocator@4.0-service.minigbm_gd: \
    lib:hw/android.hardware.graphics.mapper@4.0-impl.minigbm_gd.so:hw:android.hardware.graphics.mapper@4.0-impl.minigbm_gd: \

endif

# Gralloc5
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 34; echo $$?), 0)

LOCAL_HEADER_LIBRARIES += libbase_headers libimapper_stablec libimapper_providerutils
LOCAL_SHARED_LIBRARIES += libbinder_ndk android.hardware.graphics.allocator-V2-ndk
LOCAL_STATIC_LIBRARIES += libaidlcommonsupport
AOSPEXT_GEN_TARGETS += \
    bin:hw/android.hardware.graphics.allocator-service.minigbm_gd:hw:android.hardware.graphics.allocator-service.minigbm_gd: \
    lib:mapper.minigbm_gd.so::mapper.minigbm_gd: \
    etc:init/allocator_gd.rc:init:android.hardware.graphics.allocator_gd.rc: \
    etc:vintf/manifest/allocator.xml:vintf/manifest:android.hardware.graphics.allocator_gd.xml: \
    etc:vintf/manifest/mapper.minigbm_gd.xml:vintf/manifest:mapper.minigbm_gd.xml: \

endif

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

endif # BOARD_BUILD_AOSPEXT_MINIGBM
