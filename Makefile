ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SakrMenu

# هنا السر: بنقول للسيرفر يربط ملف التويك مع ملفات المنيو
SakrMenu_FILES = Tweak.x ArchitectMenu.m
SakrMenu_CFLAGS = -fobjc-arc
SakrMenu_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
