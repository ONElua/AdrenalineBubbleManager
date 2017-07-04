--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME
scan = {}

function scan.insertCISO(hand)
	local _type = files.type(hand.path)
	if _type == 2 or _type == 3 then
		local tmp0 = game.info(hand.path)
		if tmp0 and tmp0.CATEGORY == "UG" then
			if debug_mode then print("Loading C/ISO %s\n",hand.path) end
			table.insert(scan.list, {img = game.geticon0(hand.path), title = tmp0.TITLE, path = hand.path, name = hand.name})
		end
		tmp0 = nil
	end
end

function scan.isos(path)
	local tmp = files.list(path)	
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if tmp[i].directory then --subcategories
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
					scan.insertCISO(tmp[i])
				end
			end

		end
	end
end

function scan.insertPBP(hand)
	if game.exists(hand.name) then return end -- Is oficial PSP game (Bubble), not read :P
	if files.type(hand.path) == 1 then
		local tmp0 = game.info(hand.path)
		if tmp0 then
			if tmp0.CATEGORY != "PG" then -- Really require this if?
				if debug_mode then print("Loading PBP %s\n",hand.path) end
				table.insert(scan.list, {img = game.geticon0(hand.path), title = tmp0.TITLE, path = hand.path, name = hand.name})
			end
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
				scan.pbps(tmp[i].path, 2) -- Recursive only 2 levels :P
			end
		end
	end
end

function scan.scan() -- Ohh recall a function and module? xD Jajaj
	scan.list = {}
	
	scan.isos("ux0:pspemu/ISO")
	scan.isos("ur0:pspemu/ISO")

	scan.pbps("ux0:pspemu/PSP/GAME")
	scan.pbps("ur0:pspemu/PSP/GAME")
	
	scan.len = #scan.list
end

function scan.show()
	if scan.len > 0 then
		table.sort(scan.list ,function (a,b) return string.lower(a.path)<string.lower(b.path); end)
	end

	local scr,pic1 = newScroll(scan.list,15),nil
	if scr.maxim > 0 then
		pic1 = game.getpic1(scan.list[scr.sel].path)
	end

	while true do
		buttons.read()
		if back then back:blit(0,0) end

		draw.fillrect(0,0,960,30, 0x64545353) --UP
		screen.print(480,5,"Games Availables [ISO/CSO/PBP]", 1, color.white, color.blue, __ACENTER)
		screen.print(950,5,"Count: " + scr.maxim, 1, color.red, color.gray, __ARIGHT)

		if scr.maxim > 0 then

			if buttons.up or buttons.down then
			if buttons.up then scr:up() else scr:down() end
				pic1 = game.getpic1(scan.list[scr.sel].path)
			end

			if (buttons.held.l or buttons.analogly < -60) then
				scr:up()
			end
			if (buttons.held.r or buttons.analogly > 60) then
				scr:down()
			end

			if (buttons.released.l or buttons.released.r) or (buttons.analogly < -60 or buttons.analogly > 60) then
				pic1 = game.getpic1(scan.list[scr.sel].path)
			end

			if pic1 then
				pic1:resize(960,488)
				pic1:center()
				pic1:blit(960/2, 544/2,200)
			end

			--Blit List
			local y = 70
			for i=scr.ini,scr.lim do
				if i==scr.sel then draw.fillrect(10,y-3,930-(scan.list[scr.sel].img:getrealw()),25,color.red) end
				screen.print(25,y,scan.list[i].title or scan.list[i].name, 1, color.white, color.blue)
				y += 25
			end

			--Blit icon0
			if scan.list[scr.sel].img then
				scan.list[scr.sel].img:center()
				scan.list[scr.sel].img:blit(960 - (scan.list[scr.sel].img:getrealw()/2), 70)
			end

			if buttonskey then buttonskey:blitsprite(930,490,2) end								--[]
			screen.print(920,495,"Deletes gameid.txt",1,color.white,color.blue, __ARIGHT)

			screen.print(15,523,scan.list[scr.sel].path or scan.list[scr.sel].name, 1, color.white, color.blue)

		else
			screen.print(480,272,"Not have any PSP Game :( Try again late!", 1, color.white, color.red, __ACENTER)
		end
		draw.fillrect(0,516,960,30, 0x64545353)--Down

		if buttonskey2 then buttonskey2:blitsprite(10,490,1) end								--Start
		screen.print(50,495,"Go to the Livearea",1,color.white,color.blue)

		screen.flip()

		--Controls
		if buttons.cross and scr.maxim > 0 then bubbles.selection(scan.list[scr.sel]) end

		if buttons.square then scan.deletes() end
		
	end
end

function scan.deletes()

	buttons.interval(10,10)

	local vbuff = screen.toimage()

	local gamesid = {}
	gamesid.list = files.list("ux0:adrbblbooter/bubblesdb/")
	
	gamesid.len = #gamesid.list
	if gamesid.len > 0 then
		table.sort(gamesid.list ,function (a,b) return string.lower(a.name)<string.lower(b.name); end)
	end

	local scrids = newScroll(gamesid.list, 16)
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

			local x,y = 120,90
			for i=scrids.ini, scrids.lim do
				if i == scrids.sel then draw.fillrect(x + 10,y-1,700,18,color.green:a(100)) end
				screen.print(480,y,gamesid.list[i].name or "unk",1.0,color.white,color.gray,__ACENTER)
				y += 23
			end

			screen.print(480,430,gamesid.list[scrids.sel].path,1,color.white, color.gray, __ACENTER)
			screen.print(480,460,"X: Delete txt      |      O: Cancel", 1, color.white, color.blue, __ACENTER)

		else
			screen.print(480,200,"Not have any Files List :( Try again late!", 1, color.white, color.red, __ACENTER)
		end

		screen.flip()

		if buttons.cross and scrids.maxim > 0 then
			files.delete(gamesid.list[scrids.sel].path)
			table.remove(gamesid.list, scrids.sel)
			scrids:set(gamesid.list,16)
		end

		if buttons.circle then
			return false
		end

	end
end
