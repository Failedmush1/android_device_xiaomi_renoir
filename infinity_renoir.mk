#
# Copyright (C) 2021-2024 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from renoir device
$(call inherit-product, device/xiaomi/renoir/device.mk)

# Inherit some common Infinity stuff.
$(call inherit-product, vendor/infinity/config/common_full_phone.mk)

TARGET_BOOT_ANIMATION_RES := 1080
WITH_GAPPS := false
TARGET_SHIPS_FULL_GAPPS := false
TARGET_BUILD_GOOGLE_TELEPHONY := false
TARGET_SUPPORTS_BLUR := true
USE_MOTO_CALCULATOR := true
TARGET_FACE_UNLOCK_SUPPORTED := true
TARGET_BUILD_VIMUSIC := true
INFINITY_MAINTAINER := Failedmush
INFINITY_BUILD_TYPE := UNOFFICIAL

PRODUCT_BRAND := Xiaomi
PRODUCT_DEVICE := renoir
PRODUCT_MANUFACTURER := Xiaomi
PRODUCT_MODEL := M2101K9R
PRODUCT_NAME := infinity_renoir

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="renoir_global-user 13 TKQ1.220829.002 V14.0.7.0.TKIMIXM release-keys" \
    BuildFingerprint=Xiaomi/renoir_global/renoir:13/TKQ1.220829.002/V14.0.7.0.TKIMIXM:user/release-keys \
    DeviceProduct=renoir \
    SystemName=renoir_global

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi
