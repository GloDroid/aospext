#!/usr/bin/make
MESON_DEFS:=[PLACE_FOR_MESON_DEFS]

CONFIGURE_TARGET:=./logs/3.configure.log
BUILD_TARGET:=./logs/4.build.log
INSTALL_TARGET:=./logs/5.install.log

configure: ## Configure the project
configure: export BASE_DIR = $(OUT_BASE_DIR)
configure: $(CONFIGURE_TARGET)
$(CONFIGURE_TARGET): $(PATCH_TARGET)
	@echo Configuring...
	@echo "[constants]" > $(OUT_BASE_DIR)/gen/aosp_cross.out
	@echo "base_dir='$(OUT_BASE_DIR)'" >> $(OUT_BASE_DIR)/gen/aosp_cross.out
	@echo "llvm_dir='$(LLVM_DIR)'" >> $(OUT_BASE_DIR)/gen/aosp_cross.out
	@cat $(OUT_BASE_DIR)/gen/aosp_cross >> $(OUT_BASE_DIR)/gen/aosp_cross.out
	@(cd $(OUT_SRC_DIR) && meson setup $(OUT_BUILD_DIR) --cross-file $(OUT_BASE_DIR)/gen/aosp_cross.out $(MESON_DEFS)) 2>&1 > $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

build: ## Build the project
build: export BASE_DIR = $(OUT_BASE_DIR)
build: $(BUILD_TARGET)
$(BUILD_TARGET): $(CONFIGURE_TARGET)
	@echo Building...
	@mkdir -p $(OUT_BUILD_DIR)
	@ninja -C $(OUT_BUILD_DIR) 2>&1 > $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

install: ## Install the project (will execute copy, patch, configure and build prior to install)
install: $(INSTALL_TARGET)
$(INSTALL_TARGET): $(BUILD_TARGET)
	@echo Installing...
	@mkdir -p $(OUT_INSTALL_DIR)
	@DESTDIR=$(OUT_INSTALL_DIR) ninja -C $(OUT_BUILD_DIR) install 2>&1 > $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

gen_aospless: ## Generate tree for building without AOSP or NDK
	L_AOSP_ROOT=$(AOSP_ROOT) L_AOSP_OUT_DIR=$(AOSP_OUT_DIR) python3 $(OUT_BASE_DIR)/gen_aospless_dir.py
	tar -czf aospless.tar.gz aospless
