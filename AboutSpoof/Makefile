ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:15.0
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AboutSpoof
AboutSpoof_FILES = Tweak.xm
AboutSpoof_CFLAGS = -fobjc-arc
AboutSpoof_FRAMEWORKS = Foundation

SUBPROJECTS += aboutspoofprefs

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 Preferences || true"
