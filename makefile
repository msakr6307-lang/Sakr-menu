# إعدادات المعمارية لجهاز iPhone XS
ARCHS = arm64e
TARGET = iphone:clang:latest:12.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ArchitectMenu

# ربط الملفات البرمجية
ArchitectMenu_FILES = Tweak.x
ArchitectMenu_CFLAGS = -fobjc-arc
ArchitectMenu_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
