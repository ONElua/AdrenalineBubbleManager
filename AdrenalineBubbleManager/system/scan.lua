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
toinstall = 0
local pic1,icon0 = nil,nil
local crono, clicked = timer.new(), false -- Timer and Oldstate to click actions.
local __PIC = false
local tmp_sort = __SORT

function insert(tmp_sfo,obj,device)

	local install,state,orig = "a",false,false

	for i=1,bubbles.len do
		if obj.path:lower() == bubbles.list[i].iso:lower() then
			install,state = "b",true
			break
		end
	end

	if game.exists(obj.name) then orig = true end

	if tmp_sfo.TITLE then tmp_sfo.TITLE = tmp_sfo.TITLE:gsub("\n"," ") end

	table.insert( scan.list,
		{
		  title = tmp_sfo.TITLE or obj.name, path = obj.path:lower(), name = obj.name, inst = false, icon = true,
		  install = install, state = state, width = screen.textwidth(tmp_sfo.TITLE or obj.name), selcc = __COLOR, setpack = setpack,
		  nostretched=false, mtime = obj.mtime, type = tmp_sfo.CATEGORY or STRINGS_UNK, gameid = tmp_sfo.DISC_ID or STRINGS_UNK,
		  orig = orig, device = device
		} )
end

function scan.insertCISO(hand,device)
	local _type = files.type(hand.path)
	if _type == 2 or _type == 3 then
		local tmp0 = game.info(hand.path)
		if tmp0 then
			if tmp0.CATEGORY == "UG" or tmp0.CATEGORY == "PG" then
				init_msg(string.format(DEBUG_LOAD_CISO.." %s\n",hand.path))
				insert(tmp0,hand,device)
			end
		end
		tmp0 = nil
	end
end

function scan.isos(path,device)
	local tmp = files.list(path)
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if tmp[i].directory then
				local ls=files.listfiles(tmp[i].path)
				if ls and #ls > 0 then
					for j=1, #ls do
						local ext = ls[j].ext:upper()
						if ext == "ISO" or ext == "CSO" then scan.insertCISO(ls[j],device) end
					end
				end
			else
				if tmp[i].ext and (tmp[i].ext:upper() == "ISO" or tmp[i].ext:upper() == "CSO" ) then
					scan.insertCISO(tmp[i],device)                     -- Recursive only 2 levels
				end
			end

		end
	end
end

function scan.insertPBP(hand,device)

	--if game.exists(hand.name) then return end                  -- Is oficial PSP game (Bubble), not read :P
	--if files.exists(string.format("%s__sce_ebootpbp",files.nofile(hand.path))) then return end

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
			init_msg(string.format(DEBUG_LOAD_PBP.." %s\n",hand.path))
			insert(tmp0,hand,device)
		end
		tmp0 = nil
	end
end

function scan.pbps(path, device, level)
	if not level then level = 1 end
	local tmp = files.listdirs(path)
	if tmp and #tmp > 0 then
		for i=1, #tmp do
			if files.exists(tmp[i].path.."/EBOOT.PBP") then
				tmp[i].path += "/EBOOT.PBP"
				scan.insertPBP(tmp[i],device)
			elseif level == 1 then
				scan.pbps(tmp[i].path, device, 2)                     -- Recursive only 2 levels
			end
		end
	end
end

function scan.games()
	scan.list = {}
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
		table.sort(scan.list ,function (a,b) return string.lower(a[sort_mode[__SORT]])<string.lower(b[sort_mode[__SORT]]) end)
	end
end

function load_pic1(obj)
	if obj.setpack == STRINGS_PSP_PSX_BUBBLES then
		if obj.type == "ME" then--PS1 Game
			pic1 = PSX_IMG
		else
			pic1 = PSP_IMG
		end
	elseif obj.setpack == STRINGS_OPTION_MSG_NO then
		pic1 = game.getpic1(obj.path)
	else
		pic1=image.load(__PATHSETS..obj.setpack.."/BG0.PNG")
	end

	if pic1 then
		pic1:resize(960,488)
		pic1:center()
	end

end

local maximg = 14
function scan.show(objedit)

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
		screen.print(480,5,SCAN_TITLE, 1, color.white, color.blue, __ACENTER)
		screen.print(950,5,BUBBLES_COUNT.." "..scr.maxim, 1, color.red, color.shine, __ARIGHT)

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

			--Print Streched
			if scan.list[scr.sel].nostretched then
				screen.print(955,120,SCAN_FULLBUBBLE,1,color.white,color.blue,__ARIGHT)
			else
				screen.print(955,120,SCAN_BB_NOTSTRETCHED,1,color.white,color.blue,__ARIGHT)
			end

			--Print Sort
			screen.print(955,155,SCAN_SORT_BY,1,color.white,color.blue,__ARIGHT)
			screen.print(955,175, sort_games[__SORT], 1,color.white,color.blue,__ARIGHT)

			--Print SetPack
			screen.print(955,210,STRINGS_SETIMGS..":",1,color.white,color.blue,__ARIGHT)
			screen.print(955,235,scan.list[scr.sel].setpack,1,color.white,color.blue,__ARIGHT)

			--Print Gameid
			screen.print(955,270,SCAN_SORT_GAMEID..":",1,color.white,color.blue,__ARIGHT)
			screen.print(955,290,scan.list[scr.sel].gameid or STRINGS_UNK,1,color.white,color.blue,__ARIGHT)

			--Print PIC
			if __PIC then
				screen.print(955,325,SCAN_SHOW_PIC,1,color.white,color.blue,__ARIGHT)
			end

			--Left Options
			if scan.list[scr.sel].selcc == 1 then
				xprint = screen.print(20,465,"<- "..SCAN_DEFAULT_COLOR.." ("..scan.list[scr.sel].selcc..") ->",1,color.white,color.blue, __ALEFT)
			else
				xprint = screen.print(20,465,"<- "..SCAN_BUBBLE_COLOR.." ("..scan.list[scr.sel].selcc..") ->",1,color.white,color.blue, __ALEFT)
			end
			draw.fillrect(xprint + 30,463,18,18, colors[scan.list[scr.sel].selcc])
			draw.rect(xprint + 30,463,18,18, color.white)

			if buttonskey then buttonskey:blitsprite(15,487,2) end                     		--[]
			screen.print(45,490,SCAN_MARK_GAME,1,color.white,color.blue)

			--Right Options
			if buttonskey then buttonskey2:blitsprite(925,463,1) end                   		--Start
			screen.print(920,465,STRINGS_EXTRA_SETTINGS,1,color.white,color.blue,__ARIGHT)

			if accept_x == 1 then
				if buttonskey then buttonskey:blitsprite(935,487,3) end						--O
			else
				if buttonskey then buttonskey:blitsprite(935,487,0) end						--X
			end
			screen.print(920,490,SCAN_BUBBLES_SETTINGS,1,color.white,color.blue,__ARIGHT)

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

			if buttons.up or buttons.analogly<-60 then 
				if scr:up() then
					icon0=nil
					if __PIC then load_pic1(scan.list[scr.sel])	end
				end
			end

			if buttons.down or buttons.analogly>60 then
				if scr:down() then
					icon0=nil
					if __PIC then load_pic1(scan.list[scr.sel])	end
				end
			end

			if (buttons.released.l or buttons.released.r) or (buttons.analogly < -60 or buttons.analogly > 60) then
				if __PIC then load_pic1(scan.list[scr.sel])	end
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
							screen.print(480,405,STRINGS_BUBBLES_BAR.." ( "..(c+1).." / "..tmp.." )",1,color.white,color.blue, __ACENTER)
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

			--PIC
			if buttons.triangle then
				__PIC = not __PIC
				if __PIC then load_pic1(scan.list[scr.sel])	else pic1 = nil	end
			end
				
			--Mark/Unmark
			if buttons.square then
				scan.list[scr.sel].inst = not scan.list[scr.sel].inst
				if scan.list[scr.sel].inst then toinstall+=1 else toinstall-=1 end
			end

			--Sort
			if buttons.select then
				icon0=nil
				__SORT += 1

				if __SORT > #sort_games then __SORT = 1 end
				if __SORT < 1 then __SORT = #sort_games end
				table.sort(scan.list ,function (a,b) return string.lower(a[sort_mode[__SORT]])<string.lower(b[sort_mode[__SORT]]) end)
				scr:set(scan.list,maximg)
			end

			--Full/Stretched
			if buttons.released.l then
				scan.list[scr.sel].nostretched = not scan.list[scr.sel].nostretched
			end

			if buttons.released.r then
				if scan.list[scr.sel].setpack == STRINGS_OPTION_MSG_NO then
					scan.list[scr.sel].setpack = SCAN_SETPACK.."1"
				elseif scan.list[scr.sel].setpack == SCAN_SETPACK.."1" then
					scan.list[scr.sel].setpack = SCAN_SETPACK.."2"
				elseif scan.list[scr.sel].setpack == SCAN_SETPACK.."2" then
					scan.list[scr.sel].setpack = SCAN_SETPACK.."3"
				elseif scan.list[scr.sel].setpack == SCAN_SETPACK.."3" then
					scan.list[scr.sel].setpack = SCAN_SETPACK.."4"
				elseif scan.list[scr.sel].setpack == SCAN_SETPACK.."4" then
					scan.list[scr.sel].setpack = SCAN_SETPACK.."5"
				elseif scan.list[scr.sel].setpack == SCAN_SETPACK.."5" then
					scan.list[scr.sel].setpack = STRINGS_PSP_PSX_BUBBLES
				elseif scan.list[scr.sel].setpack == STRINGS_PSP_PSX_BUBBLES then
					scan.list[scr.sel].setpack = STRINGS_OPTION_MSG_NO
				end
				--Update PIC
				if __PIC then load_pic1(scan.list[scr.sel])	end
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
local yf, _save = 300,false
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
		{ text = STRINGS_CONVERT_8BITS, 	desc = STRINGS_DESC_CONVERT8BITS },
		{ text = STRINGS_SETIMGS, 			desc = STRINGS_DESC_SETIMGS },
		{ text = STRINGS_DEFAULT_SORT,		desc = STRINGS_DESC_DEFAULT_SORT },
		{ text = STRINGS_DEFAULT_COLOR,		desc = STRINGS_DESC_DEFAULT_COLOR },
		{ text = STRINGS_CUSTOMIZED,		desc = STRINGS_DESC_CUSTOMIZED },
		{ text = STRINGS_ABM_UPDATE,		desc = STRINGS_DESC_ABM_UPDATE },
		{ text = STRINGS_CHECK_ADRENALINE, 	desc = STRINGS_DESC_CHECK_ADRENALINE },
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
				table.sort(scan.list ,function (a,b) return string.lower(a[sort_mode[__SORT]])<string.lower(b[sort_mode[__SORT]]) end)
				obj:set(scan.list,maximg)
			end
			ini.write(__PATHINI,"sort","sort",_sort)--Save __SORT
			
			for i=1,scan.len do
				scan.list[i].selcc = _color
				scan.list[i].setpack = setpack
			end
			ini.write(__PATHINI,"color","color",_color)					--Save __COLOR
			ini.write(__PATHINI,"update","update",__UPDATE)				--Save __UPDATE
			ini.write(__PATHINI,"check_adr","check_adr",__CHECKADR)		--Save __CHECKADR
			ini.write(__PATHINI,"resources","set",__SET)				--Save __SET
			ini.write(__PATHINI,"convert","8bits",__8PNG)				--Save __8PNG
			ini.write(__PATHINI,"custom","customized",__CUSTOM)			--Save __CUSTOM

		end
		_save = false
	end

	submenu_abm.draw(obj)

end

local x_scroll_submenu = 5
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
		if buttons.up then submenu_abm.scroll:up() x_scroll_submenu=5 end
		if buttons.down then submenu_abm.scroll:down() x_scroll_submenu = 5 end

		if isTouched(0,0,960,544) and touch.front[1].released then
			if clicked then
				clicked = false
				if crono:time() <= 300 then -- Double click and in time to Go.
					-- Your action here.
					custom_msg(SCAN_PRESS_LR.."\n\n"..SCAN_PRESS_LEFT_RIGHT.."\n\n"..SCAN_PRESS_SELECT.."\n\n"..SCAN_TOGGLE_PICS.."\n"..STRING_PRESS,0)
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

				if __8PNG == 1 then __8PNG,_png = 0,STRINGS_OPTION_MSG_NO
				else __8PNG,_png = 1,STRINGS_OPTION_MSG_YES end

			elseif submenu_abm.scroll.sel == 2 then--Set Packs

				if buttons.right then __SET +=1 end
				if buttons.left then __SET -=1 end

				if __SET > TOTAL_SET then __SET = 0 end
				if __SET < 0 then __SET = TOTAL_SET end

				if __SET == 0 then setpack = STRINGS_OPTION_MSG_NO
				elseif __SET == 6 then setpack = STRINGS_PSP_PSX_BUBBLES
				else setpack = SCAN_SETPACK..__SET end

			elseif submenu_abm.scroll.sel == 3 then--Sort

				if buttons.right then _sort +=1 end
				if buttons.left then _sort -=1 end

				if _sort > #sort_games then _sort = 1 end
				if _sort < 1 then _sort = #sort_games end

				sort_type = sort_games[_sort]

			elseif submenu_abm.scroll.sel == 4 then--Color

				if buttons.right then _color +=1 end
				if buttons.left then _color -=1 end

				if _color > #colors then _color = 1 end
				if _color < 1 then _color = #colors end

			elseif submenu_abm.scroll.sel == 5 then--Customized
				if __CUSTOM == 1 then __CUSTOM,_custom = 0,STRINGS_OPTION_MSG_NO
				else __CUSTOM,_custom = 1,STRINGS_OPTION_MSG_YES end

			elseif submenu_abm.scroll.sel == 6 then--Update
				if __UPDATE == 1 then __UPDATE,_update = 0,STRINGS_OPTION_MSG_NO
				else __UPDATE,_update = 1,STRINGS_OPTION_MSG_YES end

			elseif submenu_abm.scroll.sel == 7 then--CheckAdrenaline
				if __CHECKADR == 1 then __CHECKADR,_adr = 0,STRINGS_OPTION_MSG_NO
				else __CHECKADR,_adr = 1,STRINGS_OPTION_MSG_YES end

			end
			_save = true
		end

		screen.print(480, 5, STRINGS_EXTRA_SETTINGS, 1, color.white, color.blue, __ACENTER)
		screen.print(480, 32, STRINGS_WARNING, 1, color.white, color.red, __ACENTER)

		local h = 65
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
				draw.fillrect(670, h,18,18, colors[_color])
				draw.rect(670,h,18,18, color.white)
				screen.print(655, h, "(".._color..")", 1, sel_color, color.blue, __ARIGHT)
			elseif i==5 then
				screen.print(690, h, _custom, 1, sel_color, color.blue, __ARIGHT)
			elseif i==6 then
				screen.print(690, h, _update, 1, sel_color, color.blue, __ARIGHT)
			elseif i==7 then
				screen.print(690, h, _adr, 1, sel_color, color.blue, __ARIGHT)
			end

			h += 27
        end

		if screen.textwidth(submenu_abm.options[submenu_abm.scroll.sel].desc,1) > 955 then
			x_scroll_submenu = screen.print(x_scroll_submenu, 265, submenu_abm.options[submenu_abm.scroll.sel].desc,1,color.green,color.shine,__SLEFT,955)
		else
			screen.print(480, 265, submenu_abm.options[submenu_abm.scroll.sel].desc, 1,color.green,color.shine, __ACENTER)
		end
		--screen.print(5, 222, SCAN_DOUBLE_TAP.."\n\n"..SCAN_PRESS_START, 1, color.white, color.blue, __ALEFT)

		draw.gradline(0,yf,960,yf,color.blue,color.green)
		draw.gradline(0,yf+1,960,yf+1,color.green,color.blue)

    else
        submenu_abm.open = false
    end
end
