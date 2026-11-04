THEOS_PACKAGE_SCHEME = rootless
TARGET               = iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

# ── Tweak ──────────────────────────────────────────────────────────────────
TWEAK_NAME            = AdservioFilter
AdservioFilter_FILES  = Tweak.x
AdservioFilter_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/tweak.mk

# ── Preferences Bundle ─────────────────────────────────────────────────────
BUNDLE_NAME                      = AdservioFilterPrefs
AdservioFilterPrefs_FILES        = Prefs/RootListController.mm
AdservioFilterPrefs_INSTALL_PATH = /var/jb/Library/PreferenceBundles
AdservioFilterPrefs_CFLAGS       = -fobjc-arc
AdservioFilterPrefs_FRAMEWORKS   = UIKit CoreFoundation Preferences

include $(THEOS)/makefiles/bundle.mk
