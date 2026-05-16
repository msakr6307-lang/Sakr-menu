export TARGET = iphone:latest:11.0
export ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SakrMenu
SakrMenu_FILES = Tweak.x
SakrMenu_CFLAGS = -fobjc-arc
SakrMenu_FRAMEWORKS = UIKit

# Disable codesigning
SakrMenu_CODESIGN = echo "Skipping codesign"

include $(THEOS)/makefiles/tweak.mk
