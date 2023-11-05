# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)


ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_DRMHWCOMPOSER)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := DRMHWCOMPOSER
AOSPEXT_BUILD_SYSTEM := meson

LOCAL_HEADER_LIBRARIES :=
LOCAL_SHARED_LIBRARIES := libcutils libdrm libhardware libhidlbase liblog libsync libui libutils
AOSPEXT_GEN_PKGCONFIGS := cutils drm hardware hidlbase log sync ui utils

MESON_BUILD_ARGUMENTS := \

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:hw/hwcomposer.drm.so:hw:hwcomposer.drm_gd: \
    $(BOARD_DRMHWCOMPOSER_EXTRA_TARGETS)

# HWC3
ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 33; echo $$?), 0)

LOCAL_HEADER_LIBRARIES += android.hardware.graphics.composer3-command-buffer
LOCAL_SHARED_LIBRARIES += android.hardware.graphics.composer3-V1-ndk libbinder libbinder_ndk
AOSPEXT_GEN_PKGCONFIGS += android.hardware.graphics.composer3-V1-ndk binder binder_ndk
AOSPEXT_GEN_TARGETS += \
    bin:hw/android.hardware.composer.hwc3-service.drm:hw:android.hardware.composer.hwc3-service.drm: \
    etc:init/hwc3-drm.rc:init:hwc3-drm.rc: \
    etc:vintf/manifest/hwc3-drm.xml:vintf/manifest:hwc3-drm.xml: \

endif

# Build first ARCH only
LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_DRMHWCOMPOSER
