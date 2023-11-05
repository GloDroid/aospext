# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_LIBGUDEV)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := LIBGUDEV
AOSPEXT_BUILD_SYSTEM := meson

GLIB_VERSION = $(shell cat $(BOARD_GLIB_SRC_DIR)/meson.build | grep -o "\<version\>\s*:\s*'\w*\.\w*\.\w*'" | grep -o "\w*\.\w*\.\w*" | head -1)

LOCAL_SHARED_LIBRARIES := libc libglib-2.0 libgobject-2.0 libudev
AOSPEXT_GEN_PKGCONFIGS := glib-2.0:$(GLIB_VERSION) gobject-2.0:$(GLIB_VERSION) libudev:199

MESON_BUILD_ARGUMENTS := \

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:libgudev-1.0.so::libgudev-1.0: \
    $(BOARD_LIBGUDEV_EXTRA_TARGETS)

AOSPEXT_EXPORT_INSTALLED_INCLUDE_DIRS := vendor/include/gudev-1.0

# Build first ARCH only
LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_LIBGUDEV
