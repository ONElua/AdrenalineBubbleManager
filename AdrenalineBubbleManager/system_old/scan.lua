--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 
scan = {}
__PIC = false

function scan.insertCISO(hand)
	local _type = files.type(hand.path)
	if _type == 2 or _type == 3 then
		local tmp0 = game.info(hand.path)
		if tmp0 and tmp0.CATEGORY == "UG" then
			init_msg(string.format("Loading C/ISO %s\n",hand.path))
			table.insert(scan.list, { img = game.geticon0(hand.path), title = tmp0.TITLE or hand.name, path = hand.path, name = hand.name, type=true })
		end
		tmp0 = nil
	end
end

function scan.isos(path)
	local tmp = files.list(path)
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if tmp[i].directory then
				local ls=files.listfiles(tmp[i].path)
				if ls and #ls > 0 then
					for j=1, #ls do
						local ext = ls[j].ext:upper()
						if ext == "ISO" or ext == "CSO" then scan.insertCISO(ls[j])   end
					end
				end
			else
				if tmp[i].ext and (tmp[i].ext:upper() == "ISO" or tmp[i].ext:upper() == "CSO" ) then
					scan.insertCISO(tmp[i])                     -- Recursive only 2 levels
				end
			end

		end
	end
end

function scan.insertPBP(hand)
	if game.exists(hand.name) then return end                  -- Is oficial PSP game (Bubble), not read :P
	if files.type(hand.path) == 1 then
		local tmp0 = game.info(hand.path)
		if tmp0 and tmp0.CATEGORY == "PG" then return end
		if tmp0 and tmp0.DISC_ID == "MSTKUPDATE" then return end
		local _insert = true
		if tmp0.CATEGORY == "EG" then
			local sceid = game.sceid(string.format("%s__sce_ebootpbp",files.nofile(hand.path)))
			if sceid and sceid != "---" and sceid != hand.name then
				_insert=false--nothing
			end
		end
		if _insert then
			init_msg(string.format("Loading PBP %s\n",hand.path))
			table.insert(scan.list, {img = game.geticon0(hand.path), title = tmp0.TITLE, path = hand.path, name = hand.name, type=false })
		end
		tmp0 = nil
	end
end

function scan.pbps(path, level)
	if not level then level = 1 end
	local tmp = files.listdirs(path)
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if files.exists(tmp[i].path.."/EBOOT.PBP") then
				tmp[i].path += "/EBOOT.PBP"
				scan.insertPBP(tmp[i])
			elseif level == 1 then
				scan.pbps(tmp[i].path, 2)                     -- Recursive only 2 levels
			end
		end
	end
end

function scan.games()
	scan.list = {}
	scan.isos("ux0:pspemu/ISO")
	scan.isos("ur0:pspemu/ISO")
	scan.pbps("ux0:pspemu/PSP/GAME")
	scan.pbps("ur0:pspemu/PSP/GAME")

	if files.exists("uma0:") then
		scan.isos("uma0:pspemu/ISO")
		scan.pbps("uma0:pspemu/PSP/GAME")
	end
	scan.len = #scan.list
	if scan.len > 0 then
		table.sort(scan.list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end)
	end
end

function scan.show()

	local scr,pic1 = newScroll(scan.list,15),nil

	buttons.interval(10,10)
	local xscr = 15
	while true do
		--buttons.homepopup(0)
		buttons.read()
		if back then back:blit(0,0) end

		draw.fillrect(0,0,960,30, 0x64545353) --UP
		screen.print(480,5,"Available games [ISO/CSO/PBP]", 1, color.white, color.blue, __ACENTER)
		screen.print(950,5,"Count: " + scr.maxim, 1, color.red, color.gray, __ARIGHT)

		if scr.maxim > 0 then

			if buttons.up or buttons.down then
				if buttons.up then scr:up() else scr:down() end
				if __PIC then
					pic1 = game.getpic1(scan.list[scr.sel].path)
				end
			end

			if (buttons.held.l or buttons.analogly < -60) then scr:up()   end
			if (buttons.held.r or buttons.analogly > 60) then  scr:down() end

			if (buttons.released.l or buttons.released.r) or (buttons.analogly < -60 or buttons.analogly > 60) then
				if __PIC then
					pic1 = game.getpic1(scan.list[scr.sel].path)
				end
			end

			if pic1 then
				pic1:resize(960,488)
				pic1:center()
				pic1:blit(960/2, 544/2,200)
			end

			--Blit List
			local y = 45
			for i=scr.ini,scr.lim do
				if i==scr.sel then
					local w = 144
					if scan.list[scr.sel].img then
						scan.list[scr.sel].img:resize(80,80)
						w = scan.list[scr.sel].img:getw()
					end
					draw.fillrect(10,y-3,930-w,25,color.red)
				end
				screen.print(23,y,scan.list[i].title or scan.list[i].name, 1, color.white, color.blue)            
				y += 25
			end

			--Blit icon0
			if scan.list[scr.sel].img then
				scan.list[scr.sel].img:center()
				scan.list[scr.sel].img:blit(960 - (scan.list[scr.sel].img:getw()/2), 70)
			end

			--Rigth
			if buttonskey then buttonskey:blitsprite(930,470,1) end                        --△
			screen.print(920,470,"On/Off PICs",1,color.white,color.blue, __ARIGHT)

			if buttonskey then buttonskey:blitsprite(930,490,3) end                        --O
			screen.print(920,490,"Disable/Edit AdrBubbles",1,color.white,color.blue, __ARIGHT)

			if screen.textwidth(scan.list[scr.sel].path or scan.list[scr.sel].name) > 940 then
				xscr = screen.print(xscr, 523, scan.list[scr.sel].path or scan.list[scr.sel].name,1,color.white,color.blue,__SLEFT,940)
			else
				screen.print(15, 523, scan.list[scr.sel].path or scan.list[scr.sel].name,1,color.white,color.blue)
			end

		else
			screen.print(480,272,"Not have any PSP Game :( Try again later!", 1, color.white, color.red, __ACENTER)
		end
		draw.fillrect(0,516,960,30, 0x64545353)--Down

		if buttonskey2 then buttonskey2:blitsprite(10,490,1) end                        --Start
		screen.print(40,495,"Go to the Livearea",1,color.white,color.blue)

		screen.flip()

		--Controls
		if buttons.cross and scr.maxim > 0 then
			if scan.list[scr.sel].type then bubbles.selection(scan.list[scr.sel],true)
			else bubbles.selection(scan.list[scr.sel],false) end
			buttons.read()
		end

		if buttons.triangle and scr.maxim > 0 then
			__PIC = not __PIC
			if not __PIC then pic1 = nil
			else pic1 = game.getpic1(scan.list[scr.sel].path) end
		end

		if buttons.circle then
			kick=true
				scan.deledit_gameids()
			kick=false
		end

	end
end

function scan.deledit_gameids()

	local gamesid = {}
	gamesid.list = files.listfiles(ADRBUBBLESDB)

	gamesid.len = #gamesid.list
	if gamesid.len > 0 then

		table.sort(gamesid.list ,function (a,b) return string.lower(a.name)<string.lower(b.name) end)

		for i=gamesid.len,1,-1 do
			local ext = gamesid.list[i].ext:lower()

			if ext != "txt" or string.len(gamesid.list[i].name)!=13 then
				table.remove(gamesid.list,i)
			else
				local pid = gamesid.list[i].name:gsub('.txt','')
				gamesid.list[i].picon = game.geticon0(string.format("%s/pboot.pbp", "ux0:pspemu/PSP/GAME/"..pid))

				gamesid.list[i].dds_png = false
				local icondds = string.format("ur0:appmeta/%s/icon0.dds", pid)
				local iconpng = string.format("ur0:appmeta/%s/icon0.png", pid)

				if files.exists(icondds) then
					if files.type(icondds) == 8 then
						if files.exists(iconpng) then files.delete(iconpng) end
						files.rename(icondds, "ICON0.png")
						if not gamesid.list[i].picon then
							gamesid.list[i].dicon = image.load(iconpng)
						end
						gamesid.list[i].dds_png = true
						files.rename(iconpng, "ICON0.dds")
					end
				else
					if files.exists(iconpng) then
						if not gamesid.list[i].picon then
							gamesid.list[i].dicon = image.load(iconpng)
						end
						files.rename(iconpng, "ICON0.dds")
					end
				end

				gamesid.list[i].update = false

			end
		end

		--update game.list
		gamesid.len = #gamesid.list
	end

	for i=1, gamesid.len do
		gamesid.list[i].lines = {}
		for line in io.lines(gamesid.list[i].path) do
			table.insert(gamesid.list[i].lines, line)
		end

		for j=1,5 do
			if not gamesid.list[i].lines[j] then
				gamesid.list[i].lines[j] = "DEFAULT"
			end
		end

	end

	local drivers = { "INFERNO", "MARCH33" }
	local bins = { "EBOOT.BIN", "BOOT.BIN", "EBOOT.OLD" }
	local plugin_startdat = { "ENABLE", "DISABLE" }
	local selector, optsel, change = 1,2,false
	local scrids, xscr1, xscr2 = newScroll(gamesid.list, 7), 130, 15

	buttons.interval(10,10)
	while true do
		buttons.read()
		if back then back:blit(0,0) end
		draw.fillrect(0,0,960,30, 0x64545353) --UP
		screen.print(480,5, "Edit & Uninstall GAMEID.txt", 1, color.white, color.blue, __ACENTER)

		draw.fillrect(120,64,720,416,color.new(105,105,105,230))
		draw.gradline(120,310,840,310,color.blue,color.green)
		draw.gradline(120,312,840,312,color.green,color.blue)
		draw.rect(120,64,720,416,color.blue)

		screen.print(480,70,"GAMEID.TXT ", 1, color.white, color.gray, __ACENTER)
		screen.print(830,70,"Count: " + gamesid.len, 1, color.red, color.gray, __ARIGHT)

		if scrids.maxim > 0 then

			if not change then
				if (buttons.up or buttons.held.l or buttons.analogly < -60) then scrids:up() end
				if (buttons.down or buttons.held.r or buttons.analogly > 60) then scrids:down() end
			else
				if (buttons.up or buttons.held.l) then optsel-=1 end
				if (buttons.down or buttons.held.r) then optsel+=1 end
				if optsel > 5 then optsel = 2 end
				if optsel < 2 then optsel = 5 end

				if (buttons.left or buttons.right) then
					if buttons.left then selector-=1 end
					if buttons.right then selector+=1 end

					if optsel == 3 then
						if selector > 3 then selector = 1 end
						if selector < 1 then selector = 3 end
					else
						if selector > 2 then selector = 1 end
						if selector < 1 then selector = 2 end
					end

					if optsel == 2 then
						gamesid.list[scrids.sel].lines[optsel] = drivers[selector]
					elseif optsel == 3 then
						gamesid.list[scrids.sel].lines[optsel] = bins[selector]
					else
						gamesid.list[scrids.sel].lines[optsel] = plugin_startdat[selector]
					end
					gamesid.list[scrids.sel].update = true
				end

			end

			if gamesid.list[scrids.sel].picon then
				gamesid.list[scrids.sel].picon:center()
				gamesid.list[scrids.sel].picon:blit(200, 170)
			else
				if gamesid.list[scrids.sel].dicon then
					gamesid.list[scrids.sel].dicon:center()
					gamesid.list[scrids.sel].dicon:blit(200, 170)
				end
			end

			local y = 120
			for i=scrids.ini, scrids.lim do
				if i == scrids.sel then draw.fillrect(320,y-1,330,18,color.green:a(100)) end
				screen.print(480,y,gamesid.list[i].name or "unk",1.0,color.white,color.gray,__ACENTER)
				y += 23
			end

			--Options txts
			if screen.textwidth(gamesid.list[scrids.sel].lines[1] or "unk") > 700 then
				xscr1 = screen.print(xscr1, 320, gamesid.list[scrids.sel].lines[i] or "unk",1,color.white,color.gray,__SLEFT,700)
			else
				screen.print(480, 320, gamesid.list[scrids.sel].lines[1] or "unk",1,color.white,color.gray, __ACENTER)
			end

			local y1=343
			for i=2,5 do
				if change then
					if i == optsel then draw.fillrect(300,y1-1,350,18,color.green:a(100)) end
				end
				screen.print(480, y1, gamesid.list[scrids.sel].lines[i],1,color.white,color.gray, __ACENTER)

				y1+=23
			end

			if gamesid.list[scrids.sel].dds_png then
				screen.print(480,438,"dds",1.0,color.green,color.gray,__ACENTER)
			end

			if not change then
				screen.print(480,460,SYMBOL_CROSS..": Uninstall AdrBubble      |      "..SYMBOL_TRIANGLE..": Edit gameid.txt      |      "..SYMBOL_CIRCLE..": Back", 1, color.white, color.blue, __ACENTER)
			else
				screen.print(480,460,"<- -> Toggle options      |      "..SYMBOL_TRIANGLE..": Done editing      ", 1, color.white, color.blue, __ACENTER)
			end

			if screen.textwidth(gamesid.list[scrids.sel].path) > 940 then
				xscr2 = screen.print(xscr2, 523, gamesid.list[scrids.sel].path,1,color.white,color.blue,__SLEFT,940)
			else
				screen.print(15, 523, gamesid.list[scrids.sel].path,1,color.white,color.blue)
			end

		else
			screen.print(480,200,"Not have any Files List :( Try again later!", 1, color.white, color.red, __ACENTER)
			screen.print(480,460,SYMBOL_CIRCLE..": To go Back", 1, color.white, color.blue, __ACENTER)
		end
		draw.fillrect(0,516,960,30, 0x64545353)--Down

		screen.flip()

		if (buttons.cross and not change) and scrids.maxim > 0 then

			local id = gamesid.list[scrids.sel].name:gsub('.txt','')
			scan.plugman(id)

			--Delete gameid.txt
			files.delete(gamesid.list[scrids.sel].path)
			table.remove(gamesid.list, scrids.sel)
			scrids:set(gamesid.list,7)
			gamesid.len = #gamesid.list

			--Reload config.txt
			ForceReload()

			--Delete GAMEID.PNG
			if files.exists(ADRBUBBLESDB..id..".PNG") then
				files.delete(ADRBUBBLESDB..id..".PNG")
				os.message("Removed "..id..".PNG")
			end

			--Delete PBOOT
			if files.exists("ux0:pspemu/PSP/GAME/"..id.."/PBOOT.PBP") then
				files.delete("ux0:pspemu/PSP/GAME/"..id.."/PBOOT.PBP")
				os.message("Removed "..id.."/PBOOT.PBP")
				ForcePowerReset()
			end

			--Delete icon0.dds
			local appmeta = string.format("ur0:appmeta/%s",id)
			for i=1,bubbles.len do
				if id == bubbles.list[i].id then
					bubbles.list[i].picon = nil
					bubbles.list[i].ptitle = ""
					if bubbles.list[i].dds_png then
						--Set app.db tittle
						local info_sfo = game.info("ux0:pspemu/PSP/GAME/"..id.."/EBOOT.PBP")
						if info_sfo and info_sfo.TITLE then
							os.titledb(info_sfo.TITLE,id)
							ForcePowerReset()
						end
						files.delete(appmeta.."/ICON0.dds")
						os.message("Removed "..appmeta.."/ICON0.dds")
						files.rename(appmeta.."/icon0_orig.dds","ICON0.dds")

						files.delete(appmeta.."/livearea/contents/STARTUP.PNG")
						files.rename(appmeta.."/livearea/contents/startup_orig.png","STARTUP.PNG")

						if files.exists(appmeta.."/livearea/contents/bg0_orig.png") then
							files.delete(appmeta.."/livearea/contents/BG0.PNG")
							files.rename(appmeta.."/livearea/contents/bg0_orig.png","BG0.PNG")
						end
					end
					bubbles.list[i].dds_png = false
				end
			end--for

			if os.message("Would you like to Disable another GAMEID.txt ? ",1) == 0 then
				for i=1,gamesid.len do
					if gamesid.list[i].update then
						files.write(gamesid.list[i].path, table.concat(gamesid.list[i].lines, '\n'))
					end
				end
				os.delay(15)
				if PowerReset then RestartV() end
			end
		end

		if buttons.triangle then
			change = not change
			if not change then optsel = 2 end
		end

		if buttons.circle and not change then
			for i=1,gamesid.len do
				if gamesid.list[i].update then
					files.write(gamesid.list[i].path, table.concat(gamesid.list[i].lines, '\n'))
				end
			end
			os.delay(15)
			return false
		end

	end
end

function scan.plugman(id)

	local plugman = {
		cfg = {},                	-- Have original state of file.
		list = {},                  -- Handle list of plugins.
	}

	local path = "ur0:tai/config.txt"
	if not files.exists(path) then path = "ux0:tai/config.txt" end

	plugman.cfg, plugman.list= {},{} -- Set to Zero

	if files.exists(path) then
		local id_sect = nil
		local i = 1

		for line in io.lines(path) do

			table.insert(plugman.cfg,line)

			if line:find("*",1) then -- Section Found
				if line:sub(2) == id then
					id_sect = id
					if not plugman.list[id_sect] then plugman.list[id_sect] = {} end
					table.insert(plugman.list[id_sect], {line = i, suprxline = line, dels=true })
				else
					id_sect = nil
				end
			else

				if id_sect then
					local tmp = line:gsub('#',''):lower()
					if tmp == NOSTARTDAT or tmp == ADRBBLBOOTER or tmp == ADRENALINE then
						table.insert(plugman.list[id_sect], {line = i, suprxline = line, dels=true })
					elseif line:sub(1,4) == "ux0:" or line:sub(1,4) == "ur0:" then
						table.insert(plugman.list[id_sect], {line = i, suprxline = line, dels=false })
					end
				end
			end

			i += 1
		end--for
	end

	local _write = true
	if plugman.list[id] then
		for i=#plugman.list[id],1,-1 do
			table.remove(plugman.cfg, plugman.list[id][i].line)
			if not plugman.list[id][i].dels then
				if _write then
					table.insert(plugman.cfg, "*"..id)
					_write = false
				end
				table.insert(plugman.cfg, plugman.list[id][i].suprxline)
			end
		end--for
	end
	files.write(path, table.concat(plugman.cfg, '\n'))
end
