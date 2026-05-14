ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = OneState

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SakrMenu

# ملف البرمجيات الأساسي
SakrMenu_FILES = Tweak.x
# المكتبات اللي كانت ناقصة وبتعمل Error في الصور
SakrMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
SakrMenu_PRIVATE_FRAMEWORKS = AppSupport
# تفعيل المترجم الحديث لمنع مشاكل الذاكرة
SakrMenu_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
