--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG 
scan = {}
toinstall = 0
local pic1,icon0 = nil,nil
local crono, clicked = timer.new(), false -- Timer and Oldstate to click actions.
local __PIC = false
local tmp_sort = __SORT

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
				path2game = path2game:lower(), width = screen.textwidth(tmp_sfo.TITLE or obj.name), selcc = __COLOR, nostretched=false, mtime = obj.mtime,
				type =	tmp_sfo.CATEGORY or "UNK"	})

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
		if __SORT==0 then
			table.sort(scan.list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end)
		elseif __SORT==1 then
			table.sort(scan.list ,function (a,b) return string.lower(a.mtime)<string.lower(b.mtime) end)
		elseif __SORT==2 then
			table.sort(scan.list ,function (a,b) return string.lower(a.install)<string.lower(b.install) end)
		elseif __SORT==3 then
			table.sort(scan.list ,function (a,b) return string.lower(a.type)<string.lower(b.type) end)
		end
	end
end

function load_pic1(tmp_path, flag)
	if flag then pic1=image.load(tmp_path)
	else pic1 = game.getpic1(tmp_path) end
	if pic1 then
		pic1:resize(960,488)
		pic1:center()
	end
end

function scan.show(objedit)

	local maximg = 14
	local scr = newScroll(scan.list,maximg)

	buttons.interval(12,5)
	local xscr,xscrtitle,xprint = 15,20,5
	while true do
		buttons.read()
			touch.read()
		
		if pic1 then pic1:blit(960/2, 544/2, 175)
		elseif back1 then back1:blit(0,0) end
		if math.minmax(tonumber(os.date("%d%m")),2512,2512)== tonumber(os.date("%d%m")) then stars.render() end

		draw.fillrect(0,0,960,30, 0x64545353) --UP
		screen.print(480,5,strings.scantitle, 1, color.white, color.blue, __ACENTER)
		screen.print(950,5,strings.count.." "..scr.maxim, 1, color.red, color.shine, __ARIGHT)

		if scr.maxim > 0 then

			--Blit List
			local y = 33
			for i=scr.ini,scr.lim do

				if scan.list[i].state then ccolor = color.green:a(200) else ccolor = color.white end

				if i==scr.sel then
					draw.fillrect(3,y-3,960-144-28,25,color.blue:a(160))
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

				if scan.list[i].width > (960-144-30) then
					xscrtitle = screen.print(xscrtitle, 523, scan.list[i].title,1,ccolor,color.shine,__SLEFT,960-144-30)
				else
					screen.print(20,y,scan.list[i].title, 1, ccolor, color.shine)
				end

				if scan.list[i].inst then
					screen.print(8,y,"»",1,color.white,color.green)
				end

				y += 25
			end

			--Bar Scroll
			local ybar,h=30, (maximg*26)-3
			draw.fillrect(795, ybar-2, 8, h, color.shine)
			if scr.maxim >= maximg then -- Draw Scroll Bar
				local pos_height = math.max(h/scr.maxim, maximg)
				draw.fillrect(795, ybar-2 + ((h-pos_height)/(scr.maxim-1))*(scr.sel-1), 8, pos_height, color.new(0,255,0))
			end

			--Blit icon0
			if icon0 then
				--Full bbl icon
				if scan.list[scr.sel].nostretched then
					screen.clip(960-45, 75, 40)
						icon0:blit(960-45, 75)
					screen.clip()
				else
					--icon0:blit(960 - (icon0:getw()/2), 70)
					icon0:blit(885, 73)
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
			
			screen.print(955,155,strings.sort,1,color.white,color.blue,__ARIGHT)
			if __SORT==0 then
				screen.print(955,175,strings.sorttitle,1,color.white,color.blue,__ARIGHT)
			elseif __SORT==1 then
				screen.print(955,175,strings.sortmtime,1,color.white,color.blue,__ARIGHT)
			elseif __SORT==2 then
				screen.print(955,175,strings.sortnoinst,1,color.white,color.blue,__ARIGHT)
			elseif __SORT==3 then
				screen.print(955,175,strings.category,1,color.white,color.blue,__ARIGHT)
			end

			if __SET == 0 then
				screen.print(955,210,setpack.." "..strings.set,1,color.white,color.blue,__ARIGHT)
			else
				screen.print(955,210,setpack,1,color.white,color.blue,__ARIGHT)
			end

			if __PIC then
				screen.print(955,235,strings.showpic,1,color.white,color.blue,__ARIGHT)
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
			screen.print(920,465,strings.save,1,color.white,color.blue,__ARIGHT)

			if accept_x == 1 then
				if buttonskey then buttonskey:blitsprite(935,487,3) end						--O
			else
				if buttonskey then buttonskey:blitsprite(935,487,0) end						--X
			end
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
		draw.fillrect(0,516,960,30, 0x64545353)--Down

		submenu_abm.run(scr)

		screen.flip()

		--Controls
		if scr.maxim > 0 and submenu_abm.h == -submenu_abm.y then

			if buttons.up or buttons.analogly<-60 then 
				if scr:up() then
					icon0=nil
					if __PIC and __SET == 0 then
						load_pic1(scan.list[scr.sel].path)
					end
				end
			end

			if buttons.down or buttons.analogly>60 then
				if scr:down() then
					icon0=nil
					if __PIC and __SET == 0 then
						load_pic1(scan.list[scr.sel].path)
					end
				end
			end

			if (buttons.released.l or buttons.released.r) or (buttons.analogly < -60 or buttons.analogly > 60) then
				if __PIC and __SET == 0 then
					load_pic1(scan.list[scr.sel].path)
				end
			end

			--Install
			if buttons[accept] then
				if toinstall <= 1 then
					bubbles.install(scan.list[scr.sel])
				else
					local vbuff = screen.toimage()
					local tmp,c = toinstall,0
					for i=1, scr.maxim do

						if vbuff then vbuff:blit(0,0) end
							screen.print(480,395,strings.bubbles.." ( "..(c+1).." / "..tmp.." )",1,color.white,color.blue, __ACENTER)
							draw.rect(0, 417, 960, 20, color.new(25,200,25))
							draw.fillrect(0,417, ((c+1)*960)/tmp,20,color.new(0,255,0))
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
				if __PIC then 
					if __SET == 0 then load_pic1(scan.list[scr.sel].path)
					else load_pic1(__PATHSETS.."Set"..__SET.."/BG0.PNG", true) end
				else
					pic1 = nil
				end
			end
				
			--Mark/Unmark
			if buttons.square then
				scan.list[scr.sel].inst = not scan.list[scr.sel].inst
				if scan.list[scr.sel].inst then toinstall+=1 else toinstall-=1 end
			end

			--Sort
			if buttons.select then
				icon0=nil
				if __SORT==0 then
					table.sort(scan.list ,function (a,b) return string.lower(a.mtime)<string.lower(b.mtime) end)
					__SORT = 1
				elseif __SORT==1 then
					table.sort(scan.list ,function (a,b) return string.lower(a.install)<string.lower(b.install) end)
					__SORT = 2
				elseif __SORT==2 then
					table.sort(scan.list ,function (a,b) return string.lower(a.type)<string.lower(b.type) end)
					__SORT = 3
				elseif __SORT==3 then
					table.sort(scan.list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end)
					__SORT = 0
				end
				scr:set(scan.list,maximg)
			end	

			--Full/Stretched
			if (buttons.r or buttons.l) then
				scan.list[scr.sel].nostretched = not scan.list[scr.sel].nostretched
			end

			--Bubbles Color
			if buttons.right or buttons.left then

				if buttons.right then scan.list[scr.sel].selcc += 1 end
				if buttons.left then scan.list[scr.sel].selcc -= 1 end
			
				if scan.list[scr.sel].selcc > #colors then scan.list[scr.sel].selcc = 1 end
				if scan.list[scr.sel].selcc < 1 then scan.list[scr.sel].selcc = #colors end

			end

		end

		if buttons[cancel] and submenu_abm.h == -submenu_abm.y then bubbles.settings() end

	end

end

--------------------------SubMenuContextual
local yf, _save = 280,false
submenu_abm = { -- Creamos un objeto menu contextual
    h = yf,					-- Height of menu
    w = 960,				-- Width of menu
    x = 0,					-- X origin of menu
    y = -yf,				-- Y origin of menu
    open = false,			-- Is open the menu?
    close = true,
    speed = 10,				-- Speed of Effect Open/Close.
    ctrl = "start",
    scroll = newScroll(),	-- Scroll of menu options.
}

function submenu_abm.wakefunct()
	submenu_abm.options = { 	-- Handle Option Text and Option Function
		{ text = strings.convert8 },
		{ text = strings.setimgs },
		{ text = strings.def_sort },
		{ text = strings.def_color },
		{ text = strings.update },
		{ text = strings.checkadr },
    }
	submenu_abm.scroll = newScroll(submenu_abm.options, #submenu_abm.options)
end

submenu_abm.wakefunct()

function submenu_abm.run(obj)

	if buttons[submenu_abm.ctrl] then
		submenu_abm.close = not submenu_abm.close
		__PIC,pic1 = false,nil
		if submenu_abm.close and _save then
			__SORT = _sort

			if tmp_sort != _sort then
				icon0=nil
				if __SORT==0 then
					table.sort(scan.list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end)
				elseif __SORT==1 then
					table.sort(scan.list ,function (a,b) return string.lower(a.mtime)<string.lower(b.mtime) end)
				elseif __SORT==2 then
					table.sort(scan.list ,function (a,b) return string.lower(a.install)<string.lower(b.install) end)
				elseif __SORT==3 then
					table.sort(scan.list ,function (a,b) return string.lower(a.type)<string.lower(b.type) end)
				end

				obj:set(scan.list,maximg)
			end
			ini.write(__PATHINI,"sort","sort",_sort)--Save __SORT
			
			for i=1,scan.len do
				scan.list[i].selcc =  _color
			end
			ini.write(__PATHINI,"color","color",_color)--Save __COLOR
			
			ini.write(__PATHINI,"update","update",__UPDATE)--Save __UPDATE

			ini.write(__PATHINI,"check_adr","check_adr",__CHECKADR)--Save __CHECKADR

			ini.write(__PATHINI,"resources","set",__SET)--Save __SET

			ini.write(__PATHINI,"convert","8bits",__8PNG)--Save __8PNG

		end
		_save = false
	end

	submenu_abm.draw(obj)

end

function submenu_abm.draw(obj)

    if not submenu_abm.close and submenu_abm.y < 0 then
        submenu_abm.y += submenu_abm.speed
    elseif submenu_abm.close and submenu_abm.y > -submenu_abm.h then
        submenu_abm.y -= submenu_abm.speed
    end

	if submenu_abm.y > -submenu_abm.h then
		draw.fillrect(submenu_abm.x, submenu_abm.y, submenu_abm.w, submenu_abm.h, color.black:a(210))
	end

    if submenu_abm.y >= 0 then

        submenu_abm.open = true
		tmp_sort = __SORT
 
		--Buttons
		if buttons.up then submenu_abm.scroll:up() end
		if buttons.down then submenu_abm.scroll:down() end
		
		if isTouched(0,0,960,544) and touch.front[1].released then--pressed then
			if clicked then
				clicked = false
				if crono:time() <= 300 then -- Double click and in time to Go.
					-- Your action here.
					os.message(strings.press_lr.."\n\n"..strings.press_lright.."\n\n"..strings.press_select.."\n\n"..strings.pics.."\n\n"..strings.press_cross)
				end
			else
				clicked = true
				crono:reset()
				crono:start()
			end
		end

		if crono:time() > 300 then -- First click, but long time to double click...
			clicked = false
		end

		if (buttons.left or buttons.right) then

			if submenu_abm.scroll.sel == 1 then--Set 8bits

				if __8PNG == 1 then __8PNG = 0 else __8PNG = 1 end

				if __8PNG == 1 then _png = strings.option1_msg
				else _png = strings.option2_msg end

			elseif submenu_abm.scroll.sel == 2 then--Set Packs

				if buttons.right then __SET +=1 end
				if buttons.left then __SET -=1 end

				if __SET > 5 then __SET = 0 end
				if __SET < 0 then __SET = 5 end

				if __SET == 0 then setpack = strings.option2_msg
				else setpack = strings.set..__SET end

			elseif submenu_abm.scroll.sel == 3 then--Sort

				if buttons.right then _sort +=1 end
				if buttons.left then _sort -=1 end

				if _sort > 3 then _sort = 0 end
				if _sort < 0 then _sort = 3 end

				if _sort == 0 then sort_type = strings.sorttitle
					elseif _sort == 1 then sort_type = strings.sortmtime
						elseif _sort == 2 then sort_type = strings.sortnoinst
							elseif _sort == 3 then sort_type = strings.category end

			elseif submenu_abm.scroll.sel == 4 then--Color

				if buttons.right then _color +=1 end
				if buttons.left then _color -=1 end

				if _color > #colors then _color = 1 end
				if _color < 1 then _color = #colors end

			elseif submenu_abm.scroll.sel == 5 then--Update
				if __UPDATE == 1 then __UPDATE = 0 else __UPDATE = 1 end

				if __UPDATE == 1 then _update = strings.option1_msg
				else _update = strings.option2_msg end

			elseif submenu_abm.scroll.sel == 6 then--CheckAdrenaline
				if __CHECKADR == 1 then __CHECKADR = 0 else __CHECKADR = 1 end

				if __CHECKADR == 1 then _adr = strings.option1_msg
				else _adr = strings.option2_msg end
			end
			_save = true
		end

		screen.print(480, 5, strings.save, 1, color.white, color.blue, __ACENTER)
		screen.print(480, 32, strings.warning, 1, color.white, color.red, __ACENTER)

		local h = 75
        for i=submenu_abm.scroll.ini,submenu_abm.scroll.lim do

			if i==submenu_abm.scroll.sel then
				draw.fillrect(5,h-3, 960-5,25,color.shine)
				sel_color = color.green else sel_color = color.white
			end

			screen.print(230, h, submenu_abm.options[i].text, 1, sel_color, color.blue, __ALEFT)
			if i==1 then
				screen.print(690, h, _png, 1, sel_color, color.blue, __ARIGHT)
			elseif i==2 then
				screen.print(690, h, setpack, 1, sel_color, color.blue, __ARIGHT)
			elseif i==3 then
				screen.print(690, h, sort_type, 1, sel_color, color.blue, __ARIGHT)
			elseif i==4 then
				draw.fillrect(670, h,18,18, colors[_color])--106
				draw.rect(670,h,18,18, color.white)
			elseif i==5 then
				screen.print(690, h, _update, 1, sel_color, color.blue, __ARIGHT)
			elseif i==6 then
				screen.print(690, h, _adr, 1, sel_color, color.blue, __ARIGHT)
			end

			h += 27
        end

		--screen.print(5, 222, strings.touchme.."\n\n"..strings.press_start, 1, color.white, color.blue, __ALEFT)

		draw.gradline(0,yf,960,yf,color.blue,color.green)
		draw.gradline(0,yf+1,960,yf+1,color.green,color.blue)

    else
        submenu_abm.open = false
    end
end
