--[[ 
	Adrenaline Bubble Manager VPK.
	Create and organize your direct adrenaline bubbles.
	
	Licensed by GNU General Public License v3.0
	
	Designed By:
	- Gdljjrod (https://twitter.com/gdljjrod).
	- DevDavisNunez (https://twitter.com/DevDavisNunez).
]]

day = tonumber(os.date("%d"))
month = tonumber(os.date("%m"))
snow = false
if (month == 12 and (day >= 20 and day <= 25)) then snow = true end

--Show splash ...
local splash = image.load("resources/splash.png")
if splash then splash:blit(0,0) end
screen.flip()
splash=nil

dofile("crc.lua")
dofile("system/scroll.lua")
dofile("system/lang.lua")
dofile("system/commons.lua")
dofile("system/callbacks.lua")
if os.access() == 0 then
	if back2 then back2:blit(0,0) end
	screen.flip()
	custom_msg(UNSAFE_MODE,0)
	os.exit()
end

__ITLS = os.lmodule("itlsKernel")

dofile("git/shared.lua")

-- ABM Update (requires __UPDATE from commons.lua)
if __UPDATE == 1 then
	dofile("git/updater.lua")
end

ADRENALINE = "ux0:app/PSPEMUCFW"

local function readAdrenalineModuleCrcs()
	local installed = {}
	for i=1,#__ADR_MODULE_NAMES do
		local name = __ADR_MODULE_NAMES[i]
		local path = ADRENALINE.."/sce_module/"..name
		if files.exists(path) then
			local data = files.read(path)
			if data then installed[name] = os.crc32(data) end
		end
	end
	return installed
end

local function matchesSignature(installed, signature)
	for name, crc in pairs(signature) do
		if installed[name] != crc then return false end
	end
	return true
end

local function containsCrc(values, crc)
	for i=1,#values do
		if values[i] == crc then return true end
	end
	return false
end

local function matchesKnownCore(installed, known)
	for name, values in pairs(known) do
		if not containsCrc(values, installed[name]) then return false end
	end
	return true
end

local function detectAdrenaline(installed)
	if matchesSignature(installed, __ADR_SIGNATURE_THEFLOW_MENU_FIX) then
		return "theflow", "theflow-menu-label-fix"
	elseif matchesSignature(installed, __ADR_SIGNATURE_THEFLOW_LMAN) then
		return "theflow", "theflow-lman"
	elseif matchesSignature(installed, __ADR_SIGNATURE_THEFLOW_MENU_FIX_LEGACY) then
		return "theflow", "theflow-menu-label-fix-legacy"
	elseif matchesSignature(installed, __ADR_SIGNATURE_ISAGECOMPAT) then
		return "isage", "isage-isagecompat"
	elseif matchesSignature(installed, __ADR_SIGNATURE_THEFLOW_V7) then
		return "theflow", "theflow-v7"
	elseif matchesSignature(installed, __ADR_SIGNATURE_ISAGE_802) then
		return "isage", "isage-v8.0.2"
	elseif matchesKnownCore(installed, __ADR_KNOWN_THEFLOW_CORE) then
		return "theflow", "theflow-incomplete"
	elseif matchesKnownCore(installed, __ADR_KNOWN_ISAGE_CORE) then
		return "isage", "isage-incomplete"
	end
	return nil, "unsupported"
end

local installed_modules = readAdrenalineModuleCrcs()
ADRENALINE_FAMILY, ADRENALINE_STATE = detectAdrenaline(installed_modules)

if ADRENALINE_FAMILY == "isage" then
	STRINGS_RESTORE_ADR = "Restore Adrenaline 8.0.2"
	STRINGS_DESC_RESTORE_ADR = "Reinstall the original Isage Adrenaline 8.0.2 modules"
	STRINGS_RESTART_ADR = "Adrenaline 8.0.2 has been restored, a reboot is needed"
end

local target_source = nil
local target_signature = nil
ADRENALINE_RESTORE_SOURCE = nil

if ADRENALINE_FAMILY == "theflow" then
	target_source = "modules/sce_module_abm_v7/"
	target_signature = __ADR_SIGNATURE_THEFLOW_MENU_FIX
	ADRENALINE_RESTORE_SOURCE = "bubbles/restore_adrenaline_v7/sce_module/"
elseif ADRENALINE_FAMILY == "isage" then
	target_source = "modules/sce_module_abm_8.0.2/"
	target_signature = __ADR_SIGNATURE_ISAGECOMPAT
	ADRENALINE_RESTORE_SOURCE = "bubbles/restore_adrenaline_8.0.2/sce_module/"
end

MODULES = nil
if target_source then
	MODULES = {}
	for i=1,#__ADR_MODULE_NAMES do
		local name = __ADR_MODULE_NAMES[i]
		table.insert(MODULES, {
			name = name,
			fullpath = ADRENALINE.."/sce_module/"..name,
			path = target_source..name,
			crc = target_signature[name],
		})
	end
end

function restoreAdrenalineModules()
	if not ADRENALINE_RESTORE_SOURCE then return false end
	files.copy(ADRENALINE_RESTORE_SOURCE, ADRENALINE)
	return true
end

oncopy = false

if game.exists("PSPEMUCFW") and files.exists(ADRENALINE) and
	files.exists(ADRENALINE.."/eboot.bin") and files.exists(ADRENALINE.."/eboot.pbp") then

	if not files.exists(ADRENALINE.."/adrenaline.bin") then
		oncopy = true
		files.copy("bubbles/adrenaline.bin", ADRENALINE)
		oncopy = false
	end

	if not files.exists(ADRENALINE.."/menucolor.bin") then
		files.copy("bubbles/menucolor.bin", ADRENALINE)
	end

	if __CHECKADR == 1 then
		if not MODULES then
			os.dialog(ADRENALINE_UNSUPPORTED)
		elseif not files.exists(ADRENALINE.."/sce_module/adrbubblebooter.suprx") then
			oncopy = true
			files.copy(target_source, ADRENALINE.."/sce_module/")
		else

			for i=1,#MODULES do
				if installed_modules[MODULES[i].name] != MODULES[i].crc then
					oncopy = true
					files.copy(MODULES[i].path, ADRENALINE.."/sce_module/")
				end
			end
		end

		if oncopy then
			if back2 then back2:blit(0,0) end
			screen.flip()
			os.dialog(ADRBBOTER_INSTALLED)
			os.delay(500)
		end

	end--__CHECKADR

	if oncopy then

		--Make Bubbles compatible with new boot.bin
		local list = game.list(__GAME_LIST_APP)
		table.sort(list ,function (a,b) return string.lower(a.id)<string.lower(b.id) end)

		oncopy = false
		for i=1, #list do
			
			if files.exists(list[i].path.."/data/boot.inf") then
				if not files.exists(list[i].path.."/data/boot.bin") then
				
					if back2 then back2:blit(0,0) end
					message_wait(UPDATE_BUBBLES..list[i].id)
					os.delay(50)

					AutoMakeBootBin(list[i])

				end
			end

		end--for
		custom_msg(ADRENALINE_LAUNCH_FIRST,0)
		os.delay(1000)
		power.restart()
	end

	dofile("system/stars.lua")
	dofile("system/scan.lua")
	dofile("system/bubbles.lua")
	dofile("system/resources.lua")

	bubbles.scan()
	scan.games()
	scan.show()

else
	custom_msg(ADRENALINE_NOT_INSTALLED,0)
end
