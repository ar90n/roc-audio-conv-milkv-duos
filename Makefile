SDK_DIR := $(CURDIR)/vendor/duo-buildroot-sdk-v2
BR2_EXTERNAL := $(CURDIR)/external
DL_DIR ?= $(CURDIR)/.dl
OUT_DIR ?= $(CURDIR)/output
CCACHE_DIR ?= $(CURDIR)/ccache
JOBS ?= $(shell nproc)

SDK_TARGET_BOARD := milkv-duos-musl-riscv64-sd
SDK_BUILDROOT_DIR := $(SDK_DIR)/buildroot
SDK_OUTPUT_DIR := $(SDK_DIR)/buildroot/output/$(SDK_TARGET_BOARD)
ENV_FILE := $(CURDIR)/.env
TEMPLATE_DIR := $(BR2_EXTERNAL)/template
OVERLAY_DIR := $(BR2_EXTERNAL)/overlay

export BR2_EXTERNAL
export BR2_DL_DIR=$(DL_DIR)
export CCACHE_DIR
export FORCE_UNSAFE_CONFIGURE=1

.PHONY: fetch
fetch:
	@wget -O /tmp/duo-dl.tar "https://github.com/milkv-duo/duo-buildroot-sdk-v2/releases/download/dl/dl.tar"; \
	tar xvf /tmp/duo-dl.tar -C "$(SDK_DIR)"; \
	rm -f /tmp/duo-dl.tar

.PHONY: init
init: fetch
	TOP=$(SDK_DIR) $(SDK_DIR)/build.sh $(SDK_TARGET_BOARD);

.PHONY: gen
gen:
	@set -a ; \
	source $(ENV_FILE); \
	set +a ; \
	envsubst < $(TEMPLATE_DIR)/wpa_supplicant.conf > $(OVERLAY_DIR)/etc/wpa_supplicant.conf; \
	envsubst < $(TEMPLATE_DIR)/roc-aoip > $(OVERLAY_DIR)/etc/default/roc-aoip; \

.PHONY: menuconfig
menuconfig:
	@$(MAKE) -C $(SDK_OUTPUT_DIR) menuconfig

.PHONY: savedefconfig
savedefconfig:
	@$(MAKE) -C $(SDK_OUTPUT_DIR) savedefconfig

.PHONY: loaddotconfig
loaddotconfig:
	TOP=$(SDK_DIR) source $(SDK_DIR)/build/envsetup_milkv.sh $(SDK_TARGET_BOARD); \
	cp $(BR2_EXTERNAL)/config/buildroot_dot_config $(SDK_OUTPUT_DIR)/.config; \
	mkdir -p $(SDK_DIR)/linux_5.10/build/$${MV_BOARD_LINK}; \
	cp $(BR2_EXTERNAL)/config/kernel_dot_config $(SDK_DIR)/linux_5.10/build/$${MV_BOARD_LINK}/.config

.PHONY: syncdefconfig_kernel
syncdefconfig_kernel:
	TOP=$(SDK_DIR) source $(SDK_DIR)/build/envsetup_milkv.sh $(SDK_TARGET_BOARD); \
	for CONFIG in `cat $(DEFCONFIG) | grep -v -E '^#' | sed 's/^CONFIG_//g'`; do setconfig_kernel $${CONFIG}; done 

.PHONY: menuconfig_kernel
menuconfig_kernel:
	TOP=$(SDK_DIR) source $(SDK_DIR)/build/envsetup_milkv.sh $(SDK_TARGET_BOARD); \
	menuconfig_kernel

.PHONY: setconfig_kernel
setconfig_kernel:
	TOP=$(SDK_DIR) source $(SDK_DIR)/build/envsetup_milkv.sh $(SDK_TARGET_BOARD); \
	setconfig_kernel $(CONFIG)

.PHONY: build_all
build_all:
	TOP=$(SDK_DIR) source $(SDK_DIR)/build/envsetup_milkv.sh $(SDK_TARGET_BOARD); \
	build_all

.PHONY: clean_all
clean_all:
	TOP=$(SDK_DIR) source $(SDK_DIR)/build/envsetup_milkv.sh $(SDK_TARGET_BOARD); \
	clean_all

.PHONY: pack_sd_image
pack_sd_image:
	TOP=$(SDK_DIR) source $(SDK_DIR)/build/envsetup_milkv.sh $(SDK_TARGET_BOARD); \
	pack_sd_image

all: gen clean_all loaddotconfig savedefconfig build_all pack_sd_image
