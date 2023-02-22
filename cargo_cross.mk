# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2023 The GloDroid project

MY_PATH := $(call my-dir)

include $(LOCAL_PATH)/aospext_get_buildflags.mk

CARGO_SRC_PATH                           := $(BOARD_$(AOSPEXT_PROJECT_NAME)_SRC_DIR)
CARGO_PATCHES_DIRS                       := $(BOARD_$(AOSPEXT_PROJECT_NAME)_PATCHES_DIRS)
CARGO_GEN_FILES_TARGET                   := $(AOSPEXT_OUT_DIR)/.timestamp

$(CARGO_GEN_FILES_TARGET): CARGO_RUST_TARGET  := $(subst arm64,aarch64,$(TARGET_$(AOSPEXT_ARCH_PREFIX)ARCH))-linux-android
$(CARGO_GEN_FILES_TARGET): AOSP_FLAGS_DIR_OUT := $(call relative-to-absolute,$(AOSP_FLAGS_DIR_OUT))
$(CARGO_GEN_FILES_TARGET): AOSPEXT_ABS_OUT_DIR:= $(call relative-to-absolute,$(AOSPEXT_OUT_DIR))
$(CARGO_GEN_FILES_TARGET): CARGO_OUT_SRC_DIR  := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/out_src)
$(CARGO_GEN_FILES_TARGET): CARGO_BUILD_DIR    := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/build)
$(CARGO_GEN_FILES_TARGET): CARGO_INSTALL_DIR  := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/install)

$(CARGO_GEN_FILES_TARGET): MY_PATH:=$(MY_PATH)
$(CARGO_GEN_FILES_TARGET): CARGO_SRC_PATH:=$(CARGO_SRC_PATH)
$(CARGO_GEN_FILES_TARGET): LIBDIR:=lib$(if $(TARGET_IS_64_BIT),$(if $(filter 64 first,$(LOCAL_MULTILIB)),64))

$(CARGO_GEN_FILES_TARGET): MY_OUT_ABS_PATH:=$(if $(patsubst /%,,$(OUT_DIR)),$(AOSP_ABSOLUTE_PATH)/$(OUT_DIR),$(OUT_DIR))
$(CARGO_GEN_FILES_TARGET): MY_ABS_PATH:=$(AOSP_ABSOLUTE_PATH)/$(MY_PATH)
$(CARGO_GEN_FILES_TARGET): LLVM_PREBUILTS_PATH:=$(LLVM_PREBUILTS_PATH)

AOSPEXT_TOOLS := $(sort $(shell find -L $(MY_PATH)/tools -not -path '*/\.*'))
CARGO_SRCS := $(sort $(shell find -L $(CARGO_SRC_PATH) -not -path '*/\.*'))
CARGO_PATCHES := $(if $(CARGO_PATCHES_DIRS),$(sort $(shell find -L $(CARGO_PATCHES_DIRS) -not -path '*/\.*')))
RUST_BIN_DIR_ABS := $(if $(RUST_BIN_DIR),$(shell cd $(RUST_BIN_DIR) && pwd),$(HOME)/.cargo/bin)

$(CARGO_GEN_FILES_TARGET): $(CARGO_SRCS) $(CARGO_PATCHES) $(AOSPEXT_TOOLS)
$(CARGO_GEN_FILES_TARGET): CARGO_PATCHES_DIRS:=$(CARGO_PATCHES_DIRS)
$(CARGO_GEN_FILES_TARGET): $(AOSP_FLAGS_DIR_OUT)/.exec.timestamp
$(CARGO_GEN_FILES_TARGET): $(AOSP_FLAGS_DIR_OUT)/.sharedlib.timestamp
	cp $(MY_ABS_PATH)/tools/wrapper.sh $(AOSP_FLAGS_DIR_OUT)/wrapper.sh
	ln -sf ./wrapper.sh $(AOSP_FLAGS_DIR_OUT)/wrap_rust_ld
	cp $(MY_ABS_PATH)/tools/gen_aospless_dir.py $(AOSPEXT_ABS_OUT_DIR)/gen_aospless_dir.py

	cp $(MY_ABS_PATH)/tools/makefile_base.mk $(AOSPEXT_ABS_OUT_DIR)/Makefile
	cp $(MY_ABS_PATH)/tools/makefile_cargo.mk $(AOSPEXT_ABS_OUT_DIR)/project_specific.mk
	sed -i \
		-e 's#\[PLACE_FOR_LLVM_DIR\]#$(LLVM_PREBUILTS_PATH)#g' \
		-e 's#\[PLACE_FOR_AOSP_ROOT\]#$(AOSP_ABSOLUTE_PATH)#g' \
		-e 's#\[PLACE_FOR_AOSP_OUT_DIR\]#$(MY_OUT_ABS_PATH)#g' \
		-e 's#\[PLACE_FOR_SRC_DIR\]#$(CARGO_SRC_PATH)#g' \
		-e 's#\[PLACE_FOR_PATCHES_DIRS\]#$(CARGO_PATCHES_DIRS)#g' \
		-e 's#\[PLACE_FOR_OUT_BASE_DIR\]#$(AOSPEXT_ABS_OUT_DIR)#g' \
		$(AOSPEXT_ABS_OUT_DIR)/Makefile

	sed -i \
		-e 's#\[PLACE_FOR_RUST_TARGET\]#$(CARGO_RUST_TARGET)#g' \
		$(AOSPEXT_ABS_OUT_DIR)/project_specific.mk

	# Build CARGO project
	export $$(cat /etc/environment):$(RUST_BIN_DIR_ABS):$(AOSP_ABSOLUTE_PATH)/$(LLVM_PREBUILTS_PATH) && make -C $(AOSPEXT_ABS_OUT_DIR) install

	touch $@
