# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2023 The GloDroid project

MY_PATH := $(call my-dir)

include $(LOCAL_PATH)/aospext_get_buildflags.mk

FFMPEG_SRC_PATH                           := $(BOARD_$(AOSPEXT_PROJECT_NAME)_SRC_DIR)
FFMPEG_PATCHES_DIRS                       := $(BOARD_$(AOSPEXT_PROJECT_NAME)_PATCHES_DIRS)
FFMPEG_GEN_FILES_TARGET                   := $(AOSPEXT_OUT_DIR)/.timestamp

$(FFMPEG_GEN_FILES_TARGET): FFMPEG_CPU_FAMILY   := $(subst arm64,aarch64,$(TARGET_$(AOSPEXT_ARCH_PREFIX)ARCH))
$(FFMPEG_GEN_FILES_TARGET): FFMPEG_DEFINITIONS  := $(FFMPEG_DEFINITIONS)
$(FFMPEG_GEN_FILES_TARGET): AOSP_FLAGS_DIR_OUT  := $(call relative-to-absolute,$(AOSP_FLAGS_DIR_OUT))
$(FFMPEG_GEN_FILES_TARGET): AOSPEXT_ABS_OUT_DIR := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR))
$(FFMPEG_GEN_FILES_TARGET): FFMPEG_OUT_SRC_DIR  := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/out_src)
$(FFMPEG_GEN_FILES_TARGET): FFMPEG_BUILD_DIR    := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/build)
$(FFMPEG_GEN_FILES_TARGET): FFMPEG_GEN_DIR      := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/gen)
$(FFMPEG_GEN_FILES_TARGET): FFMPEG_INSTALL_DIR  := $(call relative-to-absolute,$(AOSPEXT_OUT_DIR)/install)

$(FFMPEG_GEN_FILES_TARGET): MY_PATH:=$(MY_PATH)
$(FFMPEG_GEN_FILES_TARGET): FFMPEG_SRC_PATH:=$(FFMPEG_SRC_PATH)
$(FFMPEG_GEN_FILES_TARGET): LIBDIR:=lib$(if $(TARGET_IS_64_BIT),$(if $(filter 64 first,$(LOCAL_MULTILIB)),64))

$(FFMPEG_GEN_FILES_TARGET): FFMPEG_GEN_PKGCONFIGS:=$(FFMPEG_GEN_PKGCONFIGS)
$(FFMPEG_GEN_FILES_TARGET): MY_OUT_ABS_PATH:=$(if $(patsubst /%,,$(OUT_DIR)),$(AOSP_ABSOLUTE_PATH)/$(OUT_DIR),$(OUT_DIR))
$(FFMPEG_GEN_FILES_TARGET): MY_ABS_PATH:=$(AOSP_ABSOLUTE_PATH)/$(MY_PATH)
$(FFMPEG_GEN_FILES_TARGET): LLVM_PREBUILTS_PATH:=$(LLVM_PREBUILTS_PATH)

AOSPEXT_TOOLS := $(sort $(shell find -L $(MY_PATH)/tools -not -path '*/\.*'))
FFMPEG_SRCS := $(sort $(shell find -L $(FFMPEG_SRC_PATH) -not -path '*/\.*'))
FFMPEG_PATCHES := $(if $(FFMPEG_PATCHES_DIRS),$(sort $(shell find -L $(FFMPEG_PATCHES_DIRS) -not -path '*/\.*')))

$(FFMPEG_GEN_FILES_TARGET): $(FFMPEG_SRCS) $(FFMPEG_PATCHES) $(AOSPEXT_TOOLS)
$(FFMPEG_GEN_FILES_TARGET): FFMPEG_PATCHES_DIRS:=$(FFMPEG_PATCHES_DIRS)
$(FFMPEG_GEN_FILES_TARGET): $(AOSP_FLAGS_DIR_OUT)/.exec.timestamp
$(FFMPEG_GEN_FILES_TARGET): $(AOSP_FLAGS_DIR_OUT)/.sharedlib.timestamp
	cp $(MY_ABS_PATH)/tools/wrapper.sh $(AOSP_FLAGS_DIR_OUT)/wrapper.sh
	ln -sf ./wrapper.sh $(AOSP_FLAGS_DIR_OUT)/wrap_c
	cp $(MY_ABS_PATH)/tools/gen_aospless_dir.py $(AOSPEXT_ABS_OUT_DIR)/gen_aospless_dir.py

	cp $(MY_ABS_PATH)/tools/makefile_base.mk $(AOSPEXT_ABS_OUT_DIR)/Makefile
	cp $(MY_ABS_PATH)/tools/makefile_ffmpeg.mk $(AOSPEXT_ABS_OUT_DIR)/project_specific.mk
	sed -i \
		-e 's#\[PLACE_FOR_LLVM_DIR\]#$(LLVM_PREBUILTS_PATH)#g' \
		-e 's#\[PLACE_FOR_AOSP_ROOT\]#$(AOSP_ABSOLUTE_PATH)#g' \
		-e 's#\[PLACE_FOR_AOSP_OUT_DIR\]#$(MY_OUT_ABS_PATH)#g' \
		-e 's#\[PLACE_FOR_SRC_DIR\]#$(FFMPEG_SRC_PATH)#g' \
		-e 's#\[PLACE_FOR_PATCHES_DIRS\]#$(FFMPEG_PATCHES_DIRS)#g' \
		-e 's#\[PLACE_FOR_OUT_BASE_DIR\]#$(AOSPEXT_ABS_OUT_DIR)#g' \
		$(AOSPEXT_ABS_OUT_DIR)/Makefile

	sed -i \
		-e 's#\[PLACE_FOR_FFMPEG_DEFINITIONS\]#--libdir=/vendor/$(LIBDIR) $(FFMPEG_DEFINITIONS)#g' \
		-e 's#\[PLACE_FOR_FFMPEG_CPU_FAMILY\]#$(FFMPEG_CPU_FAMILY)#g' \
		$(AOSPEXT_ABS_OUT_DIR)/project_specific.mk

	mkdir -p $(FFMPEG_GEN_DIR)
	$(foreach pkg, $(FFMPEG_GEN_PKGCONFIGS), $(call create-pkgconfig,$(FFMPEG_GEN_DIR),$(word 1, $(subst :, ,$(pkg))),$(word 2, $(subst :, ,$(pkg)))))

	# Build FFMPEG project
	export $$(cat /etc/environment):$(RUST_BIN_DIR_ABS):$(AOSP_ABSOLUTE_PATH)/$(LLVM_PREBUILTS_PATH) && make -C $(AOSPEXT_ABS_OUT_DIR) install

	touch $@
