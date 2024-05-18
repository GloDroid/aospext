# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2023 The GloDroid project
#
# Inputs provided by user:
# AOSP_PROJECT_NAME (FFMPEG, MESA3D, etc.)
# AOSPEXT_BUILD_SYSTEM (one of the meson, cmake, cargo, ffmpeg, cmake, autotools)
# AOSPEXT_GEN_PKGCONFIGS (list: "pkg1:version pkg2:version", optional)
# FFMPEG_DEFINITIONS (optional)
# MESON_BUILD_ARGUMENTS (optional)
#
# Inputs set by aospext_get_buildflags.mk
# AOSPEXT_ARCH_PREFIX
# AOSPEXT_OUT_DIR
#
# Outputs:
# AOSPEXT_INTERNAL_BUILD_TARGET target which is used as input by aospext_gen_targets.mk as a dependency

MY_PATH := $(call my-dir)

include $(LOCAL_PATH)/aospext_get_buildflags.mk

define create-pkgconfig
echo -e "Name: $2" \
        "\nDescription: $2" \
        "\nVersion: $3" > $1/$2.pc

endef

_TMP_SRC_PATH                           := $(BOARD_$(AOSPEXT_PROJECT_NAME)_SRC_DIR)
_TMP_PATCHES_DIRS                       := $(BOARD_$(AOSPEXT_PROJECT_NAME)_PATCHES_DIRS)
AOSPEXT_INTERNAL_BUILD_TARGET           := $(AOSPEXT_OUT_DIR)/.timestamp

$(if $(_TMP_SRC_PATH),,$(error Variable BOARD_$(AOSPEXT_PROJECT_NAME)_SRC_DIR is not set))

$(AOSPEXT_INTERNAL_BUILD_TARGET): AOSPEXT_BUILD_SYSTEM   := $(AOSPEXT_BUILD_SYSTEM)
$(AOSPEXT_INTERNAL_BUILD_TARGET): AOSPEXT_GEN_PKGCONFIGS := $(AOSPEXT_GEN_PKGCONFIGS)
$(AOSPEXT_INTERNAL_BUILD_TARGET): AOSPEXT_CPU_FAMILY     := $(subst arm64,aarch64,$(TARGET_$(AOSPEXT_ARCH_PREFIX)ARCH))
$(AOSPEXT_INTERNAL_BUILD_TARGET): LIBDIR_SUFFIX:=$(if $(TARGET_IS_64_BIT),$(if $(filter 64 first,$(LOCAL_MULTILIB)),64))

# meson
$(AOSPEXT_INTERNAL_BUILD_TARGET): MESON_RUST_TARGET  := $(subst arm64,aarch64,$(TARGET_$(AOSPEXT_ARCH_PREFIX)ARCH))-linux-android
$(AOSPEXT_INTERNAL_BUILD_TARGET): MESON_BUILD_ARGUMENTS:=--prefix /vendor --libdir lib$(LIBDIR_SUFFIX) --datadir etc/shared --libexecdir bin \
                                                         --sbindir bin --localstatedir=/mnt/var --buildtype=debug $(MESON_BUILD_ARGUMENTS)

# cargo
$(AOSPEXT_INTERNAL_BUILD_TARGET): CARGO_RUST_TARGET  := $(subst arm64,aarch64,$(TARGET_$(AOSPEXT_ARCH_PREFIX)ARCH))-linux-android

# ffmpeg
$(AOSPEXT_INTERNAL_BUILD_TARGET): FFMPEG_DEFINITIONS  := $(FFMPEG_DEFINITIONS)

# dirs
$(AOSPEXT_INTERNAL_BUILD_TARGET): AOSP_FLAGS_DIR_OUT := $(call relative-to-absolute,$(AOSP_FLAGS_DIR_OUT))
$(AOSPEXT_INTERNAL_BUILD_TARGET): AOSPEXT_ABS_OUT_DIR:= $(call relative-to-absolute,$(AOSPEXT_OUT_DIR))
$(AOSPEXT_INTERNAL_BUILD_TARGET): _TMP_SRC_PATH     := $(_TMP_SRC_PATH)
$(AOSPEXT_INTERNAL_BUILD_TARGET): _TMP_PATCHES_DIRS := $(_TMP_PATCHES_DIRS)
$(AOSPEXT_INTERNAL_BUILD_TARGET): _TMP_OUT_SRC_DIR  := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/out_src)
$(AOSPEXT_INTERNAL_BUILD_TARGET): _TMP_GEN_DIR      := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/gen)
$(AOSPEXT_INTERNAL_BUILD_TARGET): _TMP_BUILD_DIR    := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/build)
$(AOSPEXT_INTERNAL_BUILD_TARGET): _TMP_INSTALL_DIR  := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/install)
$(AOSPEXT_INTERNAL_BUILD_TARGET): MY_PATH:=$(MY_PATH)
$(AOSPEXT_INTERNAL_BUILD_TARGET): MY_OUT_ABS_PATH:=$(if $(patsubst /%,,$(OUT_DIR)),$(AOSP_ABSOLUTE_PATH)/$(OUT_DIR),$(OUT_DIR))
$(AOSPEXT_INTERNAL_BUILD_TARGET): MY_ABS_PATH:=$(AOSP_ABSOLUTE_PATH)/$(MY_PATH)

# toolchain
$(AOSPEXT_INTERNAL_BUILD_TARGET): LLVM_PREBUILTS_PATH:=$(LLVM_PREBUILTS_PATH)
$(AOSPEXT_INTERNAL_BUILD_TARGET): AR_TOOL:=$($($(AOSPEXT_ARCH_PREFIX))TARGET_AR)

# target dependencies:
_TMP_SRCS := $(sort $(shell find -L $(_TMP_SRC_PATH) -not -path '*/\.*'))
_TMP_PATCHES := $(if $(_TMP_PATCHES_DIRS),$(sort $(shell find -L $(_TMP_PATCHES_DIRS) -not -path '*/\.*')))
AOSPEXT_TOOLS := $(sort $(shell find -L $(MY_PATH)/tools -not -path '*/\.*'))
RUST_BIN_DIR_ABS := $(if $(RUST_BIN_DIR),$(shell cd $(RUST_BIN_DIR) && pwd),$(HOME)/.cargo/bin)

$(AOSPEXT_INTERNAL_BUILD_TARGET): $(_TMP_SRCS) $(_TMP_PATCHES) $(AOSPEXT_TOOLS)
$(AOSPEXT_INTERNAL_BUILD_TARGET): $(AOSP_FLAGS_DIR_OUT)/.exec.timestamp
$(AOSPEXT_INTERNAL_BUILD_TARGET): $(AOSP_FLAGS_DIR_OUT)/.sharedlib.timestamp
	cp $(MY_ABS_PATH)/tools/wrapper.sh $(AOSP_FLAGS_DIR_OUT)/wrapper.sh
	ln -sf ./wrapper.sh $(AOSP_FLAGS_DIR_OUT)/wrap_clang
	ln -sf ./wrapper.sh $(AOSP_FLAGS_DIR_OUT)/wrap_clang++
	ln -sf ./wrapper.sh $(AOSP_FLAGS_DIR_OUT)/wrap_rust_ld
	ln -sf ./wrapper.sh $(AOSP_FLAGS_DIR_OUT)/wrap_rust_clang
	ln -sf ./wrapper.sh $(AOSP_FLAGS_DIR_OUT)/wrap_rust_clang++
	cp $(MY_ABS_PATH)/tools/gen_aospless_dir.py $(AOSPEXT_ABS_OUT_DIR)/gen_aospless_dir.py

	cp $(MY_ABS_PATH)/tools/makefile_base.mk $(AOSPEXT_ABS_OUT_DIR)/Makefile
	cp $(MY_ABS_PATH)/tools/makefile_$(AOSPEXT_BUILD_SYSTEM).mk $(AOSPEXT_ABS_OUT_DIR)/project_specific.mk
	sed -i \
		-e 's#\[PLACE_FOR_LLVM_DIR\]#$(LLVM_PREBUILTS_PATH)#g' \
		-e 's#\[PLACE_FOR_AOSP_ROOT\]#$(AOSP_ABSOLUTE_PATH)#g' \
		-e 's#\[PLACE_FOR_AOSP_OUT_DIR\]#$(MY_OUT_ABS_PATH)#g' \
		-e 's#\[PLACE_FOR_SRC_DIR\]#$(_TMP_SRC_PATH)#g' \
		-e 's#\[PLACE_FOR_PATCHES_DIRS\]#$(_TMP_PATCHES_DIRS)#g' \
		-e 's#\[PLACE_FOR_OUT_BASE_DIR\]#$(AOSPEXT_ABS_OUT_DIR)#g' \
		$(AOSPEXT_ABS_OUT_DIR)/Makefile

	mkdir -p $(_TMP_GEN_DIR)
	$(foreach pkg, $(AOSPEXT_GEN_PKGCONFIGS), $(call create-pkgconfig,$(_TMP_GEN_DIR),$(word 1, $(subst :, ,$(pkg))),$(word 2, $(subst :, ,$(pkg)))))

# For meson build system
	sed -i \
		-e 's#\[PLACE_FOR_MESON_DEFS\]#$(MESON_BUILD_ARGUMENTS)#g' \
		$(AOSPEXT_ABS_OUT_DIR)/project_specific.mk
	# Prepare meson cross-compilation configuration file
	cp $(MY_ABS_PATH)/tools/meson_aosp_cross.cfg $(_TMP_GEN_DIR)/meson_aosp_cross
	sed -i \
		-e 's#$$(AR_TOOL)#$(AR_TOOL)#g' \
		-e 's#$$(MESON_CPU_FAMILY)#$(AOSPEXT_CPU_FAMILY)#g' \
		-e 's#$$(MESON_RUST_TARGET)#$(MESON_RUST_TARGET)#g' \
		$(_TMP_GEN_DIR)/meson_aosp_cross

# For cargo build system
	sed -i \
		-e 's#\[PLACE_FOR_RUST_TARGET\]#$(CARGO_RUST_TARGET)#g' \
		$(AOSPEXT_ABS_OUT_DIR)/project_specific.mk

# For ffmpeg custom build system
	sed -i \
		-e 's#\[PLACE_FOR_FFMPEG_DEFINITIONS\]#--libdir=/vendor/lib$(LIBDIR_SUFFIX) $(FFMPEG_DEFINITIONS)#g' \
		-e 's#\[PLACE_FOR_FFMPEG_CPU_FAMILY\]#$(AOSPEXT_CPU_FAMILY)#g' \
		$(AOSPEXT_ABS_OUT_DIR)/project_specific.mk

	# Build project
	export PATH=$(RUST_BIN_DIR_ABS):$(AOSP_ABSOLUTE_PATH)/$(LLVM_PREBUILTS_PATH):$$(cat $(OUT_DIR)/.path_interposer_origpath) && make -C $(AOSPEXT_ABS_OUT_DIR) install

	touch $@
