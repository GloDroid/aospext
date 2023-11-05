# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_GLIB)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := GLIB
AOSPEXT_BUILD_SYSTEM := meson

LOCAL_SHARED_LIBRARIES := libc libpcre2 libffi libz
AOSPEXT_GEN_PKGCONFIGS := libpcre2-8:10.32 libffi:3.0.0 zlib

MESON_BUILD_ARGUMENTS := \

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:libintl.so::libintl:               \
    lib:libglib-2.0.so::libglib-2.0:       \
    lib:libgthread-2.0.so::libgthread-2.0: \
    lib:libgmodule-2.0.so::libgmodule-2.0: \
    lib:libgobject-2.0.so::libgobject-2.0: \
    lib:libgio-2.0.so::libgio-2.0:         \
    $(BOARD_GLIB_EXTRA_TARGETS)

AOSPEXT_EXPORT_INSTALLED_INCLUDE_DIRS := vendor/include/glib-2.0 vendor/lib64/glib-2.0/include vendor/include/gio-unix-2.0

LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_GLIB
