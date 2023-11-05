# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_DBUS)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := DBUS
AOSPEXT_BUILD_SYSTEM := meson

GLIB_VERSION = $(shell cat $(BOARD_GLIB_SRC_DIR)/meson.build | grep -o "\<version\>\s*:\s*'\w*\.\w*\.\w*'" | grep -o "\w*\.\w*\.\w*" | head -1)

LOCAL_SHARED_LIBRARIES := libc libexpat libglib-2.0 libgio-2.0 libgobject-2.0
AOSPEXT_GEN_PKGCONFIGS := expat glib-2.0:$(GLIB_VERSION) gio-unix-2.0:$(GLIB_VERSION)

MESON_BUILD_ARGUMENTS := \
    -Ddbus_session_bus_listen_address=3440

# TODO: Do not use root user for messagebus for security reasons
MESON_BUILD_ARGUMENTS += \
    -Ddbus_user=root

TMP_OUT_BIN := dbus-cleanup-sockets dbus-daemon dbus-daemon-launch-helper dbus-launch dbus-monitor dbus-run-session dbus-send dbus-test-tool dbus-update-activation-environment dbus-uuidgen

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := \
    lib:libdbus-1.so::libdbus-1:                               \
    etc:shared/dbus-1/session.conf:shared/dbus-1:session.conf: \
    etc:shared/dbus-1/system.conf:shared/dbus-1:system.conf:   \
    $(BOARD_DBUS_EXTRA_TARGETS)

AOSPEXT_GEN_TARGETS += \
    $(foreach bin,$(TMP_OUT_BIN), bin:$(bin)::$(bin):)

AOSPEXT_EXPORT_INSTALLED_INCLUDE_DIRS := vendor/include/dbus-1.0

LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
include $(LOCAL_PATH)/aospext_gen_targets.mk

#-------------------------------------------------------------------------------

endif # BOARD_BUILD_AOSPEXT_DBUS
