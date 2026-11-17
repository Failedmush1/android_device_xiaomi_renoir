#
# Copyright (C) 2021 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/renoir

# Inherit from sm8350-common
include device/xiaomi/sm8350-common/BoardConfigCommon.mk

# Assert
TARGET_OTA_ASSERT_DEVICE := renoir|renoir_global|renoir_jp|renoir_ru|renoir_eea_global

# Board
TARGET_BOOTLOADER_BOARD_NAME := renoir

# Camera
TARGET_CAMERA_OVERRIDE_FORMAT_FROM_RESERVED := true

# HIDL
DEVICE_MANIFEST_FILE += $(DEVICE_PATH)/hidl/manifest.xml

# Init
TARGET_INIT_VENDOR_LIB := //$(DEVICE_PATH):libinit_renoir
TARGET_RECOVERY_DEVICE_MODULES := libinit_renoir

# Prebuilt Linux 6.18 Kernel
KERNEL_PATH := device/xiaomi/renoir-kernel-6.18
TARGET_PREBUILT_KERNEL := $(KERNEL_PATH)/Image
BOARD_PREBUILT_DTBOIMAGE := $(KERNEL_PATH)/dtbo.img
TARGET_PREBUILT_DTB := $(KERNEL_PATH)/dtb.img

BOARD_VENDOR_KERNEL_MODULES := $(wildcard $(KERNEL_PATH)/vendor_ramdisk/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(KERNEL_PATH)/vendor_ramdisk/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(KERNEL_PATH)/vendor_ramdisk/modules.load))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD)

BOARD_KERNEL_CMDLINE += androidboot.selinux=permissive
BOARD_KERNEL_CMDLINE += binder.impl=rust iommu.strict=1 deferred_probe_timeout=-1 redwood.nlmsg_legacy
# Partitions
BOARD_DTBOIMG_PARTITION_SIZE := 25165824

# Vibrator
SOONG_CONFIG_NAMESPACES += XIAOMI_VIBRATOR
SOONG_CONFIG_XIAOMI_VIBRATOR := USE_EFFECT_STREAM
SOONG_CONFIG_XIAOMI_VIBRATOR_USE_EFFECT_STREAM := true

# Include proprietary files
include vendor/xiaomi/renoir/BoardConfigVendor.mk
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop
