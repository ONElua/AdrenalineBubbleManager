--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 
scan = {}
toinstall = 0
local pic1 = nil

function insert(tmp_sfo,obj)
	---check path vs bubbles
	local val,install,state=5,"a",false
	if obj.path:sub(1,2) != "um" and obj.path:sub(1,2) !="im" then val=4 end
	local path2game = obj.path:gsub(obj.path:sub(1,val).."pspemu/", "ms0:/")

	for i=1,bubbles.len do
		if path2game:lower() == bubbles.list[i].iso:lower() then
			install,state = "b",true
			break
		end
	end
	table.insert(scan.list, { title = tmp_sfo.TITLE or obj.name, path = obj.path, name = obj.name, inst=false, icon=true, install=install, state = state,
				path2game = path2game:lower(), width = screen.textwidth(tmp_sfo.TITLE or obj.name), selcc = 1, nostretched=false, mtime = obj.mtime })

end

function scan.insertCISO(hand)
	local _type = files.type(hand.path)
	if _type == 2 or _type == 3 then
		local tmp0 = game.info(hand.path)
		if tmp0 then
			if tmp0.CATEGORY == "UG" or tmp0.CATEGORY == "PG" then
				init_msg(string.format(strings.loadciso.." %s\n",hand.path))
				insert(tmp0,hand)
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
			insert(tmp0,hand)
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
		table.sort(scan.list ,function (a,b) return string.lower(a.install)<string.lower(b.install) end)
	end
end

function load_pic1(tmp_path)
	pic1 = game.getpic1(tmp_path)
	if pic1 then
		pic1:resize(__DISPLAYW,488)
		pic1:center()
	end
end

function scan.show(objedit)

	local __PIC = false
	local scr,icon0 = newScroll(scan.list,12),nil

	buttons.interval(12,5)
	local xscr,xscrtitle,sort,xprint = 15,30,2,5
	while true do
		buttons.read()
		
		if pic1 then pic1:blit(__DISPLAYW/2, 544/2)
		elseif back then back:blit(0,0) end
		if math.minmax(tonumber(os.date("%d%m")),2312,2512)== tonumber(os.date("%d%m")) then stars.render() end

		draw.fillrect(0,0,__DISPLAYW,30, 0x64545353) --UP
		screen.print(480,5,strings.scantitle, 1, color.white, color.blue, __ACENTER)
		screen.print(950,5,strings.count.." "..scr.maxim, 1, color.red, color.shine, __ARIGHT)

		if scr.maxim > 0 then

			--Blit List
			local y = 33
			for i=scr.ini,scr.lim do

				if scan.list[i].state then ccolor = color.green:a(180) else ccolor = color.white end

				if i==scr.sel then
					draw.fillrect(5,y-3,__DISPLAYW-144-15,25,color.red)
					if not icon0 then
						if scan.list[scr.sel].icon then
							icon0 = game.geticon0(scan.list[scr.sel].path)
							if icon0 then
								if icon0:getw()>144 then icon0:resize(144,80) end
								icon0:center()
								icon0:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
							else
								scan.list[scr.sel].icon = false
							end
						end
					end
				end

				if scan.list[i].width > (__DISPLAYW-144-30) then
					xscrtitle = screen.print(xscrtitle, 523, scan.list[i].title,1,ccolor,color.shine,__SLEFT,__DISPLAYW-144-30)
				else
					screen.print(30,y,scan.list[i].title, 1, ccolor, color.shine)
				end

				if scan.list[i].inst then
					screen.print(8,y,"»",1,color.white,color.green)
				end

				y += 25
			end

			--Blit icon0
			if icon0 then
				--Full bbl icon
				if scan.list[scr.sel].nostretched then
					screen.clip(__DISPLAYW-45, 75, 40)
						icon0:blit(__DISPLAYW-45, 75)
					screen.clip()
				else
					icon0:blit(__DISPLAYW - (icon0:getw()/2), 70)
				end
			else
				if scan.list[scr.sel].nostretched then
					draw.gradcircle(__DISPLAYW-45,75,45, color.white:a(100),color.white:a(100))
				else
					draw.fillrect(__DISPLAYW-80,35, 80, 80, color.white:a(100))
					draw.rect(__DISPLAYW-80,35, 80, 80, color.white)
				end
			end

			if scan.list[scr.sel].nostretched then
				screen.print(955,120,strings.fullbbicon,1,color.white,color.blue,__ARIGHT)
			else
				screen.print(955,120,strings.nostretched,1,color.white,color.blue,__ARIGHT)
			end
			
			screen.print(955,155,strings.sort,1,color.white,color.blue,__ARIGHT)
			if sort==0 then
				screen.print(955,175,strings.sorttitle,1,color.white,color.blue,__ARIGHT)
			elseif sort==1 then
				screen.print(955,175,strings.sortmtime,1,color.white,color.blue,__ARIGHT)
			else
				screen.print(955,175,strings.sortnoinst,1,color.white,color.blue,__ARIGHT)
			end

			--Left Options
			if scan.list[scr.sel].selcc == 1 then
				xprint = screen.print(20,465,"<- "..strings.defcolor.." ("..scan.list[scr.sel].selcc..") ->",1,color.white,color.blue, __ALEFT)
			else
				xprint = screen.print(20,465,"<- "..strings.bbcolor.." ("..scan.list[scr.sel].selcc..") ->",1,color.white,color.blue, __ALEFT)
			end
			draw.fillrect(xprint + 30,463,18,18, colors[scan.list[scr.sel].selcc])
			draw.rect(xprint + 30,463,18,18, color.white)

			if buttonskey then buttonskey:blitsprite(15,487,2) end                     		--[]
			screen.print(45,490,strings.markgame,1,color.white,color.blue)

			--Right Options
			if buttonskey then buttonskey2:blitsprite(925,463,1) end                   		--Start
			screen.print(920,465,strings.press_start,1,color.white,color.blue,__ARIGHT)

			if buttonskey then buttonskey:blitsprite(935,487,3) end							--O
			screen.print(920,490,strings.bsettings,1,color.white,color.blue,__ARIGHT)

			if scan.list[scr.sel].width > 940 then
				xscr = screen.print(xscr, 523, scan.list[scr.sel].path or scan.list[scr.sel].name,1,color.white,color.blue,__SLEFT,940)
			else
				screen.print(15, 523, scan.list[scr.sel].path or scan.list[scr.sel].name,1,color.white,color.blue)
			end

		else
			screen.print(480,252,strings.notpsp, 1, color.white, color.red, __ACENTER)
			screen.print(480,292,strings.installgames, 1, color.white, color.blue, __ACENTER)
			screen.print(480,312,strings.installgames2, 1, color.white, color.blue, __ACENTER)
		end
		draw.fillrect(0,516,__DISPLAYW,30, 0x64545353)--Down

		screen.flip()

		--Controls
		if scr.maxim > 0 then

			if buttons.up or buttons.analogly<-60 then 
				if scr:up() then
					icon0=nil
					if __PIC then
						load_pic1(scan.list[scr.sel].path)
					end
				end
			end

			if buttons.down or buttons.analogly>60 then
				if scr:down() then
					icon0=nil
					if __PIC then
						load_pic1(scan.list[scr.sel].path)
					end
				end
			end

			if (buttons.released.l or buttons.released.r) or (buttons.analogly < -60 or buttons.analogly > 60) then
				if __PIC then
					load_pic1(scan.list[scr.sel].path)
				end
			end

			--Install
			if buttons.cross then
				if toinstall <= 1 then
					bubbles.install(scan.list[scr.sel])
				else
					local vbuff = screen.toimage()
					local tmp,c = toinstall,0
					for i=1, scr.maxim do

						if vbuff then vbuff:blit(0,0) end
							screen.print(480,395,strings.bubbles.." ( "..(c+1).." / "..tmp.." )",1,color.white,color.blue, __ACENTER)
							draw.rect(0, 417, __DISPLAYW, 20, color.new(25,200,25))
							draw.fillrect(0,417, ((c+1)*__DISPLAYW)/tmp,20,color.new(0,255,0))
						screen.flip()

						if scan.list[i].inst then
							bubbles.install(scan.list[i])
							c+=1
						end
					end
					os.delay(50)
				end
			end

			--PIC
			if buttons.triangle then
				__PIC = not __PIC
				if not __PIC then pic1 = nil
				else load_pic1(scan.list[scr.sel].path) end
			end
				
			--Mark/Unmark
			if buttons.square then
				scan.list[scr.sel].inst = not scan.list[scr.sel].inst
				if scan.list[scr.sel].inst then toinstall+=1 else toinstall-=1 end
			end

			--Sort
			if buttons.select then
				icon0=nil
				if sort==0 then
					table.sort(scan.list ,function (a,b) return string.lower(a.mtime)<string.lower(b.mtime) end)
					sort = 1
				elseif sort==1 then
					table.sort(scan.list ,function (a,b) return string.lower(a.install)<string.lower(b.install) end)
					sort = 2
				else
					table.sort(scan.list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end)
					sort = 0
				end
				scr:set(scan.list,12)
			end	
				
			--Full/Stretched
			if (buttons.r or buttons.l) then
				scan.list[scr.sel].nostretched = not scan.list[scr.sel].nostretched
			end

			--Bubbles Color
			if buttons.right then scan.list[scr.sel].selcc += 1 end
			if buttons.left then scan.list[scr.sel].selcc -= 1 end	

			if scan.list[scr.sel].selcc > #colors then scan.list[scr.sel].selcc = 1 end
			if scan.list[scr.sel].selcc < 1 then scan.list[scr.sel].selcc = #colors end

			if buttons.start then
				os.message(strings.press_lr.."\n\n"..strings.press_lright.."\n\n"..strings.press_select.."\n\n"..strings.pics.."\n\n"..strings.press_cross)
			end
		end

		if buttons.circle then bubbles.settings() end

	end

end
