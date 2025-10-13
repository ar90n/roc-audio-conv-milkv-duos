RTL8XXXU_VERSION      = refs/heads/main
RTL8XXXU_SITE         = https://github.com/lwfinger/rtl8xxxu.git
RTL8XXXU_SITE_METHOD  = git

# Require the SDK-provided kernel build tree (exposed by Buildroot as LINUX_DIR).
# Do not add any Kconfig dependency; fail fast at build time if missing.
RTL8XXXU_KERNEL_DIR  := $(strip $(KERNEL_PATH))
RTL8XXXU_BUILD_DIR   := ${RTL8XXXU_KERNEL_DIR}/build/${MV_BOARD_LINK}

define RTL8XXXU_BUILD_CMDS
    env
    env | grep sg2000
    $(MAKE) -C $(RTL8XXXU_KERNEL_DIR) O=$(RTL8XXXU_BUILD_DIR) \
        M="$(@D)" ARCH=$(KERNEL_ARCH) CROSS_COMPILE="$(TARGET_CROSS)" \
        modules
endef

define RTL8XXXU_INSTALL_TARGET_CMDS
    mkdir -p "$(TARGET_DIR)/mnt/system/ko"
    { \
        mod="$$(find "$(@D)" -maxdepth 1 -type f -name '*.ko' | head -n1)"; \
        test -n "$$mod" || { echo "ERROR: no .ko built"; exit 1; }; \
        $(INSTALL) -m 0644 "$$mod" "$(TARGET_DIR)/mnt/system/ko/rtl8xxxu.ko"; \
    }
endef

$(eval $(generic-package))
