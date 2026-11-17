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

# Kernel
KERNEL_FRAGMENT_CONFIG := vendor/renoir_QGKI.config

# Kernel modules
BOARD_VENDOR_KERNEL_MODULES += \
    $(KERNEL_MODULES_OUT)/focaltech_touch.ko \
    $(KERNEL_MODULES_OUT)/fpc1020_tee.ko \
    $(KERNEL_MODULES_OUT)/goodix_core.ko \
    $(KERNEL_MODULES_OUT)/goodix_ts_gesture.ko \
    $(KERNEL_MODULES_OUT)/goodix_ts_tools.ko \
    $(KERNEL_MODULES_OUT)/qcom-hv-haptics.ko \
    $(KERNEL_MODULES_OUT)/xiaomi_touch.ko
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(BOOT_KERNEL_MODULES)

# Partitions
BOARD_DTBOIMG_PARTITION_SIZE := 25165824

# Vibrator
SOONG_CONFIG_NAMESPACES += XIAOMI_VIBRATOR
SOONG_CONFIG_XIAOMI_VIBRATOR := USE_EFFECT_STREAM
SOONG_CONFIG_XIAOMI_VIBRATOR_USE_EFFECT_STREAM := true

# Include proprietary files
include vendor/xiaomi/renoir/BoardConfigVendor.mk
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop
