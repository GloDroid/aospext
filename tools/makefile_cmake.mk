#!/usr/bin/make

CMAKE_DEFS := [PLACE_FOR_CMAKE_ARGS] \
    -DCMAKE_TOOLCHAIN_FILE=$(OUT_BASE_DIR)/gen/cross.cmake.out \
    -DCMAKE_PLATFORM_NO_VERSIONED_SONAME=ON \

CMAKE_INSTALL_LIBDIR := lib[PLACE_FOR_LIBDIR_SUFFIX]

CONFIGURE_TARGET:=./logs/3.configure.log
BUILD_TARGET:=./logs/4.build.log
INSTALL_TARGET:=./logs/5.install.log

CMAKELISTS_OUT_SRC_DIR := $(OUT_SRC_DIR)/[PLACE_FOR_CMAKE_SRC_SUBDIR]

NPROC:=$(shell grep -c "^processor" /proc/cpuinfo)

configure: ## Configure the project
configure: export BASE_DIR = $(OUT_BASE_DIR)
configure: $(CONFIGURE_TARGET)
$(CONFIGURE_TARGET): $(PATCH_TARGET)
	@echo Configuring...
	@mkdir -p $(OUT_BUILD_DIR)
	@echo "set(CMAKE_SYSTEM_NAME Linux)" > $(OUT_BASE_DIR)/gen/cross.cmake.out
	@echo "set(CMAKE_C_COMPILER $(OUT_BASE_DIR)/toolchain_wrapper/wrap_c)" >> $(OUT_BASE_DIR)/gen/cross.cmake.out
	@echo "set(CMAKE_CXX_COMPILER $(OUT_BASE_DIR)/toolchain_wrapper/wrap_cxx)" >> $(OUT_BASE_DIR)/gen/cross.cmake.out
	@echo "set(CMAKE_C_FLAGS \"[C_ARGS]\")" >> $(OUT_BASE_DIR)/gen/cross.cmake.out
	@echo "set(CMAKE_CXX_FLAGS \"[CPP_ARGS]\")" >> $(OUT_BASE_DIR)/gen/cross.cmake.out
	@echo "set(CMAKE_EXE_LINKER_FLAGS \"[C_LINK_ARGS]\")" >> $(OUT_BASE_DIR)/gen/cross.cmake.out
	@echo "set(CMAKE_SHARED_LINKER_FLAGS \"[C_LINK_ARGS]\")" >> $(OUT_BASE_DIR)/gen/cross.cmake.out
	@echo "set(CMAKE_MODULE_LINKER_FLAGS \"[C_LINK_ARGS]\")" >> $(OUT_BASE_DIR)/gen/cross.cmake.out
	@echo "set(CMAKE_INSTALL_LIBDIR \"$(CMAKE_INSTALL_LIBDIR)\")" >> $(OUT_BASE_DIR)/gen/cross.cmake.out
	@(cd $(OUT_BUILD_DIR) && cmake $(CMAKE_DEFS) $(CMAKELISTS_OUT_SRC_DIR)) &> $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

build: ## Build the project
build: export BASE_DIR = $(OUT_BASE_DIR)
build: $(BUILD_TARGET)
$(BUILD_TARGET): $(CONFIGURE_TARGET)
	@echo Building...
	@make -C $(OUT_BUILD_DIR) -j$(NPROC) &> $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

install: ## Install the project (will execute copy, patch, configure and build prior to install)
install: $(INSTALL_TARGET)
$(INSTALL_TARGET): $(BUILD_TARGET)
	@echo Installing...
	@mkdir -p $(OUT_INSTALL_DIR)
	@(cd $(OUT_BUILD_DIR) && cmake --install . --prefix $(OUT_INSTALL_DIR)/vendor) &> $@.tmp || (cat $@.tmp && exit 1)
	@mv $@.tmp $@ -f

gen_aospless: ## Generate tree for building without AOSP or NDK
	L_AOSP_ROOT=$(AOSP_ROOT) L_AOSP_OUT_DIR=$(AOSP_OUT_DIR) python3 $(OUT_BASE_DIR)/gen_aospless_dir.py
	tar -czf aospless.tar.gz aospless
