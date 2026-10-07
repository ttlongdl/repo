TARGET = iphone:clang:16.5:15.0
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AboutSpoofPrefs
AboutSpoofPrefs_FILES = ABSRootListController.m
AboutSpoofPrefs_FRAMEWORKS = UIKit
AboutSpoofPrefs_LDFLAGS = -undefined dynamic_lookup
AboutSpoofPrefs_INSTALL_PATH = /Library/PreferenceBundles
AboutSpoofPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
