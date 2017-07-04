-- Constants

APP_REPO = "ONElua"
APP_PROJECT = "AdrenalineBubbleManager"

APP_VERSION_MAJOR = 0x00 -- major.minor
APP_VERSION_MINOR = 0x91
	
APP_VERSION = ((APP_VERSION_MAJOR << 0x18) | (APP_VERSION_MINOR << 0x10)) -- Union Binary
