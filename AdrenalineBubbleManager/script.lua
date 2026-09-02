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

if ADRENALINE_FAMILY == "theflow" then
	STRINGS_RESTORE_ADR = "Restore Adrenaline v7"
	STRINGS_DESC_RESTORE_ADR = "Reinstall the original TheOfficialFloW Adrenaline v7 modules"
	STRINGS_RESTART_ADR = "Adrenaline v7 has been restored, a reboot is needed"
elseif ADRENALINE_FAMILY == "isage" then
	STRINGS_RESTORE_ADR = "Restore Adrenaline 8.0.2"
	STRINGS_DESC_RESTORE_ADR = "Reinstall the original isage Adrenaline 8.0.2 modules"
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

local function crc_hex(v)
	if v == nil then return "MISSING" end
	return string.format("0x%08X", v)
end

local function read_module_crc(fullpath)
	if not files.exists(fullpath) then return nil end
	local data = files.read(fullpath)
	if not data then return nil end
	return os.crc32(data)
end

-- Log CRC of Adrenaline modules before/after install
local __ABM_MOD_LOG = "ux0:data/ABM/module_install_log.txt"
local function append_mod_log(lines)
	files.mkdir("ux0:data/ABM/")
	local prev = ""
	if files.exists(__ABM_MOD_LOG) then
		prev = files.read(__ABM_MOD_LOG) or ""
	end
	local chunk = table.concat(lines, "\n") .. "\n"
	files.write(__ABM_MOD_LOG, prev .. chunk)
end

-- Copy each ABM module into Adrenaline/sce_module and verify CRC when known.
local function installAbmModules(force_all)
	if not MODULES then return false, false end
	files.mkdir(ADRENALINE.."/sce_module")

	local lines = {}
	table.insert(lines, "===== ABM module install " .. os.date("%Y-%m-%d %H:%M:%S") .. " =====")
	table.insert(lines, "family=" .. tostring(ADRENALINE_FAMILY) .. " state=" .. tostring(ADRENALINE_STATE))
	table.insert(lines, "target_source=" .. tostring(target_source))
	table.insert(lines, "force_all=" .. tostring(force_all))
	table.insert(lines, "")
	table.insert(lines, "--- BEFORE copy (installed on device) ---")

	for i=1,#MODULES do
		local m = MODULES[i]
		local before = installed_modules[m.name]
		if before == nil then
			before = read_module_crc(m.fullpath)
		end
		table.insert(lines, string.format(
			"  %s  before=%s  expected=%s  src=%s",
			m.name, crc_hex(before), crc_hex(m.crc), tostring(m.path)
		))
	end

	local copied, verified = false, true
	for i=1,#MODULES do
		local m = MODULES[i]
		local need = force_all or (installed_modules[m.name] != m.crc)
		if need then
			if not files.exists(m.path) then
				verified = false
				table.insert(lines, "  COPY FAIL missing source: " .. tostring(m.path))
			else
				files.copy(m.path, ADRENALINE.."/sce_module/")
				copied = true
			end
		end
	end

	table.insert(lines, "")
	table.insert(lines, "--- AFTER copy (re-read from device) ---")
	for i=1,#MODULES do
		local m = MODULES[i]
		local after = read_module_crc(m.fullpath)
		local ok = (after != nil and m.crc != nil and after == m.crc)
		if m.crc and after != m.crc then
			verified = false
		end
		if after == nil then
			verified = false
		end
		if after then
			installed_modules[m.name] = after
		end
		table.insert(lines, string.format(
			"  %s  after=%s  expected=%s  %s",
			m.name, crc_hex(after), crc_hex(m.crc), ok and "OK" or "MISMATCH"
		))
	end
	table.insert(lines, "")
	table.insert(lines, "result: copied=" .. tostring(copied) .. " verified=" .. tostring(verified))
	table.insert(lines, "")
	append_mod_log(lines)

	return copied, verified
end

function restoreAdrenalineModules()
	if not ADRENALINE_RESTORE_SOURCE then return false end
	files.mkdir(ADRENALINE.."/sce_module")

	-- Stock Adrenaline modules only (not adrbubblebooter/bootconv)
	local names = {
		"adrenaline_kernel.skprx",
		"adrenaline_user.suprx",
		"adrenaline_vsh.suprx",
		"usbdevice.skprx",
	}

	local lines = {}
	table.insert(lines, "===== ABM restore " .. os.date("%Y-%m-%d %H:%M:%S") .. " =====")
	table.insert(lines, "family=" .. tostring(ADRENALINE_FAMILY))
	table.insert(lines, "restore_source=" .. tostring(ADRENALINE_RESTORE_SOURCE))
	table.insert(lines, "")
	table.insert(lines, "--- BEFORE restore ---")

	local any_src = false
	for i=1,#names do
		local name = names[i]
		local full = ADRENALINE.."/sce_module/"..name
		local src = ADRENALINE_RESTORE_SOURCE..name
		local before = read_module_crc(full)
		table.insert(lines, string.format(
			"  %s  before=%s  src_exists=%s",
			name, crc_hex(before), tostring(files.exists(src))
		))
		if files.exists(src) then any_src = true end
	end

	if not any_src then
		table.insert(lines, "result: FAIL no restore source files")
		table.insert(lines, "")
		append_mod_log(lines)
		return false
	end

	-- File-by-file into sce_module/ (never copy the folder — avoids nesting)
	for i=1,#names do
		local name = names[i]
		local src = ADRENALINE_RESTORE_SOURCE..name
		if files.exists(src) then
			files.copy(src, ADRENALINE.."/sce_module/")
		end
	end

	table.insert(lines, "")
	table.insert(lines, "--- AFTER restore ---")
	local ok = true
	for i=1,#names do
		local name = names[i]
		local full = ADRENALINE.."/sce_module/"..name
		local src = ADRENALINE_RESTORE_SOURCE..name
		local after = read_module_crc(full)
		local src_crc = nil
		if files.exists(src) then
			local data = files.read(src)
			if data then src_crc = os.crc32(data) end
		end
		local match = (after != nil and src_crc != nil and after == src_crc)
		if files.exists(src) and not match then ok = false end
		table.insert(lines, string.format(
			"  %s  after=%s  pack=%s  %s",
			name, crc_hex(after), crc_hex(src_crc), match and "OK" or "MISMATCH"
		))
	end
	table.insert(lines, "result: " .. (ok and "OK" or "FAIL"))
	table.insert(lines, "")
	append_mod_log(lines)
	return ok
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
		else
			local force_all = not files.exists(ADRENALINE.."/sce_module/adrbubblebooter.suprx")
			local copied, verified = installAbmModules(force_all)
			if copied then
				oncopy = true
				if back2 then back2:blit(0,0) end
				screen.flip()
				if verified then
					os.dialog(ADRBBOTER_INSTALLED)
				else
					os.dialog(ADRENALINE_UNSUPPORTED)
					oncopy = false
				end
				os.delay(500)
			end
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
