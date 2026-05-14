# اسم الجهاز أو الآي بي (اختياري لو بتنصب يدوي)
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = OneState

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SakrMenu

# ملفات السورس (تأكد إن اسم الملف عندك Tweak.x)
SakrMenu_FILES = Tweak.x
# المكتبات اللازمة للجرافيكس والمنيو (السر هنا)
SakrMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
# إضافة مكتبات إضافية لضمان الأداء
SakrMenu_PRIVATE_FRAMEWORKS = AppSupport
# إعدادات الكومبايلر
SakrMenu_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
