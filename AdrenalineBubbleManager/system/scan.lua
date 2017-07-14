--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltaR4 & Wzjk.
	
]]

ADRBUBBLESDB = "ux0:adrbblbooter/bubblesdb/"

--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 
scan = {}
__PIC = false

function scan.insertCISO(hand)
    local _type = files.type(hand.path)
	if _type == 2 or _type == 3 then
		local tmp0 = game.info(hand.path)
		if tmp0 and tmp0.CATEGORY == "UG" then
			if debug_mode then init_msg(string.format("Loading C/ISO %s\n",hand.path)) end
			table.insert(scan.list, {img = game.geticon0(hand.path), title = tmp0.TITLE or hand.name, path = hand.path, name = hand.name})
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
						if ext == "ISO" or ext == "CSO" then
							scan.insertCISO(ls[j])
						end

					end
				end
			else
				if tmp[i].ext and (tmp[i].ext:upper() == "ISO" or tmp[i].ext:upper() == "CSO" ) then
					scan.insertCISO(tmp[i])							-- Recursive only 2 levels
				end
			end

		end
	end
end

function scan.insertPBP(hand)
	if game.exists(hand.name) then return end						-- Is oficial PSP game (Bubble), not read :P
	if files.type(hand.path) == 1 then
		local tmp0 = game.info(hand.path)
		if tmp0 and tmp0.CATEGORY != "PG" then
			if debug_mode then init_msg(string.format("Loading PBP %s\n",hand.path)) end
			table.insert(scan.list, {img = game.geticon0(hand.path), title = tmp0.TITLE, path = hand.path, name = hand.name})
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
				scan.pbps(tmp[i].path, 2)							-- Recursive only 2 levels
			end
		end
	end
end

function scan.scan()
	scan.list = {}
	scan.isos("ux0:pspemu/ISO")
	scan.isos("ur0:pspemu/ISO")
	scan.pbps("ux0:pspemu/PSP/GAME")
	scan.pbps("ur0:pspemu/PSP/GAME")
	scan.len = #scan.list
	if scan.len > 0 then
		table.sort(scan.list ,function (a,b) return string.lower(a.path)<string.lower(b.path) end)
	end
end

function scan.show()

	local scr,pic1 = newScroll(scan.list,15),nil

	buttons.interval(10,10)
	local xscr = 15
	while true do
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

			if (buttons.held.l or buttons.analogly < -60) then
				scr:up()
			end
			if (buttons.held.r or buttons.analogly > 60) then
				scr:down()
			end

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
			local y = 70
			for i=scr.ini,scr.lim do
				if i==scr.sel then
					local w = 144
					if scan.list[scr.sel].img then w = scan.list[scr.sel].img:getrealw() end
					draw.fillrect(10,y-3,930-w,25,color.red)
				end
				screen.print(25,y,scan.list[i].title or scan.list[i].name, 1, color.white, color.blue)
				y += 25
			end

			--Blit icon0
			if scan.list[scr.sel].img then
				scan.list[scr.sel].img:center()
				scan.list[scr.sel].img:blit(960 - (scan.list[scr.sel].img:getrealw()/2), 70)
			end

			if buttonskey then buttonskey:blitsprite(930,470,1) end								--Triangle
			screen.print(920,470,"On/Off PICs",1,color.white,color.blue, __ARIGHT)

			if buttonskey then buttonskey:blitsprite(930,490,2) end								--[]
			screen.print(920,490,"Disable Adrbblbooter Bubbles",1,color.white,color.blue, __ARIGHT)
		
			if screen.textwidth(scan.list[scr.sel].path or scan.list[scr.sel].name) > 940 then
				xscr = screen.print(xscr, 523, scan.list[scr.sel].path or scan.list[scr.sel].name,1,color.white,color.blue,__SLEFT,940)
			else
				screen.print(15, 523, scan.list[scr.sel].path or scan.list[scr.sel].name,1,color.white,color.blue)
			end
			

		else
			screen.print(480,272,"Not have any PSP Game :( Try again late!", 1, color.white, color.red, __ACENTER)
		end
		draw.fillrect(0,516,960,30, 0x64545353)--Down

		if buttonskey2 then buttonskey2:blitsprite(10,490,1) end								--Start
		screen.print(50,495,"Go to the Livearea",1,color.white,color.blue)

		screen.flip()

		--Controls
		if buttons.cross and scr.maxim > 0 then bubbles.selection(scan.list[scr.sel]) end
		if buttons.triangle and scr.maxim > 0 then
			__PIC = not __PIC
			if not __PIC then pic1 = nil
			else pic1 = game.getpic1(scan.list[scr.sel].path) end
		end

		if buttons.square then scan.deletes() end
	end
end

function scan.deletes()
	local vbuff = screen.toimage()

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
			end
		end

		--update game.list
		gamesid.len = #gamesid.list
	end

	for i=1, gamesid.len do
		for line in io.lines(gamesid.list[i].path) do
			gamesid.list[i].line = line
			break
		end--for
	end

	local scrids, xscr1 = newScroll(gamesid.list, 7), 130
	buttons.interval(10,10)
	while true do

		buttons.read()
		if vbuff then vbuff:blit(0,0) end

		draw.fillrect(120,64,720,416,color.new(105,105,105,230))
		draw.rect(120,64,720,416,color.blue)

		screen.print(480,66,"GAMEIDs.TXT ", 1, color.white, color.gray, __ACENTER)
		screen.print(830,64,"Count: " + gamesid.len, 1, color.red, color.gray, __ARIGHT)

		if scrids.maxim > 0 then

			if (buttons.up or buttons.held.l or buttons.analogly < -60) then scrids:up() end
			if (buttons.down or buttons.held.r or buttons.analogly > 60) then scrids:down() end

			screen.print(480, 90, ADRBUBBLESDB,1,color.white,color.gray, __ACENTER)

			if gamesid.list[scrids.sel].picon then
				gamesid.list[scrids.sel].picon:center()
				gamesid.list[scrids.sel].picon:blit(480, 360)
			end

			local x,y = 120,130
			for i=scrids.ini, scrids.lim do
				if i == scrids.sel then draw.fillrect(x + 10,y-1,700,18,color.green:a(100)) end
				screen.print(480,y,gamesid.list[i].name or "unk",1.0,color.white,color.gray,__ACENTER)
				y += 23
			end

			if screen.textwidth(gamesid.list[scrids.sel].line or "Empty") > 700 then
				xscr1 = screen.print(xscr1, 425, gamesid.list[scrids.sel].line or "Empty",1,color.white,color.gray,__SLEFT,700)
			else
				screen.print(480, 425, gamesid.list[scrids.sel].line or "Empty",1,color.white,color.gray, __ACENTER)
			end

			screen.print(480,460,SYMBOL_CROSS..": Uninstall AdrBubble      |      "..SYMBOL_CIRCLE..": Cancel", 1, color.white, color.blue, __ACENTER)

		else
			screen.print(480,200,"Not have any Files List :( Try again late!", 1, color.white, color.red, __ACENTER)
		end

		screen.flip()

		if buttons.cross and scrids.maxim > 0 then
			--Update config.txt
			local id = gamesid.list[scrids.sel].name:gsub('.txt','')

			scan.plugman(id)

			--Delete gameid.txt
			files.delete(gamesid.list[scrids.sel].path)
			table.remove(gamesid.list, scrids.sel)
			scrids:set(gamesid.list,7)

			--Delete GAMEID.PNG
			if files.exists(ADRBUBBLESDB..id..".PNG") then
				files.delete(ADRBUBBLESDB..id..".PNG")
			end

			--Delete PBOOT ??
			local update = false
			if files.exists("ux0:pspemu/PSP/GAME/"..id.."/PBOOT.PBP") then
				--if os.message("You want to eliminate the PBOOT.PBP \n                      "..id,1) == 1 then
					files.delete("ux0:pspemu/PSP/GAME/"..id.."/PBOOT.PBP")
					for i=1,bubbles.len do
						if id == bubbles.list[i].id then
							bubbles.list[i].picon = nil
							bubbles.list[i].ptitle = ""
						end
					end
					update = true
					ForceReset()
				--end
			end

			if os.message("Would you like to disable another GAMEID.txt ? ",1) == 0 then
				if update then UpdateDB() end
			end
			os.taicfgreload()
			os.message("Reload taiHEN Done!!")
		end

		if buttons.circle then
			return false
		end

	end
end

function scan.plugman(id)

	local plugman = {
			cfg = {},					-- Have original state of file.
			list = {},					-- Handle list of plugins.
	}

    local path = "ux0:tai/config.txt"
	if not files.exists(path) then path = "ur0:tai/config.txt" end

	plugman.cfg = {} -- Set to Zero
	plugman.list = {} -- Set to Zero

	if files.exists(path) then
		local id_sect = nil
		local i = 1

		for line in io.lines(path) do

			table.insert(plugman.cfg,line)

			if line:find("*",1) then -- Section Found
				if line:sub(2) == id then
					id_sect = id
					if not plugman.list[id_sect] then plugman.list[id_sect] = {line = i, suprxline = line, dels=true } end
					table.insert(plugman.list[id_sect], {line = i, suprxline = line, dels=true })
				else
					id_sect = nil
				end
			else

				if id_sect then
					local tmp = line:gsub('#',''):lower()
					if tmp == NOSTARTDAT or tmp == YESSTARTDAT or tmp == ADRENALINE then
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
