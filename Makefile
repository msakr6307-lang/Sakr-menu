TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SakrMenu

SakrMenu_FILES = Tweak.x ArchitectMenu.mm
SakrMenu_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-function # السطر ده هو الحل
SakrMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

include $(THEOS_MAKE_FILE)/tweak.mk
