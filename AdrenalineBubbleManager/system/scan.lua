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
			screen.print(920,490,"Edit Boot.inf",1,color.white,color.blue, __ARIGHT)

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
			kick=true
				if scan.list[scr.sel].type then bubbles.install(scan.list[scr.sel],true)
				else bubbles.install(scan.list[scr.sel],false) end
			kick=false
			buttons.read()
		end

		if buttons.triangle and scr.maxim > 0 then
			__PIC = not __PIC
			if not __PIC then pic1 = nil
			else pic1 = game.getpic1(scan.list[scr.sel].path) end
		end

		if buttons.circle then
			kick=true
				scan.bootinf()
			kick=false
		end

	end
end

function scan.bootinf()

	local list = game.list(__ALL)
	table.sort(list ,function (a,b) return string.lower(a.id)<string.lower(b.id); end)
	local len = #list

	bubbles.list = {}
	for i=1, len do
		if files.exists(list[i].path.."/data/boot.inf") then
			if list[i].path:sub(1,14) == "ux0:app/PSPEMU" and list[i].id != "PSPEMUCFW" then
				local info = game.info(string.format("%s/sce_sys/param.sfo", list[i].path))
				if info then
					local entry = {
						id = list[i].id,                                             					-- TITLEID of the game.
						path = string.format("%s/data/boot.inf", list[i].path),							-- Path to the boot.inf
						pathini = string.format("%s/data/boot.ini", list[i].path),						-- Path to the boot.inf
						icon = image.load(string.format("%s/icon0.png", "ur0:appmeta/"..list[i].id)),	--Icon of the Game.
						pic = image.load(string.format("%s/pic0.png", "ur0:appmeta/"..list[i].id)),		--Icon of the Game.
						title = nil,											--nil
					}
					entry.title = info.TITLE or entry.id,												--Title of the Game.
					table.insert(bubbles.list, entry)                                   				-- Insert entry in list of bubbles! :)
				end
			end
		end
	end--for

	local boot = { "PATH", "DRIVER", "EXECUTE", "PLUGINS" }
	local drivers = { "INFERNO", "MARCH33", "NP9660" }
	local bins =	{ "EBOOT.BIN", "BOOT.BIN", "EBOOT.OLD" }
	local plugins = { "ENABLE", "DISABLE" }
	local selector, optsel, change = 1,2,false
	local scrids, xscr1, xscr2 = newScroll(bubbles.list, 7), 130, 15

	bubbles.len = #bubbles.list
	if bubbles.len > 0 then
		table.sort(bubbles.list ,function (a,b) return string.lower(a.id)<string.lower(b.id) end)

		for i=1, bubbles.len do
			bubbles.list[i].lines = {}
			files.rename(bubbles.list[i].path, "boot.ini")
			for j=1, #boot do
				table.insert(bubbles.list[i].lines, ini.read(bubbles.list[i].pathini, boot[j], "DEFAULT"))
			end
		end
	end

	buttons.interval(10,10)
	while true do
		buttons.read()

		if back then back:blit(0,0) end

		draw.fillrect(0,0,960,30, 0x64545353) --UP
		screen.print(480,5, "EDIT BOOT.INF", 1, color.white, color.blue, __ACENTER)

		if scrids.maxim > 0 then
			if bubbles.list[scrids.sel].pic then
				bubbles.list[scrids.sel].pic:resize(600,352)
				bubbles.list[scrids.sel].pic:center()
				bubbles.list[scrids.sel].pic:blit(480,272)
			end
		end

		draw.fillrect(120,64,720,416,color.new(105,105,105,230))
		draw.gradline(120,310,840,310,color.blue,color.green)
		draw.gradline(120,312,840,312,color.green,color.blue)
		draw.rect(120,64,720,416,color.blue)

		screen.print(830,70,"Count: " + bubbles.len, 1, color.red, color.gray, __ARIGHT)

		if scrids.maxim > 0 then

			if not change then
				if (buttons.up or buttons.held.l or buttons.analogly < -60) then scrids:up() end
				if (buttons.down or buttons.held.r or buttons.analogly > 60) then scrids:down() end
			else
				if (buttons.up or buttons.held.l) then optsel-=1 end
				if (buttons.down or buttons.held.r) then optsel+=1 end

				if optsel > #boot then optsel = 2 end
				if optsel < 2 then optsel = #boot end

				if (buttons.left or buttons.right) then
					if buttons.left then selector-=1 end
					if buttons.right then selector+=1 end

					if optsel == 4 then
						if selector > 2 then selector = 1 end
						if selector < 1 then selector = 2 end
					else
						if selector > 3 then selector = 1 end
						if selector < 1 then selector = 3 end
					end

					if optsel == 2 then
						bubbles.list[scrids.sel].lines[optsel] = drivers[selector]
					elseif optsel == 3 then
						bubbles.list[scrids.sel].lines[optsel] = bins[selector]
					elseif optsel == 4 then
						bubbles.list[scrids.sel].lines[optsel] = plugins[selector]
					end
					bubbles.list[scrids.sel].update = true
				end

			end-- not change

			if bubbles.list[scrids.sel].icon then
				bubbles.list[scrids.sel].icon:center()
				bubbles.list[scrids.sel].icon:blit(200, 170)
			end

			local y = 120
			for i=scrids.ini, scrids.lim do
				if i == scrids.sel then draw.fillrect(320,y-1,330,18,color.green:a(100)) end
				screen.print(480,y,bubbles.list[i].id or "unk",1.0,color.white,color.gray,__ACENTER)
				y += 23
			end

			--Options txts
			if screen.textwidth(bubbles.list[scrids.sel].lines[1] or "unk") > 700 then
				xscr1 = screen.print(xscr1, 320, bubbles.list[scrids.sel].lines[i] or "unk",1,color.white,color.gray,__SLEFT,700)
			else
				screen.print(480, 320, bubbles.list[scrids.sel].lines[1] or "unk",1,color.white,color.gray, __ACENTER)
			end

			local y1=343
			for i=2,#boot do
				if change then
					if i == optsel then draw.fillrect(300,y1-1,350,18,color.green:a(100)) end
				end
				screen.print(480, y1, bubbles.list[scrids.sel].lines[i],1,color.white,color.gray, __ACENTER)

				y1+=23
			end

			if not change then
				screen.print(480,460,SYMBOL_TRIANGLE..": Edit boot.inf      |      "..SYMBOL_CIRCLE..": Back", 1, color.white, color.blue, __ACENTER)
			else
				screen.print(480,460,"<- -> Toggle options      |      "..SYMBOL_TRIANGLE..": Done editing      ", 1, color.white, color.blue, __ACENTER)
			end

			if screen.textwidth(bubbles.list[scrids.sel].path) > 940 then
				xscr2 = screen.print(xscr2, 523, bubbles.list[scrids.sel].path,1,color.white,color.blue,__SLEFT,940)
			else
				screen.print(15, 523, bubbles.list[scrids.sel].path,1,color.white,color.blue)
			end

		else
			screen.print(480,200,"Not have any Files List :( Try again later!", 1, color.white, color.red, __ACENTER)
			screen.print(480,460,SYMBOL_CIRCLE..": To go Back", 1, color.white, color.blue, __ACENTER)
		end
		draw.fillrect(0,516,960,30, 0x64545353)--Down

		screen.flip()

		if buttons.triangle and scrids.maxim > 0 then
			change = not change
			if not change then optsel = 2 end
		end

		if buttons.circle and not change then
			for i=1,bubbles.len do
				if bubbles.list[i].update then
					for j=1, #boot do
						ini.write(bubbles.list[i].pathini, boot[j], bubbles.list[i].lines[j])
					end
				end
				files.rename(bubbles.list[i].pathini, "boot.inf")
			end
			os.delay(15)
			return false
		end

	end
end
