ARCHS = arm64 arm64e
DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MustafaSupreme
MustafaSupreme_FILES = Tweak.x
MustafaSupreme_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable
MustafaSupreme_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk
