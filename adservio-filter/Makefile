ARCHS = arm64
THEOS_PACKAGE_SCHEME = rootless
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME            = AdservioFilter
AdservioFilter_FILES  = Tweak.x
AdservioFilter_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/tweak.mk
