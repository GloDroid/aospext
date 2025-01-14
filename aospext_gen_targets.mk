# SPDX-License-Identifier: Apache-2.0
#
# AOSPEXT project (https://github.com/GloDroid/aospext)
#
# Copyright (C) 2021 GlobalLogic Ukraine
# Copyright (C) 2021-2024 Roman Stratiienko (r.stratiienko@gmail.com)

# Inputs:
# AOSPEXT_GEN_TARGETS array
# AOSPEXT_TARGETS_SO_DEPS array
# AOSPEXT_INTERNAL_BUILD_TARGET
# AOSPEXT_EXPORT_INSTALLED_INCLUDE_DIRS (optional)
# AOSPEXT_EXTRA_DEPS (optional)

__TMP_AOSPEXT_PROJECT_INSTALL_DIR := $(dir $(AOSPEXT_INTERNAL_BUILD_TARGET))/install

__TMP_C_INCLUDE_DIRS := $(LOCAL_EXPORT_C_INCLUDE_DIRS)
__TMP_C_INCLUDE_DIRS += $(foreach dir,$(AOSPEXT_EXPORT_INSTALLED_INCLUDE_DIRS), $(__TMP_AOSPEXT_PROJECT_INSTALL_DIR)/$(dir))

__TMP_MULTILIB := $(LOCAL_MULTILIB)
__TMP_SHARED_LIBRARIES := $(LOCAL_SHARED_LIBRARIES)

__TMP_BASE_DIR := $(AOSPEXT_PARTITION)

__TMP_CLASSES_bin := EXECUTABLES
__TMP_CLASSES_lib := SHARED_LIBRARIES
__TMP_CLASSES_libetc := ETC
__TMP_CLASSES_etc := ETC
__TMP_SUFFIX_bin :=
__TMP_SUFFIX_lib := .so
__TMP_SUFFIX_libetc :=
__TMP_SUFFIX_etc :=
__TMP_DIR_bin := $(__TMP_BASE_DIR)/bin
__TMP_DIR_lib := $(__TMP_BASE_DIR)/lib$(if $(TARGET_IS_64_BIT),$(if $(filter 64 first,$(LOCAL_MULTILIB)),64))
__TMP_DIR_libetc := $(__TMP_BASE_DIR)/lib$(if $(TARGET_IS_64_BIT),$(if $(filter 64 first,$(LOCAL_MULTILIB)),64))
__TMP_DIR_etc := $(__TMP_BASE_DIR)/etc

define unwrap_target
__TYPE := $(word 1,$1)
__PATHNAME = $(word 2,$1)
__SUBDIR := $(word 3,$1)
__PATH_OVERRIDE := $(if $(filter libetc,$(word 1,$1)),$(PRODUCT_OUT)/$(__TMP_DIR_libetc))
__MODULE := $(word 4,$1)
__SYMLINK_SUFFIX := $(word 5,$1)
__SKIP := $(if $(filter lib first,$(__TMP_MULTILIB) $(word 1,$1)),,true)
endef

define gen_module_for_target

# Target should be already created after $(AOSPEXT_INTERNAL_BUILD_TARGET) finished.
# So just define a target for KATI + update timestamp
$(__TMP_AOSPEXT_PROJECT_INSTALL_DIR)/$(__TMP_DIR_$(__TYPE))/$(__PATHNAME): $(AOSPEXT_INTERNAL_BUILD_TARGET) $(AOSPEXT_EXTRA_DEPS)
	touch -ch $$@

include $(CLEAR_VARS)
LOCAL_MODULE_CLASS := $(__TMP_CLASSES_$(__TYPE))
LOCAL_MODULE_SUFFIX := $(__TMP_SUFFIX_$(__TYPE))
LOCAL_MODULE := $(__MODULE)
LOCAL_VENDOR_MODULE := $(if $(filter vendor,$(AOSPEXT_PARTITION)),true)
LOCAL_PRODUCT_MODULE := $(if $(filter product,$(AOSPEXT_PARTITION)),true)
LOCAL_SYSTEM_EXT_MODULE := $(if $(filter system_ext,$(AOSPEXT_PARTITION)),true)
LOCAL_MODULE_PATH := $(__PATH_OVERRIDE)
LOCAL_MODULE_RELATIVE_PATH := $(__SUBDIR)
LOCAL_PREBUILT_MODULE_FILE := $(__TMP_AOSPEXT_PROJECT_INSTALL_DIR)/$(__TMP_DIR_$(__TYPE))/$(__PATHNAME)
LOCAL_MULTILIB := $(__TMP_MULTILIB)
LOCAL_CHECK_ELF_FILES := false
LOCAL_MODULE_SYMLINKS := $(if $(__SYMLINK_SUFFIX),$(__MODULE)$(__SYMLINK_SUFFIX))
LOCAL_SHARED_LIBRARIES := $(__TMP_SHARED_LIBRARIES) $(foreach dep,$(AOSPEXT_TARGETS_SO_DEPS),$(if $(filter $(word 1,$(subst =, ,$(dep))),$(__MODULE)), $(subst :, ,$(word 2,$(subst =, ,$(dep))))))
LOCAL_EXPORT_C_INCLUDE_DIRS := $(__TMP_C_INCLUDE_DIRS)

include $(BUILD_PREBUILT)

endef

$(foreach target,$(AOSPEXT_GEN_TARGETS),$(eval $(call unwrap_target,$(subst $(space)$(space),$(space)$$(empty)$(space),$(subst :, ,$(target)))))$(if $(__SKIP),,$(eval $(call gen_module_for_target))))
