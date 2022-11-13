#!/usr/bin/make

FFMPEG_DEFINITIONS := [PLACE_FOR_FFMPEG_DEFINITIONS]
FFMPEG_CPU_FAMILY := [PLACE_FOR_FFMPEG_CPU_FAMILY]

CONFIGURE_TARGET:=./logs/3.configure.log
BUILD_TARGET:=./logs/4.build.log
INSTALL_TARGET:=./logs/5.install.log

NPROCS:=$(shell grep -c ^processor /proc/cpuinfo)

CONFIGURE_CMD:=configure \
    --prefix=/vendor \
    --cc=$(OUT_BASE_DIR)/toolchain_wrapper/wrap_c \
    --arch=$(FFMPEG_CPU_FAMILY) --target-os=android \
    --extra-cflags=[C_ARGS] \
    --extra-ldflags=[C_LINK_ARGS] \
    --enable-cross-compile \
    --strip=$(LLVM_DIR)/llvm-strip \
    $(FFMPEG_DEFINITIONS)

configure: ## Configure the project
configure: $(CONFIGURE_TARGET)
$(CONFIGURE_TARGET): $(PATCH_TARGET)
	@echo Configuring...
	@mkdir -p $(OUT_BUILD_DIR)
	@bash -c 'export PKG_CONFIG_PATH=$(OUT_BASE_DIR)/gen && cd $(OUT_BUILD_DIR) && $(OUT_SRC_DIR)/$(CONFIGURE_CMD)' &> $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

build: ## Build the project
build: $(BUILD_TARGET)
$(BUILD_TARGET): $(CONFIGURE_TARGET)
	@echo Building...
	@bash -c 'cd $(OUT_BUILD_DIR) && make -j$(NPROCS)' &> $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

install: ## Install the project (will execute copy, patch, configure and build prior to install)
install: $(INSTALL_TARGET)
$(INSTALL_TARGET): $(BUILD_TARGET)
	@echo Installing...
	@mkdir -p $(OUT_INSTALL_DIR)
	@bash -c 'cd $(OUT_BUILD_DIR) && DESTDIR=$(OUT_INSTALL_DIR) make install' &> $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

gen_aospless: ## Generate tree for building without AOSP or NDK
	L_AOSP_ROOT=$(AOSP_ROOT) L_AOSP_OUT_DIR=$(AOSP_OUT_DIR) python3 $(OUT_BASE_DIR)/gen_aospless_dir.py
	tar -czf aospless.tar.gz aospless
