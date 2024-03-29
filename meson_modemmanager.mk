# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_MODEMMANAGER)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := MODEMMANAGER
AOSPEXT_BUILD_SYSTEM := meson

GLIB_VERSION = $(shell cat $(BOARD_GLIB_SRC_DIR)/meson.build | grep -o "\<version\>\s*:\s*'\w*\.\w*\.\w*'" | grep -o "\w*\.\w*\.\w*" | head -1)
LIBQMI_VERSION = $(shell cat $(BOARD_LIBQMI_SRC_DIR)/meson.build | grep -o "\<version\>\s*:\s*'\w*\.\w*\.\w*'" | grep -o "\w*\.\w*\.\w*" | head -1)

LOCAL_SHARED_LIBRARIES := libc libexpat libglib-2.0 libgio-2.0 libgobject-2.0 libgmodule-2.0 libdbus-1 libqmi-glib libgudev-1.0
AOSPEXT_GEN_PKGCONFIGS := glib-2.0:$(GLIB_VERSION) gmodule-2.0:$(GLIB_VERSION) gobject-2.0:$(GLIB_VERSION) gio-2.0:$(GLIB_VERSION) gio-unix-2.0:$(GLIB_VERSION) dbus-1 qmi-glib:$(LIBQMI_VERSION) gudev-1.0:232

MESON_BUILD_ARGUMENTS := \
    -Dmbim=false \
    -Dqrtr=false \
    -Dtests=false \
    -Dintrospection=false \
    -Dbash_completion=false \
    -Dsystemdsystemunitdir=no \
    -Dsystemd_suspend_resume=false \
    -Dsystemd_journal=false \
    -Dpolkit=no \
    -Dplugin_dell=disabled \
    -Dplugin_foxconn=disabled \
    -Dudevdir=/vendor/etc/mm_udev \
    -Dbuiltin_plugins=true

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    bin:mmcli::mmcli:               \
    bin:ModemManager::ModemManager: \
    lib:libmm-glib.so::libmm-glib:  \
    etc:dbus-1/system.d/org.freedesktop.ModemManager1.conf:dbus-1/system.d:org.freedesktop.ModemManager1.conf: \
    $(BOARD_MODEMMANAGER_EXTRA_TARGETS)

AOSPEXT_EXPORT_INSTALLED_INCLUDE_DIRS := vendor/include/libmm-glib vendor/include/ModemManager

LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_MODEMMANAGER
