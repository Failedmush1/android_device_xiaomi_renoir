#
# Copyright (C) 2021-2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from renoir device
$(call inherit-product, device/xiaomi/renoir/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

#Axion Bringup!

AXION_CAMERA_REAR_INFO := 64,13,5

AXION_CAMERA_FRONT_INFO := 20

AXION_MAINTAINER := Failedmush

AXION_PROCESSOR := Snapdragon_780g

TARGET_DISABLE_EPPE := true
TARGET_ENABLE_BLUR := true

AXION_CPU_PRIME_CORES := 7
AXION_CPU_BIG_CORES := 4,5,6
AXION_CPU_SMALL_CORES := 0,1,2,3

PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.axion_cpu_prime=$(AXION_CPU_PRIME_CORES) \
    persist.sys.axion_cpu_big=$(AXION_CPU_BIG_CORES) \
    persist.sys.axion_cpu_small=$(AXION_CPU_SMALL_CORES)

# Boot animation
TARGET_BOOT_ANIMATION_RES := 1080

PRODUCT_BRAND := Xiaomi
PRODUCT_DEVICE := renoir
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := M2101K9R
PRODUCT_NAME := lineage_renoir

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="renoir_global-user 13 TKQ1.220829.002 V14.0.7.0.TKIMIXM release-keys" \
    BuildFingerprint=Xiaomi/renoir_global/renoir:13/TKQ1.220829.002/V14.0.7.0.TKIMIXM:user/release-keys \
    DeviceProduct=renoir \
    SystemName=renoir_global

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
