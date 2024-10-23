# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2022 Roman Stratiienko (r.stratiienko@gmail.com)

ifneq ($(filter true, $(BOARD_BUILD_AOSPEXT_MESA3D)),)

LOCAL_PATH := $(call my-dir)
include $(LOCAL_PATH)/aospext_cleanup.mk

AOSPEXT_PROJECT_NAME := MESA3D
AOSPEXT_BUILD_SYSTEM := meson

LIBDRM_VERSION = $(shell cat external/libdrm/meson.build | grep -o "\<version\>\s*:\s*'\w*\.\w*\.\w*'" | grep -o "\w*\.\w*\.\w*" | head -1)
MESA3D_VERSION = $(shell cat $(BOARD_MESA3D_SRC_DIR)/VERSION | cut -d '.' -f 1-2)
MESA3D_GALLIUM_LIBDIR :=
MESA3D_POPULATE_SYMLINKS :=

ifeq ($(shell expr $(MESA3D_VERSION) \<= 24.1), 1)
MESA3D_GALLIUM_LIBDIR := dri
MESA3D_POPULATE_SYMLINKS := true
endif

MESA_VK_LIB_SUFFIX_amd := radeon
MESA_VK_LIB_SUFFIX_intel := intel
MESA_VK_LIB_SUFFIX_intel_hasvk := intel_hasvk
MESA_VK_LIB_SUFFIX_nouveau := nouveau
MESA_VK_LIB_SUFFIX_freedreno := freedreno
MESA_VK_LIB_SUFFIX_broadcom := broadcom
MESA_VK_LIB_SUFFIX_panfrost := panfrost
MESA_VK_LIB_SUFFIX_virtio := virtio
MESA_VK_LIB_SUFFIX_swrast := lvp

MESON_BUILD_ARGUMENTS := \
    -Dplatforms=android                                                          \
    -Dplatform-sdk-version=$(PLATFORM_SDK_VERSION)                               \
    -Dgallium-drivers=$(subst $(space),$(comma),$(BOARD_MESA3D_GALLIUM_DRIVERS)) \
    -Dvulkan-drivers=$(subst $(space),$(comma),$(subst radeon,amd,$(BOARD_MESA3D_VULKAN_DRIVERS)))   \
    -Dgbm=enabled                                                                \
    -Degl=$(if $(BOARD_MESA3D_GALLIUM_DRIVERS),enabled,disabled)                 \
    -Dllvm=$(if $(MESON_GEN_LLVM_STUB),enabled,disabled)                         \
    -Dcpp_rtti=false                                                             \
    -Dlmsensors=disabled                                                         \
    -Dandroid-libbacktrace=disabled                                              \
    $(BOARD_MESA3D_EXTRA_MESON_ARGS)                                             \
    $(BOARD_MESA3D_MESON_ARGS)

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 30; echo $$?), 0)
MESA_LIBGBM_NAME := libgbm_mesa
else
MESA_LIBGBM_NAME := libgbm
endif

# Format: TYPE:REL_PATH_TO_INSTALL_ARTIFACT:VENDOR_SUBDIR:MODULE_NAME:SYMLINK_SUFFIX
# TYPE one of: lib, bin, etc
AOSPEXT_GEN_TARGETS := $(BOARD_MESA3D_EXTRA_TARGETS)

ifneq ($(strip $(BOARD_MESA3D_GALLIUM_DRIVERS)),)
AOSPEXT_GEN_TARGETS += \
    lib:libgallium_dri.so:$(MESA3D_GALLIUM_LIBDIR):libgallium_dri:   \
    lib:libglapi.so::libglapi:                  \
    lib:libEGL.so:egl:libEGL_mesa:              \
    lib:libGLESv1_CM.so:egl:libGLESv1_CM_mesa:  \
    lib:libGLESv2.so:egl:libGLESv2_mesa:        \

endif

ifneq ($(filter true, $(BOARD_MESA3D_BUILD_LIBGBM)),)
AOSPEXT_GEN_TARGETS += lib:$(MESA_LIBGBM_NAME).so::$(MESA_LIBGBM_NAME):
AOSPEXT_GEN_TARGETS += lib:gbm/dri_gbm.so::dri_gbm:
endif

AOSPEXT_GEN_TARGETS += \
    $(foreach driver,$(BOARD_MESA3D_VULKAN_DRIVERS), lib:libvulkan_$(MESA_VK_LIB_SUFFIX_$(driver)).so:hw:vulkan.$(MESA_VK_LIB_SUFFIX_$(driver)):)

include $(CLEAR_VARS)

LOCAL_SHARED_LIBRARIES := libc libdl libdrm libm liblog libcutils libz libc++ libnativewindow libsync libhardware
LOCAL_STATIC_LIBRARIES := libexpat libarect libelf
LOCAL_HEADER_LIBRARIES := libnativebase_headers hwvulkan_headers
AOSPEXT_GEN_PKGCONFIGS := log cutils expat hardware libdrm:$(LIBDRM_VERSION) nativewindow sync zlib:1.2.11 libelf
LOCAL_CFLAGS += $(BOARD_MESA3D_CFLAGS)

ifneq ($(filter swrast,$(BOARD_MESA3D_GALLIUM_DRIVERS) $(BOARD_MESA3D_VULKAN_DRIVERS)),)
ifeq ($(BOARD_MESA3D_FORCE_SOFTPIPE),)
MESON_GEN_LLVM_STUB := true
endif
endif

ifneq ($(filter zink,$(BOARD_MESA3D_GALLIUM_DRIVERS)),)
LOCAL_SHARED_LIBRARIES += libvulkan
AOSPEXT_GEN_PKGCONFIGS += vulkan
endif

ifneq ($(filter iris,$(BOARD_MESA3D_GALLIUM_DRIVERS)),)
LOCAL_SHARED_LIBRARIES += libdrm_intel
AOSPEXT_GEN_PKGCONFIGS += libdrm_intel:$(LIBDRM_VERSION)
endif

ifneq ($(filter radeonsi,$(BOARD_MESA3D_GALLIUM_DRIVERS)),)
MESON_GEN_LLVM_STUB := true
LOCAL_CFLAGS += -DFORCE_BUILD_AMDGPU   # instructs LLVM to declare LLVMInitializeAMDGPU* functions
endif

ifneq ($(filter radeonsi amd,$(BOARD_MESA3D_GALLIUM_DRIVERS) $(BOARD_MESA3D_VULKAN_DRIVERS)),)
LOCAL_SHARED_LIBRARIES += libdrm_amdgpu
AOSPEXT_GEN_PKGCONFIGS += libdrm_amdgpu:$(LIBDRM_VERSION)
endif

ifneq ($(filter radeonsi r300 r600,$(BOARD_MESA3D_GALLIUM_DRIVERS)),)
LOCAL_SHARED_LIBRARIES += libdrm_radeon
AOSPEXT_GEN_PKGCONFIGS += libdrm_radeon:$(LIBDRM_VERSION)
endif

ifneq ($(filter nouveau,$(BOARD_MESA3D_GALLIUM_DRIVERS)),)
LOCAL_SHARED_LIBRARIES += libdrm_nouveau
AOSPEXT_GEN_PKGCONFIGS += libdrm_nouveau:$(LIBDRM_VERSION)
endif

ifneq ($(filter d3d12,$(BOARD_MESA3D_GALLIUM_DRIVERS)),)
LOCAL_HEADER_LIBRARIES += DirectX-Headers
LOCAL_STATIC_LIBRARIES += DirectX-Guids
AOSPEXT_GEN_PKGCONFIGS += DirectX-Headers
endif

ifneq ($(MESON_GEN_LLVM_STUB),)
MESON_LLVM_VERSION := 12.0.0
LOCAL_SHARED_LIBRARIES += libLLVM12
endif

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 30; echo $$?), 0)
LOCAL_SHARED_LIBRARIES += libgralloctypes libutils

ifeq ($(shell test $(PLATFORM_SDK_VERSION) -ge 35; echo $$?), 0)
LOCAL_SHARED_LIBRARIES += libui
AOSPEXT_GEN_PKGCONFIGS += ui
else
LOCAL_SHARED_LIBRARIES += libhidlbase android.hardware.graphics.mapper@4.0
AOSPEXT_GEN_PKGCONFIGS += android.hardware.graphics.mapper:4.0
endif

endif

LOCAL_EXPORT_C_INCLUDE_DIRS := $(BOARD_MESA3D_SRC_DIR)/src/gbm/main
AOSPEXT_EXPORT_INSTALLED_INCLUDE_DIRS := vendor/include

ifneq ($(MESA3D_POPULATE_SYMLINKS),)
define populate_dri_symlinks
# -------------------------------------------------------------------------------
# Mesa3d installs every dri target as a separate shared library, but for gallium drivers all
# dri targets are identical and can be replaced with symlinks to save some disk space.
# To do that we take first driver, copy it as libgallium_dri.so and populate vendor/lib{64}/dri/
# directory with a symlinks to libgallium_dri.so

$(SYMLINKS_TARGET): MESA3D_LIB_INSTALL_DIR:=$(dir $(AOSPEXT_INTERNAL_BUILD_TARGET))/install/vendor/lib$(if $(TARGET_IS_64_BIT),$(if $(filter 64 first,$(LOCAL_MULTILIB)),64))
$(SYMLINKS_TARGET): $(AOSPEXT_INTERNAL_BUILD_TARGET)
	# Create Symlinks
	mkdir -p $$(dir $$@)
ifneq ($(strip $(BOARD_MESA3D_GALLIUM_DRIVERS)),)
	ls -1 $$(MESA3D_LIB_INSTALL_DIR)/dri/ | PATH=/usr/bin:$$PATH xargs -I{} ln -s -f libgallium_dri.so $$(dir $$@)/{}
	cp `ls -1 $$(MESA3D_LIB_INSTALL_DIR)/dri/* | head -1` $$(MESA3D_LIB_INSTALL_DIR)/libgallium_dri.so
endif
	touch $$@
endef

#-------------------------------------------------------------------------------
endif # MESA3D_POPULATE_SYMLINKS

LOCAL_MULTILIB := first
include $(LOCAL_PATH)/aospext_cross_compile.mk
ifneq ($(MESA3D_POPULATE_SYMLINKS),)
SYMLINKS_TARGET := $($(AOSPEXT_ARCH_PREFIX)TARGET_OUT_VENDOR_SHARED_LIBRARIES)/dri/.symlinks.timestamp
$(eval $(call populate_dri_symlinks))
FIRSTARCH_SYMLINKS_TARGET := $(SYMLINKS_TARGET)
endif # MESA3D_POPULATE_SYMLINKS
FIRSTARCH_BUILD_TARGET := $(AOSPEXT_INTERNAL_BUILD_TARGET)

ifdef TARGET_2ND_ARCH
LOCAL_MULTILIB := 32
include $(LOCAL_PATH)/aospext_cross_compile.mk
ifneq ($(MESA3D_POPULATE_SYMLINKS),)
SYMLINKS_TARGET := $($(AOSPEXT_ARCH_PREFIX)TARGET_OUT_VENDOR_SHARED_LIBRARIES)/dri/.symlinks.timestamp
$(eval $(call populate_dri_symlinks))
SECONDARCH_SYMLINKS_TARGET := $(SYMLINKS_TARGET)
endif # MESA3D_POPULATE_SYMLINKS
SECONDARCH_BUILD_TARGET := $(AOSPEXT_INTERNAL_BUILD_TARGET)
endif

#-------------------------------------------------------------------------------

LOCAL_MULTILIB := first
AOSPEXT_EXTRA_DEPS := $(FIRSTARCH_SYMLINKS_TARGET)
AOSPEXT_INTERNAL_BUILD_TARGET := $(FIRSTARCH_BUILD_TARGET)
include $(LOCAL_PATH)/aospext_gen_targets.mk

ifdef TARGET_2ND_ARCH
LOCAL_MULTILIB := 32
AOSPEXT_EXTRA_DEPS := $(SECONDARCH_SYMLINKS_TARGET)
AOSPEXT_INTERNAL_BUILD_TARGET := $(SECONDARCH_BUILD_TARGET)
include $(LOCAL_PATH)/aospext_gen_targets.mk
endif

endif # BOARD_BUILD_AOSPEXT_MESA3D
