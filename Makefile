ARCHS = arm64
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SakrMenu
SakrMenu_FILES = Tweak.x
SakrMenu_CFLAGS = -fobjc-arc
SakrMenu_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
