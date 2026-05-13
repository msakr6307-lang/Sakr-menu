ARCHS = arm64e
TARGET = iphone:clang:latest:12.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SakrMenu

# ربط ملف الكود الأساسي
SakrMenu_FILES = Tweak.x

# المكتبات المطلوبة للرسوميات، التحكم في المسافة، والواجهة السوداء
SakrMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

# إعدادات البناء لضمان أفضل أداء (Final Package)
SakrMenu_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
