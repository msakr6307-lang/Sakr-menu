export THEOS := $(shell pwd)/theos

ARCHS = arm64 arm64e
TARGET = iphone:latest:11.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MUSTAFA_VIP
MUSTAFA_VIP_FILES = Tweak.x
MUSTAFA_VIP_CFLAGS = -fobjc-arc
MUSTAFA_VIP_FRAMEWORKS = UIKit

include $(THEOS)/makefiles/tweak.mk
