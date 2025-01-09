LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_PREBUILT_KERNEL),)
CYPRESS-FMAC-UPSTREAM_PATH := kernel/nvidia/cypress-fmac-upstream
LINEAGE_TOOLS_PATH := $(abspath prebuilts/tools-lineage/$(HOST_PREBUILT_TAG))
PERL5LIB := $(abspath prebuilts/tools-lineage/common/perl-base)

include $(CLEAR_VARS)

LOCAL_MODULE        := cypress-fmac-upstream
LOCAL_MODULE_SUFFIX := .ko
LOCAL_MODULE_CLASS  := ETC
LOCAL_MODULE_PATH   := $(TARGET_OUT_VENDOR)/lib/modules

_fmac_upstream_intermediates := $(call intermediates-dir-for,$(LOCAL_MODULE_CLASS),$(LOCAL_MODULE))
_fmac_upstream_ko := $(_fmac_upstream_intermediates)/$(LOCAL_MODULE)$(LOCAL_MODULE_SUFFIX)
KERNEL_OUT := $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ
KERNEL_OUT_RELATIVE := ../../KERNEL_OBJ

$(_fmac_upstream_ko): $(KERNEL_OUT)/arch/$(KERNEL_ARCH)/boot/$(BOARD_KERNEL_IMAGE_NAME)
	@mkdir -p $(dir $@)
	@mkdir -p $(KERNEL_MODULES_OUT)/lib/modules
	@cp -R $(CYPRESS-FMAC-UPSTREAM_PATH)/backports-wireless/* $(_fmac_upstream_intermediates)/
	@chmod +x $(_fmac_upstream_intermediates)/kconf/lxdialog/check-lxdialog.sh
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_MAKE_FLAGS) -C $(_fmac_upstream_intermediates) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) PERL5LIB=$(PERL5LIB) PERL=$(LINEAGE_TOOLS_PATH)/bin/perl KLIB=$(KERNEL_MODULES_OUT)/lib/modules KLIB_BUILD=$(KERNEL_OUT_RELATIVE) defconfig-brcmfmac
	$(hide) +$(KERNEL_MAKE_CMD) $(KERNEL_MAKE_FLAGS) -C $(_fmac_upstream_intermediates) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) PERL5LIB=$(PERL5LIB) PERL=$(LINEAGE_TOOLS_PATH)/bin/perl KLIB=$(KERNEL_MODULES_OUT)/lib/modules KLIB_BUILD=$(KERNEL_OUT_RELATIVE) modules
	modules=$$(find $(_fmac_upstream_intermediates) -type f -name '*.ko'); \
	for f in $$modules; do \
		$(KERNEL_TOOLCHAIN_PATH)strip --strip-unneeded $$f; \
		cp $$f $(KERNEL_MODULES_OUT)/lib/modules; \
	done;
	touch $(_fmac_upstream_intermediates)/cypress-fmac-upstream.ko

include $(BUILD_SYSTEM)/base_rules.mk
endif
