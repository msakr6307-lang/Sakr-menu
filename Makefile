# إعدادات المعالج والنظام المستهدف
ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = OneState

include $(THEOS)/makefiles/common.mk

# اسم التويك (تأكد إنه نفس الاسم في ملف الـ control)
TWEAK_NAME = SakrMenu

# ملفات السورس (تأكد إن اسم الملف هو Tweak.x)
SakrMenu_FILES = Tweak.x

# المكتبات الأساسية (السر في تشغيل الدائرة واللمس)
SakrMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

# مكتبات إضافية لضمان استقرار المنيو
SakrMenu_PRIVATE_FRAMEWORKS = AppSupport

# إعدادات الكومبايلر (إدارة الذاكرة التلقائية)
SakrMenu_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
