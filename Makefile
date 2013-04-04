include theos/makefiles/common.mk

TWEAK_NAME = SecretNowPlaying
SecretNowPlaying_FILES = Tweak.xm
SecretNowPlaying_FRAMEWORKS = CoreGraphics UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
