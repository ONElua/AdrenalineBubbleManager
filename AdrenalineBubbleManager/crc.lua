__ADR_MODULE_NAMES = {
	"adrbubblebooter.suprx",
	"adrenaline_kernel.skprx",
	"adrenaline_user.suprx",
	"adrenaline_vsh.suprx",
	"bootconv.suprx",
}

__CRCADRBOOTER = 0x039095FD
__CRCKERNEL    = 0x21BD6D72
__CRCUSER      = 0x2C6FB429
__CRCVSH       = 0x485293A1
__CRCBOOTCONV  = 0xD072FE17

__ADR_SIGNATURE_THEFLOW_V7 = {
	["adrenaline_kernel.skprx"] = 0x20F7C5CD,
	["adrenaline_user.suprx"]   = 0x5487A9C3,
	["adrenaline_vsh.suprx"]    = 0xFA85CD74,
}

__ADR_SIGNATURE_THEFLOW_LMAN = {
	["adrbubblebooter.suprx"]   = 0x039095FD,
	["adrenaline_kernel.skprx"] = 0xC9F84053,
	["adrenaline_user.suprx"]   = 0xF5116106,
	["adrenaline_vsh.suprx"]    = 0x485293A1,
	["bootconv.suprx"]          = 0xD072FE17,
}

__ADR_SIGNATURE_THEFLOW_MENU_FIX_LEGACY = {
	["adrbubblebooter.suprx"]   = 0x039095FD,
	["adrenaline_kernel.skprx"] = 0xC9F84053,
	["adrenaline_user.suprx"]   = 0x9E1B321A,
	["adrenaline_vsh.suprx"]    = 0x485293A1,
	["bootconv.suprx"]          = 0xD072FE17,
}

__ADR_SIGNATURE_THEFLOW_MENU_FIX = {
	["adrbubblebooter.suprx"]   = __CRCADRBOOTER,
	["adrenaline_kernel.skprx"] = __CRCKERNEL,
	["adrenaline_user.suprx"]   = __CRCUSER,
	["adrenaline_vsh.suprx"]    = __CRCVSH,
	["bootconv.suprx"]          = __CRCBOOTCONV,
}

__ADR_SIGNATURE_ISAGE_802 = {
	["adrenaline_kernel.skprx"] = 0x3B998F83,
	["adrenaline_user.suprx"]   = 0xEDDF100E,
	["adrenaline_vsh.suprx"]    = 0xCAE14C01,
}

__ADR_SIGNATURE_ISAGECOMPAT = {
	["adrbubblebooter.suprx"]   = 0x02C3104E,
	["adrenaline_kernel.skprx"] = 0x373BD9D6,
	["adrenaline_user.suprx"]   = 0xCB75A035,
	["adrenaline_vsh.suprx"]    = 0x2A23114D,
	["bootconv.suprx"]          = 0x84BF1418,
}

__ADR_KNOWN_THEFLOW_CORE = {
	["adrenaline_kernel.skprx"] = { 0x20F7C5CD, 0xC9F84053, 0x21BD6D72 },
	["adrenaline_user.suprx"]   = { 0x5487A9C3, 0xF5116106, 0x9E1B321A, 0x2C6FB429 },
	["adrenaline_vsh.suprx"]    = { 0xFA85CD74, 0x485293A1 },
}

__ADR_KNOWN_ISAGE_CORE = {
	["adrenaline_kernel.skprx"] = { 0x3B998F83, 0x373BD9D6 },
	["adrenaline_user.suprx"]   = { 0xEDDF100E, 0xCB75A035 },
	["adrenaline_vsh.suprx"]    = { 0xCAE14C01, 0x2A23114D },
}
