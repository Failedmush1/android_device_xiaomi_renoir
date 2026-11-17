#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),renoir)
include $(call all-makefiles-under,$(LOCAL_PATH))

ifneq ($(TARGET_PREBUILT_KERNEL),)
$(PRODUCT_OUT)/kernel: $(TARGET_PREBUILT_KERNEL)
	@mkdir -p $(dir $@)
	cp $< $@
endif

ifneq ($(TARGET_PREBUILT_DTB),)
$(PRODUCT_OUT)/dtb.img: $(TARGET_PREBUILT_DTB)
	@mkdir -p $(dir $@)
	cp $< $@
endif

ifneq ($(BOARD_PREBUILT_DTBOIMAGE),)
$(PRODUCT_OUT)/dtbo.img: $(BOARD_PREBUILT_DTBOIMAGE)
	@mkdir -p $(dir $@)
	cp $< $@
endif

endif
