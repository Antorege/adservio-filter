ARCHS = arm64
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME            = AdservioFilter
AdservioFilter_FILES  = Tweak.x
AdservioFilter_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/tweak.mk

BUNDLE_NAME                      = AdservioFilterPrefs
AdservioFilterPrefs_FILES        = Prefs/RootListController.mm
AdservioFilterPrefs_INSTALL_PATH = /var/jb/Library/PreferenceBundles
AdservioFilterPrefs_CFLAGS       = -fobjc-arc
AdservioFilterPrefs_FRAMEWORKS   = UIKit CoreFoundation Preferences
AdservioFilterPrefs_LDFLAGS      = -F$(THEOS)/vendor/lib -F$(THEOS)/lib

include $(THEOS)/makefiles/bundle.mk
