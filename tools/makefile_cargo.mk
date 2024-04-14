#!/usr/bin/make

RUST_TARGET_ARCH := [PLACE_FOR_RUST_TARGET]

LOCAL_PATH := $(shell pwd)
CARGO_ARGS := -v --target-dir $(OUT_BUILD_DIR)

CONFIG_TOML := $(OUT_SRC_DIR)/.cargo/config.toml

CONFIGURE_TARGET:=./logs/3.configure.log
BUILD_TARGET:=./logs/4.build.log
INSTALL_TARGET:=./logs/5.install.log

CARGO_ARGS+=$(if $(wildcard $(SRC_DIR)/vendor),--offline)

CARGO_ENV := \
    CC=$(LOCAL_PATH)/toolchain_wrapper/wrap_rust_c \
    CXX=$(LOCAL_PATH)/toolchain_wrapper/wrap_rust_cxx \
    AR=$(if $(LLVM_DIR),$(LLVM_DIR)/,)llvm-ar \

configure: ## Configure the project
configure: export BASE_DIR = $(OUT_BASE_DIR)
configure: $(CONFIGURE_TARGET)
$(CONFIGURE_TARGET): $(PATCH_TARGET)
	@echo Configuring...
	@echo "Generating cargo configuration file:" > $@
	@mkdir -p $(dir $(CONFIG_TOML))
	@echo "[build]" > $(CONFIG_TOML)
	@echo "target = [\"$(RUST_TARGET_ARCH)\"]" >> $(CONFIG_TOML)
	@echo "[target.$(RUST_TARGET_ARCH)]" >> $(CONFIG_TOML)
	@echo "linker = \"$(LOCAL_PATH)/toolchain_wrapper/wrap_rust_ld\"" >> $(CONFIG_TOML)
	@echo "rustflags = [\"-Clink-arg=-fuse-ld=lld\"]" >> $(CONFIG_TOML)
ifneq ($(wildcard $(SRC_DIR)/vendor),)
	@echo "[source.crates-io]" >> $(CONFIG_TOML)
	@echo "replace-with = 'vendored-sources'" >> $(CONFIG_TOML)
	@echo "[source.vendored-sources]" >> $(CONFIG_TOML)
	@echo "directory = '$(OUT_SRC_DIR)/vendor'" >> $(CONFIG_TOML)
endif
	@cat $(CONFIG_TOML) >> $@

build: ## Build the project
build: export BASE_DIR = $(OUT_BASE_DIR)
build: $(BUILD_TARGET)
$(BUILD_TARGET): $(CONFIGURE_TARGET)
	@echo Building...
	@mkdir -p $(OUT_BUILD_DIR)
	@bash -c 'cd $(OUT_SRC_DIR) && $(CARGO_ENV) cargo build --release $(CARGO_ARGS)' &> $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

install: ## Install the project (will execute copy, patch, configure and build prior to install)
install: $(INSTALL_TARGET)
$(INSTALL_TARGET): $(BUILD_TARGET)
	@echo Installing...
	@mkdir -p $(OUT_INSTALL_DIR)/vendor/bin/hw
	@(bash -x $(OUT_SRC_DIR)/aospext.install.sh $(OUT_SRC_DIR) $(OUT_BUILD_DIR)/$(RUST_TARGET_ARCH)/release/ $(OUT_INSTALL_DIR) &> $@.tmp) || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

gen_aospless: ## Generate tree for building without AOSP or NDK
	L_AOSP_ROOT=$(AOSP_ROOT) L_AOSP_OUT_DIR=$(AOSP_OUT_DIR) python3 $(OUT_BASE_DIR)/gen_aospless_dir.py
	tar -czf aospless.tar.gz aospless
