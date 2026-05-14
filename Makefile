ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MustafaSupreme

MustafaSupreme_FILES = Tweak.x
MustafaSupreme_CFLAGS = -fobjc-arc
MustafaSupreme_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore
MustafaSupreme_PRIVATE_FRAMEWORKS = AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk
