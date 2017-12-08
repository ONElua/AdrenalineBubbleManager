--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 
scan = {}
toinstall = 0

function scan.insertCISO(hand)
	local _type = files.type(hand.path)
	if _type == 2 or _type == 3 then
		local tmp0 = game.info(hand.path)
		if tmp0 then
			if tmp0.CATEGORY == "UG" or tmp0.CATEGORY == "PG" then
				init_msg(string.format(strings.loadciso.." %s\n",hand.path))

				local imgicon,getw = game.geticon0(hand.path),80
				if imgicon then
					if imgicon:getw()>144 then imgicon:resize(144,80) getw = 144
					else getw = imgicon:getw() end
				end

				table.insert(scan.list, { img = imgicon, title = tmp0.TITLE or hand.name, path = hand.path, name = hand.name, imgw = getw,
									  inst=false, width = screen.textwidth(tmp0.TITLE or hand.name), selcc = 1, nostretched=false, mtime = hand.mtime })
			end
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
	if files.exists(string.format("%s__sce_ebootpbp",files.nofile(hand.path))) then return end
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
			init_msg(string.format(strings.loadpbp.." %s\n",hand.path))

			local imgicon,getw = game.geticon0(hand.path),80
			if imgicon then
				if imgicon:getw()>144 then imgicon:resize(144,80) getw = 144
				else getw = imgicon:getw() end
			end

			table.insert(scan.list, { img = imgicon, title = tmp0.TITLE, path = hand.path, name = hand.name, imgw = getw,
									  inst=false, width = screen.textwidth(tmp0.TITLE or hand.name), selcc = 1, nostretched=false, mtime = hand.mtime })
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
	if files.exists("imc0:") then
		scan.isos("imc0:pspemu/ISO")
		scan.pbps("imc0:pspemu/PSP/GAME")
	end
	scan.len = #scan.list
	if scan.len > 0 then
		table.sort(scan.list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end)
	end
end

function scan.show(objedit)

	local __PIC = false
	local scr,pic1 = newScroll(scan.list,12),nil

	buttons.interval(10,10)
	local xscr,xscrtitle = 15,30
	local sort = true
	while true do
		buttons.read()
		if back then back:blit(0,0) end

		draw.fillrect(0,0,960,30, 0x64545353) --UP
		screen.print(480,5,strings.scantitle, 1, color.white, color.blue, __ACENTER)
		screen.print(950,5,strings.count.." "..scr.maxim, 1, color.red, color.gray, __ARIGHT)

		if scr.maxim > 0 then

			if buttons.up or buttons.down then
				if buttons.up then scr:up() else scr:down() end
				if __PIC then
					pic1 = game.getpic1(scan.list[scr.sel].path)
				end
			end

			if buttons.analogly < -60 then scr:up()   end
			if buttons.analogly > 60 then  scr:down() end

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
				if i==scr.sel then draw.fillrect(5,y-3,945-scan.list[scr.sel].imgw,25,color.red) end

				if scan.list[i].width > (940-scan.list[i].imgw) then
					xscrtitle = screen.print(xscrtitle, 523, scan.list[i].title or scan.list[i].name,1,color.white,color.blue,__SLEFT,940-scan.list[i].imgw)
				else
					screen.print(30,y,scan.list[i].title, 1, color.white, color.blue)
				end

				if scan.list[i].inst then
					screen.print(8,y,"»",1,color.white,color.green)
				end

				y += 25
			end

			--Blit icon0
			if scan.list[scr.sel].img then
				--Full bbl icon
				if scan.list[scr.sel].nostretched then
					screen.clip(960-45, 75, 40)
						scan.list[scr.sel].img:center()
						scan.list[scr.sel].img:blit(960-45, 75)
					screen.clip()
				else
					scan.list[scr.sel].img:center()
					scan.list[scr.sel].img:blit(960 - (scan.list[scr.sel].imgw/2), 70)
				end
			else
				if scan.list[scr.sel].nostretched then
					draw.gradcircle(960-45,75,45, color.white:a(100),color.white:a(100))
				else
					draw.fillrect(960-80,35, 80, 80, color.white:a(100))
					draw.rect(960-80,35, 80, 80, color.white)
				end
			end

			if scan.list[scr.sel].nostretched then
				screen.print(955,120,strings.fullbbicon,1,color.white,color.blue,__ARIGHT)
			else
				screen.print(955,120,strings.nostretched,1,color.white,color.blue,__ARIGHT)
			end

			--Bubbles Colors
			if scan.list[scr.sel].selcc == 1 then
				screen.print(960-40,465,strings.defcolor.." ("..scan.list[scr.sel].selcc..")",1,color.white,color.blue, __ARIGHT)
			else
				screen.print(960-40,465,strings.bbcolor.." ("..scan.list[scr.sel].selcc..")",1,color.white,color.blue, __ARIGHT)
			end
			draw.fillrect(960-30,463,18,18, colors[scan.list[scr.sel].selcc])
			draw.rect(960-30,463,18,18, color.white)

			--Right
			if buttonskey then buttonskey:blitsprite(930,487,1) end                     --△
			screen.print(920,490,strings.pics,1,color.white,color.blue, __ARIGHT)

			--Left
			if buttonskey then buttonskey2:blitsprite(10,438,1) end                     --Start
			screen.print(45,440,strings.press_start,1,color.white,color.blue)

			if buttonskey then buttonskey:blitsprite(15,463,2) end                     --[]
			screen.print(45,465,strings.markgame,1,color.white,color.blue)

			if buttonskey then buttonskey:blitsprite(15,487,3) end						--O
			screen.print(45,490,strings.bsettings,1,color.white,color.blue)

			if scan.list[scr.sel].width > 940 then
				xscr = screen.print(xscr, 523, scan.list[scr.sel].path or scan.list[scr.sel].name,1,color.white,color.blue,__SLEFT,940)
			else
				screen.print(15, 523, scan.list[scr.sel].path or scan.list[scr.sel].name,1,color.white,color.blue)
			end

		else
			screen.print(480,272,strings.notpsp, 1, color.white, color.red, __ACENTER)
			screen.print(480,292,strings.installgames, 1, color.white, color.blue, __ACENTER)
			screen.print(480,312,strings.installgames2, 1, color.white, color.blue, __ACENTER)
		end
		draw.fillrect(0,516,960,30, 0x64545353)--Down

		screen.flip()

		--Controls
		if buttons.cross and scr.maxim > 0 then
			if toinstall <= 1 then
				bubbles.install(scan.list[scr.sel])
			else
				local vbuff = screen.toimage()
				local tmp,c = toinstall,0
				for i=1, scr.maxim do
					if vbuff then vbuff:blit(0,0) end
					screen.print(480,415,strings.bubbles.." ( "..(c+1).." / "..tmp.." )",1,color.white,color.blue, __ACENTER)
					draw.rect(0, 437, 960, 20, color.new(25,200,25))
					draw.fillrect(0,437, ((c+1)*960)/tmp,20,color.new(0,255,0))
					screen.flip()
					if scan.list[i].inst then
						bubbles.install(scan.list[i])
						c+=1
					end
				end
				os.delay(50)
			end
		end

		if buttons.triangle and scr.maxim > 0 then
			__PIC = not __PIC
			if not __PIC then pic1 = nil
			else pic1 = game.getpic1(scan.list[scr.sel].path) end
		end

		if buttons.square and scr.maxim > 0 then
			scan.list[scr.sel].inst = not scan.list[scr.sel].inst
			if scan.list[scr.sel].inst then toinstall+=1 else toinstall-=1 end
		end

		if buttons.select and scr.maxim > 0 then
			if sort then
				table.sort(scan.list ,function (a,b) return string.lower(a.mtime)<string.lower(b.mtime) end)
				sort = not sort
			else
				table.sort(scan.list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end)
				sort = not sort
			end
			scr:set(scan.list,14)
		end

		if buttons.start then
			os.message(strings.press_lr.."\n\n"..strings.press_lright.."\n\n"..strings.press_select)
		end

		if buttons.circle then bubbles.settings() end

		if (buttons.r or buttons.l) and scr.maxim > 0 then
			scan.list[scr.sel].nostretched = not scan.list[scr.sel].nostretched
		end

		--Bubbles Color
		if buttons.right and scr.maxim > 0 then scan.list[scr.sel].selcc += 1 end
		if buttons.left and scr.maxim > 0 then scan.list[scr.sel].selcc -= 1 end
		if scr.maxim > 0 then
			if scan.list[scr.sel].selcc > #colors then scan.list[scr.sel].selcc = 1 end
			if scan.list[scr.sel].selcc < 1 then scan.list[scr.sel].selcc = #colors end
		end

	end
end
