ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = OneState

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SakrMenu

# تأكد أن اسم الملف في المجلد هو Tweak.x بالظبط
SakrMenu_FILES = Tweak.x
# إضافة المكتبات المسؤولة عن الرسم (الدائرة) واللمس (الأيقونة)
SakrMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
# دعم إضافي للنظام
SakrMenu_PRIVATE_FRAMEWORKS = AppSupport
# تفعيل إدارة الذاكرة التلقائية لمنع الكراش
SakrMenu_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
