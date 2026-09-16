--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

PSP_IMG = image.load("bubbles/sce_sys_lman/psp/bg0.png")
PSX_IMG = image.load("bubbles/sce_sys_lman/ps1/bg0.png")

--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 
scan = {}
scan.list = {}
toinstall = 0
local pic1,icon0 = nil,nil
--local crono, clicked = timer.new(), false -- Timer and Oldstate to click actions.
local tmp_sort = __SORT


-- format label from files.type only (not filename extension)
local function scan_format_label(v)
	local n = tonumber(v)
	if n == 1 then return "pbp"
	elseif n == 2 then return "iso"
	elseif n == 3 then return "cso"
	elseif n == 4 then return "dax"
	elseif n == 9 then return "zso"
	end
	local s = string.lower(tostring(v != nil and v or ""))
	if s == "pbp" or s == "iso" or s == "cso" or s == "dax" or s == "zso" then
		return s
	end
	return ""
end

-- fixed group order for Format sort
local function scan_platform_label(cat)
	local c = string.upper(tostring(cat or ""))
	if c == "ME" then return "PSX"
	elseif c == "MG" then return "HB"
	elseif c == "UG" or c == "EG" or c == "PG" then return "PSP"
	end
	return "--"
end

local FORMAT_ORDER = {
	["iso"] = 1,
	["cso"] = 2,
	["pbp"] = 3,
	["dax"] = 4,
	["zso"] = 5,
}

-- mtime may be unix number OR "DD/MM/YYYY HH:MM:SS" string from files.list
local function scan_mtime_value(v)
	if v == nil then return 0 end
	local n = tonumber(v)
	if n then return n end
	local s = tostring(v)
	local d, m, y, h, mi, sec = s:match("^(%d+)/(%d+)/(%d+)%s+(%d+):(%d+):(%d+)")
	if not y then
		d, m, y = s:match("^(%d+)/(%d+)/(%d+)")
		h, mi, sec = 0, 0, 0
	end
	if y and m and d then
		return tonumber(string.format("%04d%02d%02d%02d%02d%02d",
			tonumber(y), tonumber(m), tonumber(d),
			tonumber(h) or 0, tonumber(mi) or 0, tonumber(sec) or 0)) or 0
	end
	-- ISO-like YYYY-MM-DD
	y, m, d, h, mi, sec = s:match("^(%d+)%-(%d+)%-(%d+)[%sT]+(%d+):(%d+):(%d+)")
	if not y then
		y, m, d = s:match("^(%d+)%-(%d+)%-(%d+)")
		h, mi, sec = 0, 0, 0
	end
	if y and m and d then
		return tonumber(string.format("%04d%02d%02d%02d%02d%02d",
			tonumber(y), tonumber(m), tonumber(d),
			tonumber(h) or 0, tonumber(mi) or 0, tonumber(sec) or 0)) or 0
	end
	return 0
end

-- Sort rules:
-- title / gameid : single key A-Z
-- mtime          : newest first (numeric desc)
-- device / install : group key, then title A-Z
-- type (category) / format : group key, then title A-Z
local function scan_sort_cmp(a, b)
	local key = sort_mode[__SORT]

	local function title_lt()
		local ta = string.lower(tostring(a.title or a.name or ""))
		local tb = string.lower(tostring(b.title or b.name or ""))
		if ta != tb then return ta < tb end
		return string.lower(tostring(a.path or "")) < string.lower(tostring(b.path or ""))
	end

	if key == "mtime" then
		local na = scan_mtime_value(a.mtime)
		local nb = scan_mtime_value(b.mtime)
		if na != nb then return na > nb end  -- newest first
		return title_lt()
	end

	if key == "title" then
		return title_lt()
	end

	if key == "gameid" then
		local sa = string.lower(tostring(a.gameid or ""))
		local sb = string.lower(tostring(b.gameid or ""))
		if sa != sb then return sa < sb end
		return title_lt()
	end

	if key == "format" then
		local fa = scan_format_label(a.format)
		local fb = scan_format_label(b.format)
		local oa = FORMAT_ORDER[fa] or 99
		local ob = FORMAT_ORDER[fb] or 99
		if oa != ob then return oa < ob end
		return title_lt()
	end

	local va = a[key]
	local vb = b[key]
	if key == "device" then
		local na = tonumber(va) or 0
		local nb = tonumber(vb) or 0
		if na != nb then return na < nb end
		return title_lt()
	end

	local sa = string.lower(tostring(va != nil and va or ""))
	local sb = string.lower(tostring(vb != nil and vb or ""))
	if sa != sb then return sa < sb end
	return title_lt()
end


-- Visible list line: Title [PSP/PSX/HB] + extra field
local function scan_device_name(dev)
	local n = tonumber(dev)
	if n and partitions and partitions[n] then
		return tostring(partitions[n]):gsub(":$", "")
	end
	return tostring(dev != nil and dev or "?")
end

local function scan_row_text(obj)
	if not obj then return "" end
	local title = obj.title or obj.name or ""
	local plat = scan_platform_label(obj.type)
	local text = string.format("%s  [%s]", title, plat)

	local key = sort_mode and sort_mode[__SORT] or "title"
	if key == "type" then
		text = text .. "  [" .. tostring(obj.type or "") .. "]"
	elseif key == "device" then
		text = text .. "  [" .. scan_device_name(obj.device) .. "]"
	elseif key == "format" then
		text = text .. "  [" .. tostring(obj.format or "") .. "]"
--	elseif key == "mtime" then
--		text = text .. "  [" .. tostring(obj.mtime != nil and obj.mtime or "") .. "]"
--	elseif key == "gameid" then
--		text = text .. "  [" .. tostring(obj.gameid or "") .. "]"
	end
	return text
end

local function scan_refresh_labels()
	if not scan.list then return end
	for i = 1, #scan.list do
		local t = scan_row_text(scan.list[i])
		scan.list[i].label = t
		scan.list[i].width = screen.textwidth(t)
	end
end

-- One line per game → ux0:data/ABM/debug_log.txt (truncated each scan)
-- Log PATH first so a crash still leaves the last game attempted
local function scan_debug_log(line)
	files.mkdir("ux0:data/ABM/")
	local f = io.open("ux0:data/ABM/debug_log.txt", "a")
	if f then
		f:write(line)
		if line:sub(-1) != "\n" then f:write("\n") end
		f:close()
	end
end

function insert(tmp_sfo,obj,device,official,ext)

	local install,state,orig = "a",false,false

	for i=1,bubbles.len do
		if obj.path:lower() == bubbles.list[i].iso:lower() then
			install,state = "b",true
			break
		end
	end

	if official then orig = official end

	if tmp_sfo.TITLE then tmp_sfo.TITLE = tmp_sfo.TITLE:gsub("\n","") end
	if tmp_sfo.TITLE then tmp_sfo.TITLE = tmp_sfo.TITLE:gsub("\r","") end

	local title = tmp_sfo.TITLE or obj.name or ""
	local cat = tmp_sfo.CATEGORY or STRINGS_UNK

	-- Build entry first, then label from current sort mode
	local entry = {
		  title = title, title_bubble = title, path = obj.path:lower(), name = obj.name, inst = false, icon = true,
		  install = install, state = state, selcc = __COLOR, setpack = setpack,
		  nostretched=false, mtime = obj.mtime, type = cat, gameid = tmp_sfo.DISC_ID or STRINGS_UNK,
		  orig = orig, device = device, template = _template, format = scan_format_label(ext), raw_type = ext
		}
	entry.label = scan_row_text(entry)
	entry.width = screen.textwidth(entry.label)
	table.insert(scan.list, entry)
end

-- isage 8.0.2 + ABM (firma ISAGECOMPAT)
local allow_zso_dax = (ADRENALINE_FAMILY == "isage" and ADRENALINE_STATE == "isage-isagecompat")
function scan.insertCISO(hand, device)
	init_msg(string.format(DEBUG_LOAD_CISO.." %s\n", hand.path))

	-- Path first (if later step fails, last log line is this game)
	scan_debug_log(string.format("SCAN | kind=CISO | path=%s", tostring(hand.path)))

	local _type = files.type(hand.path)
	-- 2=ISO 3=CSO ; 4=DAX 9=ZSO solo con isage+ABM
	if not (_type == 2 or _type == 3 or (allow_zso_dax and (_type == 4 or _type == 9))) then
		scan_debug_log(string.format(
			"SKIP | kind=CISO | files.type=%s | path=%s",
			tostring(_type), tostring(hand.path)))
		return
	end

	local tmp0 = game.info(hand.path)
	if not tmp0 then
		scan_debug_log(string.format(
			"FAIL | kind=CISO | files.type=%s | reason=info_nil | path=%s",
			tostring(_type), tostring(hand.path)))
		return
	end

	local cat = tmp0.CATEGORY
	if (cat == nil or cat == "") then
		cat = "UG"
		tmp0.CATEGORY = "UG"
	end

	if cat == "UG" or cat == "PG" then
		insert(tmp0, hand, device, false, _type)
		local item = scan.list[#scan.list]
		scan_debug_log(string.format(
			"OK | kind=CISO | files.type=%s | label=%s | CAT=%s | TITLE=%s | DISC_ID=%s | path=%s",
			tostring(_type),
			tostring(item and item.format),
			tostring(cat),
			tostring(item and item.title),
			tostring(item and item.gameid),
			tostring(hand.path)))
	else
		scan_debug_log(string.format(
			"SKIP | kind=CISO | files.type=%s | CAT=%s | TITLE=%s | path=%s",
			tostring(_type), tostring(cat), tostring(tmp0.TITLE), tostring(hand.path)))
	end

	tmp0 = nil
end

function scan.isos(path,device)
	local tmp = files.list(path)
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if tmp[i].directory then
				local ls=files.listfiles(tmp[i].path)
				if ls and #ls > 0 then
					for j=1, #ls do
						local ext = ls[j].ext and ls[j].ext:upper() or ""
						if ext == "ISO" or ext == "CSO"
							or (allow_zso_dax and (ext == "ZSO" or ext == "DAX")) then
							scan.insertCISO(ls[j], device)
						end
					end
				end
			else
				local ext = tmp[i].ext:upper()
				if ext == "ISO" or ext == "CSO"
					or (allow_zso_dax and (ext == "ZSO" or ext == "DAX")) then
					scan.insertCISO(tmp[i], device)-- Recursive only 2 levels
				end
			end

		end
	end
end

function scan.insertPBP(hand,device)
	init_msg(string.format(DEBUG_LOAD_PBP.." %s\n",hand.path))
	local orig = false
	if game.exists(hand.name) then orig = true end

	scan_debug_log(string.format("SCAN | kind=PBP | path=%s", tostring(hand.path)))

	local _type = files.type(hand.path)
	if _type != 1 then
		scan_debug_log(string.format("SKIP | kind=PBP | files.type=%s | path=%s", tostring(_type), tostring(hand.path)))
		return
	end

	local tmp0 = game.info(hand.path)
	if not tmp0 then
		scan_debug_log(string.format("FAIL | kind=PBP | files.type=%s | reason=info_nil | path=%s", tostring(_type), tostring(hand.path)))
		return
	end
	if tmp0.CATEGORY == "PG" then
		scan_debug_log(string.format("SKIP | kind=PBP | files.type=%s | CAT=PG | path=%s", tostring(_type), tostring(hand.path)))
		return
	end
	if tmp0.DISC_ID == "MSTKUPDATE" then
		scan_debug_log(string.format("SKIP | kind=PBP | files.type=%s | DISC_ID=MSTKUPDATE | path=%s", tostring(_type), tostring(hand.path)))
		return
	end

	insert(tmp0, hand, device, orig, _type)
	local item = scan.list[#scan.list]
	scan_debug_log(string.format("OK | kind=PBP | files.type=%s | label=%s | CAT=%s | TITLE=%s | DISC_ID=%s | path=%s",
		tostring(_type),
		tostring(item and item.format),
		tostring(item and item.type),
		tostring(item and item.title),
		tostring(item and item.gameid),
		tostring(hand.path)))
	tmp0 = nil
end

function scan.pbps(path, device, level)
	if not level then level = 1 end
	local tmp = files.listdirs(path)
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if files.exists(tmp[i].path.."/EBOOT.PBP") and not files.exists(tmp[i].path.."/CHAPTER5.BIN") then
				tmp[i].path += "/EBOOT.PBP"
				scan.insertPBP(tmp[i],device)
			elseif level == 1 then
				scan.pbps(tmp[i].path, device, 2)                     -- Recursive only 2 levels
			end
		end
	end
end

function scan.games()
	files.mkdir("ux0:data/ABM/")
	files.write("ux0:data/ABM/debug_log.txt",
		"===== ABM debug_log " .. os.date("%Y-%m-%d %H:%M:%S") .. " =====\n" ..
		"# SCAN=path first; then OK/FAIL/SKIP\n")
	for i=1,#partitions do
		if files.exists(partitions[i]) then
			local _info_device = os.devinfo(partitions[i])
			if _info_device then
				scan.isos(partitions[i].."pspemu/ISO", i)
				scan.pbps(partitions[i].."pspemu/PSP/GAME", i)
			end
		end
	end
	scan.len = #scan.list
	if scan.len > 0 then
		table.sort(scan.list, scan_sort_cmp)
		scan_refresh_labels()
	end
end

function load_pic1(obj)
	pic1, style = nil, nil
	if obj.setpack != STRINGS_PSP_PSX_BUBBLES then return end

	local src = (obj.type == "ME") and PSX_IMG or PSP_IMG
	if not src then return end

	pic1 = src:copy()
	if pic1 then
		pic1:resize(805,390)
	end
end

function load_style(obj)
	--os.message(obj.template)
	if obj.template == "A5" then
		style = a5
	elseif obj.template == "PSMOBILE" then
		style = psmobile
	elseif obj.template == "PS1EMU" then
		style = ps1emu
	elseif obj.template == "PSPEMU" then
		style = pspemu
	end
end

local maximg = 14
function scan.show(objedit)

	local scr = newScroll(scan.list,maximg)

	buttons.interval(12,5)
	local xscr,xscrtitle = 15,25

	--load 1st
	if scr.maxim > 0 then
		load_pic1(scan.list[1])
	end

	local xb,yb = 820,60
	while true do
		power.tick(__POWER_TICK_ALL)
		buttons.read()
			touch.read()

		if back1 then back1:blit(0,0) end
		if pic1 then pic1:blit(0,30,155) end
		if snow then stars.render() end

		draw.fillrect(0,0,960,30, 0x64545353) --UP
		
		if buttons.analogry<-60 and scr.maxim > 0 then
			if scan.list[scr.sel].width > (960-130-40) then
				xscrtitle = screen.print(xscrtitle, 5, scan.list[scr.sel].label or scan.list[scr.sel].title,1,color.white, color.blue,__SLEFT,960-130-40)
			else
				screen.print(25,5,scan.list[scr.sel].label or scan.list[scr.sel].title, 1, color.white, color.blue)
			end
		else
			screen.print(480,5,SCAN_TITLE, 1, color.white, color.blue, __ACENTER)
		end

		local b_str = (tostring(batt.lifepercent()).."%" or "")
		if batt.charging() then b_str = b_str.." ⚡" end
		screen.print(950,5, BUBBLES_COUNT.." "..scr.maxim.." "..b_str.." ("..os.date("%H:%M")..")", 1, color.yellow, color.gray, __ARIGHT)

		if scr.maxim > 0 then

			if buttons.analogry<-60 then
				load_style(scan.list[scr.sel])
				if style then style:blit(0,30,125) end
			end
			--Blit List
			local y = 40
			for i=scr.ini,scr.lim do

				if scan.list[i].state then ccolor = color.green:a(200) else ccolor = color.white end

				if i == scr.sel then

					if buttons.analogry<-60 then
					else
						draw.fillrect(1,y-5,960-130-27,26,color.blue:a(160))
					end

					if not icon0 then
						if scan.list[scr.sel].icon then
							icon0 = game.geticon0(scan.list[scr.sel].path)
							if icon0 then
								if icon0:getrealw() != 80 or icon0:getrealw() != 80 then
									if scan.list[scr.sel].nostretched then
										icon0:resize(128,128)
									else
										icon0:resize(100,55)
									end
								else
									scan.list[scr.sel].noscaled = true
									if scan.list[scr.sel].nostretched then
										icon0:resize(128,128)
									end
								end
								icon0:center()
								icon0:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
							else
								scan.list[scr.sel].icon = false
							end
						end
					end

				end

				screen.clip(0,25,800,555)
					if i == scr.sel then
						if buttons.analogry<-60 then
						else
							if scan.list[i].width > (960-130-60) then
								xscrtitle = screen.print(xscrtitle, y, scan.list[i].label or scan.list[i].title,1,ccolor,color.shine,__SLEFT,960-130-60)
							else
								screen.print(25,y,scan.list[i].label or scan.list[i].title, 1, ccolor, color.shine)
							end
						end
					else
						if buttons.analogry<-60 then
						else
							screen.print(25,y,scan.list[i].label or scan.list[i].title, 1, ccolor, color.shine)
						end
					end
				screen.clip()

				if scan.list[i].inst then
					screen.print(7,y,"»",1,color.white,color.green)
				end

				y += 27
			end

			--Bar Scroll
			local ybar,h = 34,(maximg*27.9)-2
			draw.fillrect(805, ybar-5, 8, h + 3, color.shine)
			if scr.maxim >= maximg then -- Draw Scroll Bar
				local pos_height = math.max(h/scr.maxim, maximg)
				draw.fillrect(805, ybar-5 + ((h-pos_height)/(scr.maxim-1))*(scr.sel-1), 8, pos_height + 2, color.new(0,255,0))
			end

			--Blit icon0
			if icon0 then
				screen.clip(xb+64, yb+64, 120/2)
				draw.fillrect(xb,yb, 128, 128, colors[scan.list[scr.sel].selcc])
					icon0:blit(xb+64, yb+64)
				screen.clip()
			else
				draw.fillrect(xb,yb, 128, 128, color.white:a(100))
				draw.rect(xb,yb, 128, 128, color.white)
			end

			-- Print Gameid
			screen.print(960-75,40,scan.list[scr.sel].gameid or STRINGS_UNK,1,color.white,color.blue,__ACENTER)


			--Print Streched
			screen.print(955,yb+64+65,"< L >",1,color.white,color.blue,__ARIGHT)
			if scan.list[scr.sel].nostretched then
				screen.print(955,yb+64+85,SCAN_FULLBUBBLE,1,color.white,color.blue,__ARIGHT)
			else
				screen.print(955,yb+64+85,SCAN_BB_NOTSTRETCHED,1,color.white,color.blue,__ARIGHT)
			end

			--Print SetPack
			screen.print(955,yb+64+120,"< R >",1,color.white,color.blue,__ARIGHT)
			screen.print(955,yb+64+140,scan.list[scr.sel].setpack,1,color.white,color.blue,__ARIGHT)

			--Print Colors
			screen.print(955,yb+64+175," ←/→ ",1,color.white,color.blue,__ARIGHT)
			screen.print(955,yb+64+200,SCAN_TEXT_COLOR.." ("..scan.list[scr.sel].selcc..")", 1,color.white,color.blue,__ARIGHT)

			--Print Style (template)
			screen.print(955,yb+64+242,"RS↑ + Pad↑",1,color.white,color.blue,__ARIGHT)
			screen.print(955,yb+64+270,scan.list[scr.sel].template, 1,color.white,color.blue,__ARIGHT)

			--Left Options
			if buttonskey then buttonskey2:blitsprite(10,425,0) end                   		--Select
			screen.print(45,427,SCAN_SORT_BY.." : "..sort_games[__SORT],1,color.white,color.blue,__ALEFT)

			if buttonskey then buttonskey:blitsprite(15,455,1) end                     		--Triangle
			screen.print(45,457,SCAN_ALL_BUBBLES,1,color.white,color.blue)

			if buttonskey then buttonskey:blitsprite(15,485,2) end                     		--[]
			screen.print(45,487,SCAN_MARK_GAME,1,color.white,color.blue)

			--Right Options
			if buttonskey then buttonskey2:blitsprite(925,425,1) end                   		--Start
			screen.print(920,427,STRINGS_EXTRA_SETTINGS,1,color.white,color.blue,__ARIGHT)

			if accept_x == 1 then
				if buttonskey then buttonskey:blitsprite(930,455,3) end						--O
			else
				if buttonskey then buttonskey:blitsprite(930,455,0) end						--X
			end
			screen.print(920,457,SCAN_BUBBLES_SETTINGS,1,color.white,color.blue,__ARIGHT)

			if scan.list[scr.sel].width > 940 then
				xscr = screen.print(xscr, 523, scan.list[scr.sel].path or scan.list[scr.sel].name,1,color.white,color.blue,__SLEFT,940)
			else
				screen.print(15, 523, scan.list[scr.sel].path or scan.list[scr.sel].name,1,color.white,color.blue)
			end

		else
			screen.print(480,252,SCAN_NOTFIND_PSPGAMES, 1, color.white, color.red, __ACENTER)
			screen.print(480,292,SCAN_INSTALL_CISO_GAMES, 1, color.white, color.blue, __ACENTER)
			screen.print(480,312,SCAN_INSTALL_PBP_GAMES, 1, color.white, color.blue, __ACENTER)
		end
		draw.fillrect(0,516,960,30, 0x64545353)--Down

		submenu_abm.run(scr)

		screen.flip()

		--Controls
		if scr.maxim > 0 and submenu_abm.h == -submenu_abm.y then

			if (buttons.up or buttons.analogly<-60) and not buttons.held.square and not (buttons.analogry<-60) then
				if scr:up() then
					xscrtitle = 25
					icon0=nil
					load_pic1(scan.list[scr.sel])
				end
			end

			if (buttons.down or buttons.analogly>60) and not buttons.held.square and not (buttons.analogry<-60) then
				if scr:down() then
					xscrtitle = 25
					icon0=nil
					load_pic1(scan.list[scr.sel])
				end
			end

			if (buttons.analoglx > 60 or buttons.analoglx < -60) and not buttons.held.square and not (buttons.analogry<-60) then
				xscrtitle = 25
			end

			--Install
			if buttons.accept then

				if toinstall <= 1 then
					local bubble_title = nil
					if __TITLE == 1 then
						bubble_title = scan.list[scr.sel].title
					elseif __TITLE == 2 then
						bubble_title = scan.list[scr.sel].name
					else
						bubble_title = osk.init(STRINGS_TITLE_OSK, scan.list[scr.sel].title or STRINGS_NAME_OSK, 128, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
					end

					if not bubble_title or (string.len(bubble_title)<=0) then bubble_title = scan.list[scr.sel].title or scan.list[scr.sel].name end
					scan.list[scr.sel].title_bubble = bubble_title
					bubbles.install(scan.list[scr.sel])
				else

					--batch titles
					for i=1, scr.maxim do
						if scan.list[i].inst then
							local bubble_title = nil
							if __TITLE == 1 then
								bubble_title = scan.list[i].title
							elseif __TITLE == 2 then
								bubble_title = scan.list[i].name
							else
								bubble_title = osk.init(STRINGS_TITLE_OSK, scan.list[i].title or STRINGS_NAME_OSK, 128, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
							end

							if not bubble_title or (string.len(bubble_title)<=0) then bubble_title = scan.list[i].title or scan.list[i].name end
							scan.list[i].title_bubble = bubble_title
						end
					end

					--batch install
					local tmp,c = toinstall,0
					for i=1, scr.maxim do
						if scan.list[i].inst then

							if back2 then back2:blit(0,0) end
							screen.print(480,490,STRINGS_BUBBLES_BAR.." ( "..(c+1).." / "..tmp.." )",1,color.white,color.blue, __ACENTER)
							draw.fillrect(10, 520, 940, 9, color.shine:a(125))
							draw.fillrect(10,520, ((c+1)*940)/tmp,9,color.new(0,255,0))
							draw.circle(10,524,8,color.new(0,255,0),30)
							draw.circle(948,524,8,color.new(0,255,0),30)
							screen.flip()

							bubbles.install(scan.list[i])
							c+=1
						end
					end
					os.delay(25)
				end
				load_pic1(scan.list[scr.sel])
				xscrtitle = 25
			end

			--Sort
			if buttons.select then
				xscrtitle = 25
				icon0=nil
				__SORT += 1

				if __SORT > #sort_games then __SORT = 1 end
				if __SORT < 1 then __SORT = #sort_games end
				table.sort(scan.list, scan_sort_cmp)
				scan_refresh_labels()
				scr:set(scan.list,maximg)
			end

			--Install all (only games not installed)
			if buttons.triangle then
				local check_install = 0
				for i=1, scr.maxim do
					if scan.list[i].install == "a" then	check_install += 1 end
				end

				if check_install > 0 then
					--if custom_msg(SCAN_INSTALL_ALL.." ? ",1) == true then
					if os.dialog(SCAN_INSTALL_ALL.." ? ", STRINGS_OS_DIALOG, __DIALOG_MODE_OK_CANCEL) == true then
						--batch titles
						for i=1, scr.maxim do
							if scan.list[i].install == "a" then
								local bubble_title = nil
								if scan.list[i].title then
									if __TITLE == 0 then
										bubble_title = osk.init(STRINGS_TITLE_OSK, scan.list[i].title or STRINGS_NAME_OSK, 128, __OSK_TYPE_DEFAULT, __OSK_MODE_TEXT)
									end
								end
								if not bubble_title or (string.len(bubble_title)<=0) then bubble_title = scan.list[i].title or scan.list[i].name end
								scan.list[i].title_bubble = bubble_title
								scan.list[i].inst = true
							end
						end

						--batch install
						local tmp,c = check_install,0
						for i=1, scr.maxim do
							if scan.list[i].inst then
								if back2 then back2:blit(0,0) end
								screen.print(480,490,STRINGS_BUBBLES_BAR.." ( "..(c+1).." / "..tmp.." )",1,color.white,color.blue, __ACENTER)
								draw.fillrect(10, 520, 940, 9, color.shine:a(125))
								draw.fillrect(10,520, ((c+1)*940)/tmp,9,color.new(0,255,0))
								draw.circle(10,524,8,color.new(0,255,0),30)
								draw.circle(948,524,8,color.new(0,255,0),30)
								screen.flip()

								bubbles.install(scan.list[i])
								c+=1
							end
						end
						os.delay(25)
					end
				end
				xscrtitle = 25
			end

			--Mark/Unmark
			if buttons.square then
				scan.list[scr.sel].inst = not scan.list[scr.sel].inst
				if scan.list[scr.sel].inst then toinstall+=1 else toinstall-=1 end
			end

			if buttons.select and buttons.held.square then error("USB") end--Debug USB

			--Full/Stretched
			if buttons.released.l then
				scan.list[scr.sel].nostretched = not scan.list[scr.sel].nostretched
				if icon0 then
					local ws,hs = 128,128
					if scan.list[scr.sel].noscaled then
						if not scan.list[scr.sel].nostretched then ws,hs = 80,80 end
					else
						if not scan.list[scr.sel].nostretched then ws,hs = 100,55 end
					end
					icon0:resize(ws,hs)
					icon0:center()
				end
			end

			if buttons.released.r then
				if scan.list[scr.sel].setpack == STRINGS_OPTION_MSG_NO then
					scan.list[scr.sel].setpack = STRINGS_PSP_PSX_BUBBLES
				elseif scan.list[scr.sel].setpack == STRINGS_PSP_PSX_BUBBLES then
					scan.list[scr.sel].setpack = STRINGS_OPTION_MSG_NO
				end
				--Update PIC
				load_pic1(scan.list[scr.sel])
			end

			--Bubbles Color
			if (buttons.right or buttons.left) and not buttons.held.square then

				if buttons.right then scan.list[scr.sel].selcc += 1 end
				if buttons.left then scan.list[scr.sel].selcc -= 1 end
			
				if scan.list[scr.sel].selcc > #colors then scan.list[scr.sel].selcc = 1 end
				if scan.list[scr.sel].selcc < 1 then scan.list[scr.sel].selcc = #colors end

			end

			if buttons.analogry<-60 and buttons.released.up then
				if scan.list[scr.sel].template == "PSPEMU" then scan.list[scr.sel].template = "PS1EMU"
				elseif scan.list[scr.sel].template == "PS1EMU" then scan.list[scr.sel].template = "PSMOBILE"
				elseif scan.list[scr.sel].template == "PSMOBILE" then scan.list[scr.sel].template = "A5"
				else scan.list[scr.sel].template = "PSPEMU"
				end
				load_style(scan.list[scr.sel])
			end

		end

		if buttons.cancel and submenu_abm.h == -submenu_abm.y then bubbles.settings() end

	end

end

--------------------------SubMenuContextual
local yf, _save = 540,false--420
submenu_abm = { 			-- Creamos un objeto menu contextual
    h = yf,					-- Height of menu
    w = 960,				-- Width of menu
    x = 0,					-- X origin of menu
    y = -yf,				-- Y origin of menu
    open = false,			-- Is open the menu?
    close = true,
    speed = 16,				-- Speed of Effect Open/Close.
    ctrl = "start",
    scroll = newScroll(),	-- Scroll of menu options.
}

function submenu_abm.wakefunct()
	submenu_abm.options = { 	-- Handle Option Text and Option Function
		{ text = STRINGS_DEFAULT_BUBBLE,	desc = STRINGS_DESC_DEFAULT_BUBBLE },		--1
		{ text = STRINGS_CONVERT_8BITS, 	desc = STRINGS_DESC_CONVERT8BITS },			--2
		{ text = STRINGS_SETIMGS, 			desc = STRINGS_DESC_SETIMGS },				--3
		{ text = STRINGS_DEFAULT_SORT,		desc = STRINGS_DESC_DEFAULT_SORT },			--4
		{ text = STRINGS_DEFAULT_COLOR,		desc = STRINGS_DESC_DEFAULT_COLOR },		--5
		{ text = STRINGS_DEFAULT_BNAME,		desc = STRINGS_DESC_TITLES },				--6
		{ text = STRINGS_TEMPLATE,			desc = STRINGS_DESC_TEMPLATE_OPTION },		--7

		{ text = STRINGS_CHECK_ADRENALINE, 	desc = STRINGS_DESC_CHECK_ADRENALINE },		--8
		{ text = STRINGS_ABM_UPDATE,		desc = STRINGS_DESC_ABM_UPDATE },			--9
		{ text = STRINGS_LANG_OPTION,		desc = STRINGS_DESC_LANG_OPTION },			--10
		{ text = STRINGS_LANG_DOWNLOAD,		desc = STRINGS_DESC_LANG_DOWNLOAD },		--10

		{ text = STRINGS_RESTORE_ADR,		desc = STRINGS_DESC_RESTORE_ADR },			--11
    }
	submenu_abm.scroll = newScroll(submenu_abm.options, #submenu_abm.options)
end

submenu_abm.wakefunct()

function submenu_abm.run(obj)

	if buttons[submenu_abm.ctrl] then
		submenu_abm.close = not submenu_abm.close
		if submenu_abm.close and _save then
			__SORT = _sort

			if tmp_sort != _sort then
				icon0=nil
				table.sort(scan.list, scan_sort_cmp)
				scan_refresh_labels()
				obj:set(scan.list,maximg)
			end
			ini.write(__PATHINI,"sort","sort",_sort)--Save __SORT
			
			for i=1,scan.len do
				scan.list[i].selcc = _color
				scan.list[i].setpack = setpack
				scan.list[i].template = _template
			end

			ini.write(__PATHINI,"gameid","titleid",__TITLEID)			--Save __TITLEID
			ini.write(__PATHINI,"convert","8bits",__8PNG)				--Save __8PNG
			ini.write(__PATHINI,"resources","set",__SET)				--Save __SET
			ini.write(__PATHINI,"color","color",_color)					--Save __COLOR
			ini.write(__PATHINI,"title","title",__TITLE)				--Save __TITLE
			ini.write(__PATHINI,"template","style",__TEMPLATE)			--Save __TEMPLATE

			ini.write(__PATHINI,"check_adr","check_adr",__CHECKADR)
			ini.write(__PATHINI,"update","update",__UPDATE)		        --Save __CHECKADR
			ini.write(__PATHINI,"lang","lang",__LANG_CUSTOM)			--Save __LANG_CUSTOM

			if __LANG_CUSTOM == 1 then
				if files.exists("ux0:data/ABM/lang/"..__LANG..".txt") then dofile("ux0:data/ABM/lang/"..__LANG..".txt")	end
				if files.exists("resources/lang/"..__LANG..".txt") then dofile("resources/lang/"..__LANG..".txt") end
			else
				dofile("resources/lang/english_us.txt")
			end
			--Update PIC
			load_pic1(scan.list[obj.sel])
		end
		_save = false
	end

	submenu_abm.draw(obj)

end

function restore_adr()
	if game.exists("PSPEMUCFW") and files.exists(ADRENALINE) and files.exists(ADRENALINE.."/eboot.bin") and files.exists(ADRENALINE.."/eboot.pbp") then
		if not restoreAdrenalineModules() then
			os.dialog(ADRENALINE_UNSUPPORTED)
			return
		end
		if back2 then back2:blit(0,0) end
			screen.flip()
			os.dialog(STRINGS_RESTART_ADR)
		os.delay(500)
		power.restart()
	else
		os.dialog(ADRENALINE_NOT_INSTALLED)
	end
end

local x_scroll_submenu = 5
function submenu_abm.draw(obj)

    if not submenu_abm.close and submenu_abm.y < 0 then
        submenu_abm.y += submenu_abm.speed
    elseif submenu_abm.close and submenu_abm.y > -submenu_abm.h then
        submenu_abm.y -= submenu_abm.speed
    end

	if submenu_abm.y > -submenu_abm.h then
		draw.fillrect(0,0,960,10,color.black:a(210))
		draw.fillrect(submenu_abm.x, submenu_abm.y, submenu_abm.w, submenu_abm.h, color.black:a(210))
	end

    if submenu_abm.y >= 0 then

        submenu_abm.open = true
		tmp_sort = __SORT
 
		--Buttons
		if (buttons.up or buttons.analogly<-60) then submenu_abm.scroll:up() x_scroll_submenu = 5 end
		if (buttons.down or buttons.analogly>60) then submenu_abm.scroll:down() x_scroll_submenu = 5 end

		if (buttons.left or buttons.right) then

			if submenu_abm.scroll.sel == 1 then--Gameid
				if __TITLEID  == 1 then __TITLEID ,_gameid = 0,STRINGS_DEFAULT_PSPEMUXXX
				else __TITLEID,_gameid = 1,STRINGS_DEFAULT_GAMEID end

			elseif submenu_abm.scroll.sel == 2 then--Set 8bits

				if __8PNG == 1 then __8PNG,_png = 0,STRINGS_OPTION_MSG_NO
				else __8PNG,_png = 1,STRINGS_OPTION_MSG_YES end

			elseif submenu_abm.scroll.sel == 3 then--Set PSP/PSX

				if __SET == 0 then __SET,setpack = 1,STRINGS_PSP_PSX_BUBBLES
				else __SET,setpack = 0,STRINGS_OPTION_MSG_NO
				end

			elseif submenu_abm.scroll.sel == 4 then--Sort

				if buttons.right then _sort +=1 end
				if buttons.left then _sort -=1 end

				if _sort > #sort_games then _sort = 1 end
				if _sort < 1 then _sort = #sort_games end

				sort_type = sort_games[_sort]

			elseif submenu_abm.scroll.sel == 5 then--Color

				if buttons.right then _color +=1 end
				if buttons.left then _color -=1 end

				if _color > #colors then _color = 1 end
				if _color < 1 then _color = #colors end

			elseif submenu_abm.scroll.sel == 6 then--Titles for your Bubbles
				if __TITLE == 1 then __TITLE,_title = 2,STRINGS_DEFAULT_NAME
				elseif __TITLE == 2 then __TITLE,_title = 0,STRINGS_DEFAULT_OSK
				else __TITLE,_title = 1,STRINGS_DEFAULT_TITLE end

			elseif submenu_abm.scroll.sel == 7 then--Style
				if __TEMPLATE == 1 then __TEMPLATE,_template = 2,"PS1EMU"
				elseif __TEMPLATE == 2 then __TEMPLATE,_template = 3,"PSMOBILE"
				elseif __TEMPLATE == 3 then __TEMPLATE,_template = 4,"A5"
				else __TEMPLATE,_template = 1,"PSPEMU" end

			elseif submenu_abm.scroll.sel == 8 then--CheckAdrenaline
				if __CHECKADR == 1 then __CHECKADR,_adr = 0,STRINGS_OPTION_MSG_NO
				else __CHECKADR,_adr = 1,STRINGS_OPTION_MSG_YES end

			elseif submenu_abm.scroll.sel == 9 then--ABM Update
				if __UPDATE == 1 then __UPDATE,_update = 0,STRINGS_OPTION_MSG_NO
				else __UPDATE,_update = 1,STRINGS_OPTION_MSG_YES end

			elseif submenu_abm.scroll.sel == 10 then--Load Language
				if __LANG_CUSTOM == 1 then __LANG_CUSTOM,_lang = 0,STRINGS_LANG_DEFAULT
				else __LANG_CUSTOM,_lang = 1,STRINGS_LANG_CUSTOM end

			end

			_save = true

		end

		if buttons.accept and submenu_abm.scroll.sel == 11 then
			download_langs()
		end
		if buttons.accept and submenu_abm.scroll.sel == 12 then
			restore_adr()
		end

		screen.print(480, 7, STRINGS_EXTRA_SETTINGS, 1, color.white, color.blue, __ACENTER)
		screen.print(480, 47, STRINGS_WARNING, 1, color.white, color.red, __ACENTER)

		local h = 90
        for i=submenu_abm.scroll.ini,submenu_abm.scroll.lim do

			if i==submenu_abm.scroll.sel then
				draw.fillrect(5,h-5, 960-5,28,color.shine)
				sel_color = color.green
			else sel_color = color.white
			end

			screen.print(180, h, submenu_abm.options[i].text, 1, sel_color, color.blue, __ALEFT)

			if i==1 then
				screen.print(780, h, _gameid, 1, sel_color, color.blue, __ARIGHT)
			elseif i==2 then
				screen.print(780, h, _png, 1, sel_color, color.blue, __ARIGHT)
			elseif i==3 then
				screen.print(780, h, setpack, 1, sel_color, color.blue, __ARIGHT)
			elseif i==4 then
				screen.print(780, h, sort_type, 1, sel_color, color.blue, __ARIGHT)
			elseif i==5 then
				draw.fillrect(760, h,18,18, colors[_color])
				draw.rect(760,h,18,18, color.white)
				screen.print(745, h, "(".._color..")", 1, sel_color, color.blue, __ARIGHT)
			elseif i==6 then
				screen.print(780, h, _title, 1, sel_color, color.blue, __ARIGHT)
			elseif i==7 then
				screen.print(780, h, _template, 1, sel_color, color.blue, __ARIGHT)
			elseif i==8 then
				screen.print(780, h, _adr, 1, sel_color, color.blue, __ARIGHT)
			elseif i==9 then
				screen.print(780, h, _update, 1, sel_color, color.blue, __ARIGHT)
			elseif i==10 then
				screen.print(780, h, _lang, 1, sel_color, color.blue, __ARIGHT)
			elseif i==11 then
				screen.print(780, h, string.format(SCAN_PRESS_CONFIRM, SYMBOL_BACK2), 1, sel_color, color.blue, __ARIGHT)
			elseif i==12 then
				screen.print(780, h, string.format(SCAN_PRESS_CONFIRM, SYMBOL_BACK2), 1, sel_color, color.blue, __ARIGHT)
			end

			h += 30

        end

		if screen.textwidth(submenu_abm.options[submenu_abm.scroll.sel].desc,1) > 945 then
			x_scroll_submenu = screen.print(x_scroll_submenu, yf-27, submenu_abm.options[submenu_abm.scroll.sel].desc,1,color.green,color.shine,__SLEFT,945)
		else
			screen.print(480, yf-27, submenu_abm.options[submenu_abm.scroll.sel].desc, 1,color.green,color.shine, __ACENTER)--265
		end

		draw.gradline(0,yf,960,yf,color.blue,color.green)
		draw.gradline(0,yf+1,960,yf+1,color.green,color.blue)

    else
        submenu_abm.open = false
    end
end
