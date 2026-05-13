ARCHS = arm64 arm64e
TARGET := iphone:clang:latest:14.0

DEBUG = 0
FINALPACKAGE = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SakrMenu

SakrMenu_FILES = Tweak.x ArchitectMenu.mm
SakrMenu_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-function
SakrMenu_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore

include $(THEOS)/makefiles/tweak.mk
