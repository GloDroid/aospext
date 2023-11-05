# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_LIBQMI)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := LIBQMI
AOSPEXT_BUILD_SYSTEM := meson

LOCAL_SHARED_LIBRARIES := libc libglib-2.0 libgio-2.0 libgobject-2.0
AOSPEXT_GEN_PKGCONFIGS := glib-2.0:2.75.1 gio-2.0:2.75.1 gio-unix-2.0:2.75.1 gobject-2.0:2.75.1

MESON_BUILD_ARGUMENTS := \
    -Dudev=false \
    -Dbash_completion=false \
    -Dintrospection=false \
    -Dmbim_qmux=false \
    -Dqrtr=false \
    -Dman=false \

TMP_OUT_BIN := qmicli qmi-firmware-update qmi-network qmi-proxy

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:libqmi-glib.so::libqmi-glib: \
    $(BOARD_LIBQMI_EXTRA_TARGETS)

AOSPEXT_GEN_TARGETS += \
    $(foreach bin,$(TMP_OUT_BIN), bin:$(bin)::$(bin):)

AOSPEXT_EXPORT_INSTALLED_INCLUDE_DIRS := vendor/include/libqmi-glib

# Build first ARCH only
LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_LIBQMI
