ARCHS = arm64 arm64e
TARGET = iphone:latest:11.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SakrMenu
SakrMenu_FILES = Tweak.x
SakrMenu_CFLAGS = -fobjc-arc
SakrMenu_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
