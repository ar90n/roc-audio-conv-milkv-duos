ROC_TOOLKIT_VERSION     = 7d7d73cd1cf4a7cc019b6491d45b9eb772dbf4e6
ROC_TOOLKIT_SITE        = https://github.com/roc-streaming/roc-toolkit.git
ROC_TOOLKIT_SITE_METHOD = git

# Use Buildroot toolchain exclusively
ROC_TOOLKIT_HOST_TRIPLET := $(GNU_TARGET_NAME)
ROC_TOOLKIT_CC  := $(HOST_DIR)/bin/$(ROC_TOOLKIT_HOST_TRIPLET)-gcc
ROC_TOOLKIT_CXX := $(HOST_DIR)/bin/$(ROC_TOOLKIT_HOST_TRIPLET)-g++
ROC_TOOLKIT_AR  := $(HOST_DIR)/bin/$(ROC_TOOLKIT_HOST_TRIPLET)-gcc-ar
ROC_TOOLKIT_RL  := $(HOST_DIR)/bin/$(ROC_TOOLKIT_HOST_TRIPLET)-gcc-ranlib
ROC_TOOLKIT_STR := $(HOST_DIR)/bin/$(ROC_TOOLKIT_HOST_TRIPLET)-strip
ROC_TOOLKIT_SCONS := scons

# Use system deps from Buildroot; and host ragel for codegen
ROC_TOOLKIT_DEPENDENCIES = alsa-lib speexdsp libsndfile sox
define ROC_TOOLKIT_BUILD_CMDS
    cd $(@D) && \
    export PATH="$(dir $(TARGET_CC)):$$PATH" && \
    scons -Q -j$(PARALLEL_JOBS) \
        --prefix=/usr \
        --host=$(shell $(TARGET_CC) -dumpmachine) \
        --build-3rdparty=libuv,openfec \
        --disable-libunwind \
        --disable-openssl \
        --disable-pulseaudio \
        --enable-static \
        --disable-shared \
        CC="$(TARGET_CC)" \
        CXX="$(TARGET_CXX)" \
        AR="$(TARGET_AR)" \
        RANLIB="$(TARGET_RANLIB)" \
        STRIP="$(TARGET_STRIP)" \
        CFLAGS="$(TARGET_CFLAGS)" \
        CXXFLAGS="$(TARGET_CXXFLAGS)" \
        LINKFLAGS="$(TARGET_LDFLAGS)"
endef

define ROC_TOOLKIT_INSTALL_TARGET_CMDS
    cd $(@D) && \
    export PATH="$(dir $(TARGET_CC)):$$PATH" && \
    scons -Q -j$(PARALLEL_JOBS) \
        --prefix=/usr \
        --host=$(shell $(TARGET_CC) -dumpmachine) \
        --build-3rdparty=libuv,openfec \
        --disable-libunwind \
        --disable-openssl \
        --disable-pulseaudio \
        --enable-static \
        --disable-shared \
        CC="$(TARGET_CC)" \
        CXX="$(TARGET_CXX)" \
        AR="$(TARGET_AR)" \
        RANLIB="$(TARGET_RANLIB)" \
        STRIP="$(TARGET_STRIP)" \
        CFLAGS="$(TARGET_CFLAGS)" \
        CXXFLAGS="$(TARGET_CXXFLAGS)" \
        LINKFLAGS="$(TARGET_LDFLAGS)" \
        DESTDIR="$(TARGET_DIR)" \
        install
endef

$(eval $(generic-package))

