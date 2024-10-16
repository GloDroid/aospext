#!/usr/bin/make
# Variables are replaced with real data by top-level make:

AOSP_ROOT:=$(shell pwd)
AOSP_OUT_DIR:=$(shell pwd)
SRC_DIR:=./src
PATCHES_DIRS:=
LLVM_DIR:=

ifeq ($(AOSPLESS),)
AOSP_ROOT:=[PLACE_FOR_AOSP_ROOT]
AOSP_OUT_DIR:=[PLACE_FOR_AOSP_OUT_DIR]
SRC_DIR:=$(AOSP_ROOT)/[PLACE_FOR_SRC_DIR]
PATCHES_DIRS:=[PLACE_FOR_PATCHES_DIRS]
LLVM_DIR:=$(AOSP_ROOT)/[PLACE_FOR_LLVM_DIR]
endif

COPY_TARGET:=./logs/1.copy.log
PATCH_TARGET:=./logs/2.patch.log

OUT_BASE_DIR:=$(shell pwd)
OUT_SRC_DIR:=$(OUT_BASE_DIR)/out_src
OUT_INSTALL_DIR:=$(OUT_BASE_DIR)/install
OUT_BUILD_DIR:=$(OUT_BASE_DIR)/build
OUT_GEN_DIR:=$(OUT_BASE_DIR)/gen

PATCHES:=$(foreach dir,$(PATCHES_DIRS), $(sort $(shell find -L $(AOSP_ROOT)/$(dir)/*.patch -not -path '*/\.*')))

.PHONY: help cleanup copy patch configure build install
.DEFAULT_GOAL = help
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@exit || exit # Protection against running this makefile as script (otherwise it will invoke 'rm -rf /*' eventually)

cleanup: ## Cleanup
	@echo Cleaning up...
	@[ "$(OUT_SRC_DIR)" ] || ( echo "var is not set"; exit 1 )
	@[ "$(OUT_INSTALL_DIR)" ] || ( echo "var is not set"; exit 1 )
	@[ "$(OUT_BUILD_DIR)" ] || ( echo "var is not set"; exit 1 )
	@shopt -s dotglob nullglob && rm -rf $(OUT_SRC_DIR)/*
	@shopt -s dotglob nullglob && rm -rf $(OUT_INSTALL_DIR)/*
	@shopt -s dotglob nullglob && rm -rf $(OUT_BUILD_DIR)/*
	@rm ./logs/* -f

copy: ## Copy sources into intermediate directory
copy:
	@[ "$(OUT_SRC_DIR)" ] || ( echo "var is not set"; exit 1 )
	@echo Copying...
	@mkdir -p $(OUT_SRC_DIR)
	@mkdir -p ./logs
	@(shopt -s dotglob nullglob && rm -rf $(OUT_SRC_DIR)/*)
	@(shopt -s dotglob nullglob && rsync -arv $(SRC_DIR)/* $(OUT_SRC_DIR)) &> $(COPY_TARGET) || (cat $(COPY_TARGER) && exit 1)

patch: ## Patch sources in intermediate directory
patch: $(PATCH_TARGET)
$(PATCH_TARGET): copy
ifneq ($(wildcard $(SRC_DIR)/_aospext_patched),)
	@echo "Sources are already patched, skip patching..."
	@echo > $@
else
	@echo Patching...
	@(cd $(OUT_SRC_DIR) && $(foreach patch,$(PATCHES), echo -e " - Applying $(notdir $(patch))\n" && patch -f -p1 < $(patch) && echo -e "\n" &&) true) &> $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f
endif

include project_specific.mk
