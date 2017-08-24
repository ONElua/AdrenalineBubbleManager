--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

-- Adrbblbooter v.05
if not files.exists(ADRBUBBLESDB) then files.mkdir(ADRBUBBLESDB) end
files.copy("adrbblbooter/adrbblbooter.suprx", "ur0:adrbblbooter/")
files.copy("adrbblbooter/readme.txt", "ur0:adrbblbooter/")

bubbles = {}

function bubbles.load()
	bubbles.list = {}
	local list = game.list(__PSPEMU)
	local len = #list

	for i=1, len do
		local _path = string.format("%s/eboot.pbp", list[i].path)
		local _ppath = string.format("%s/pboot.pbp", list[i].path)
		local info = game.info(_path)

		if info then
			if info.CATEGORY and info.CATEGORY != "ME" then						--Not PS1 ME

				local entry = {
					id = list[i].id,                                             	-- TITLEID of the game.
					path = list[i].path,                                         	-- Path to the folder of the game.
					icon = game.geticon0(_path),                           			-- Icon of the Game Eboot.
					picon = game.geticon0(_ppath),                           		-- Icon of the Game PBOOT (Only if exists!)
					ptitle = nil,                                                	-- Title of the PBOOT (Only if exists!)
					dds_png = false
				}

				if files.type(string.format("ur0:appmeta/%s/icon0.dds", list[i].id)) == 8 then entry.dds_png = true end

				if info.CATEGORY == "EG" then
					local sceid = game.sceid(string.format("%s/__sce_ebootpbp",entry.path))
					if sceid and sceid != "---" and sceid != entry.id then
						entry.clon = true
					end
				end
				entry.title = info.TITLE or entry.id

				if entry.picon then
					local pinfo = game.info(_ppath)
					entry.ptitle = pinfo.TITLE                                       -- if exists then text else nil :D
				end

				table.insert(bubbles.list, entry)                                   -- Insert entry in list of bubbles! :)
			end
		end
	end--for

	bubbles.len = #bubbles.list
	if bubbles.len > 0 then
		table.sort(bubbles.list ,function (a,b) return string.lower(a.id)<string.lower(b.id) end)
	end

end

-- src = objet game to launch - dst = gamebase.
function bubbles.install(src, dst, driver)

	local id = dst.id or (files.nopath(dst.path):gsub("/",""))

	local work_dir = "ux0:data/lmanbootr/"
	if not files.exists(work_dir) then files.mkdir(work_dir) end

	local bubble_title,info_sfo = nil, game.info(src.path)
	if info_sfo then
		bubble_title = osk.init("Bubble's Title", info_sfo.TITLE or "Put here name", 1, 128)
	end
	if not bubble_title then bubble_title = src.name end

	-- ICON0
	local icon = nil
	if files.type(src.path) == 1 then
		game.unpack(src.path, work_dir)
	else
		icon = game.geticon0(src.path)
		if icon then image.save(icon, work_dir.."ICON0.PNG") end
	end
	if not files.exists(work_dir.."ICON0.PNG") then   files.copy("pboot/ICON0.PNG",work_dir) end
	if not icon then icon = image.load(work_dir.."ICON0.PNG") end

	-----------------------------------      icon0.dds      --------------------------------------------------------------------
	local appmeta = string.format("ur0:appmeta/%s",id)
	if not files.exists(appmeta.."/livearea/contents/") then
		os.message("We need to open the basegame, Please return \n\nto ABM inmediatelly to continue the process...")
		game.open(id)
		os.delay(100)
		files.mkdir(appmeta.."/livearea/contents/")
		--os.exit()
	end
	--buttons.homepopup(0)
	--buttons.read()

	files.copy(work_dir.."ICON0.PNG", appmeta)
	if files.exists(appmeta.."/ICON0.PNG") then
		if not files.exists(appmeta.."/icon0_orig.dds") then
			if files.exists(appmeta.."/ICON0.dds") then
				files.rename(appmeta.."/ICON0.dds","icon0_orig.dds")
			end
		end

		if files.exists(appmeta.."/livearea/contents/ICON0.PNG") then
			files.delete(appmeta.."/livearea/contents/ICON0.PNG")
		end
		files.copy(appmeta.."/ICON0.PNG",appmeta.."/livearea/contents/")

		if not files.exists(appmeta.."/startup_orig.png") then
			if files.exists(appmeta.."/livearea/contents/startup.png") then
				files.rename(appmeta.."/livearea/contents/startup.png","startup_orig.png")
			end
		end

		if files.exists(appmeta.."/livearea/contents/STARTUP.PNG") then
			files.delete(appmeta.."/livearea/contents/STARTUP.PNG")
		end
		files.rename(appmeta.."/livearea/contents/ICON0.PNG","STARTUP.PNG")

		files.copy("pboot/template.xml",appmeta.."/livearea/contents/")

		if files.exists(appmeta.."/ICON0.dds") then
			files.delete(appmeta.."/ICON0.dds")
		end
		files.rename(appmeta.."/ICON0.PNG","ICON0.dds")

		dst.dds_png = true
		ForcePowerReset()
		os.message("ICON0.DDS Done!!!")
	end

	if not files.exists(appmeta.."/bg0_orig.png") then
		if files.exists(appmeta.."/livearea/contents/BG0.PNG") then
			files.rename(appmeta.."/livearea/contents/BG0.PNG","bg0_orig.png")
		end
	end

	local pic = game.getpic1(src.path)
	if pic then
		image.save(pic, appmeta.."/livearea/contents/BG0.PNG")
	else
		files.copy("sce_sys/livearea/contents/bg0.png",appmeta.."/livearea/contents/")
	end

	--Set app.db tittle
	os.titledb(tostring(bubble_title),id)
	----------------------------------------------------------------------------------------------------------------------------

	-----------------------------------      pboot.pbp      --------------------------------------------------------------------
	files.copy("pboot/DATA.PSP",work_dir)
	files.copy("pboot/PARAM.SFO",work_dir)

	-- Set SFO & TITLE
	game.setsfo(work_dir.."PARAM.SFO", "TITLE", tostring(bubble_title), 0)

	-- Pack all in a new PBOOT :D
	game.pack(work_dir)

	if files.exists(work_dir.."EBOOT.PBP") then

		files.rename(work_dir.."EBOOT.PBP","PBOOT.PBP")
		files.move(work_dir.."PBOOT.PBP", dst.path)

		--Refresh&Insert
		if icon then dst.picon = icon else dst.picon = icon0 end
		dst.ptitle = bubble_title

		ForcePowerReset()
		os.message("Custom PBOOT.PBP Done!!!")
		os.delay(100)
	end
	----------------------------------------------------------------------------------------------------------------------------
	
	local fp = io.open(ADRBUBBLESDB..id..".txt", "w+")
	if fp then

		val=5
		if src.path:sub(1,2) != "um" then val=4 end
		local path2game = src.path:gsub(src.path:sub(1,val).."pspemu/", "ms0:/")

		--Path ISO/CSO/PBP
		fp:write(path2game.."\n")

		--not psx... only iso/cso/hb/psp psn
		if driver then
			buttons.read()
			local vbuff = screen.toimage()
			while true do
				--buttons.homepopup(0)
				buttons.read()
				if vbuff then vbuff:blit(0,0) elseif back then back:blit(0,0) end

				local title = string.format("Driver Options")
				local w,h = screen.textwidth(title,1) + 110,115
				local x,y = 480 - (w/2), 272 - (h/2)

				draw.fillrect(x, y, w, h, color.new(0x2f,0x2f,0x2f,0xff))
					screen.print(480, y+5, title,1,color.white,color.black, __ACENTER)
					screen.print(480,y+35,SYMBOL_CROSS.." INFERNO",1,color.white,color.black, __ACENTER)
					screen.print(480,y+55,SYMBOL_TRIANGLE.." MARCH33",1,color.white,color.black, __ACENTER)
					screen.print(480,y+75,SYMBOL_CIRCLE.." NP9660",1,color.white,color.black, __ACENTER)
				screen.flip()

				if buttons.released.cross or buttons.released.circle or buttons.released.triangle then break end
			end--while

			if buttons.released.cross then         -- Press X
				fp:write("INFERNO".."\n")
			elseif buttons.released.triangle then   -- Press △
				fp:write("MARCH33".."\n")
			elseif buttons.released.circle then      -- Press O
				fp:write("NP9660".."\n")
			end
			buttons.read()--fflush

			--Boot mode bin
			while true do
				--buttons.homepopup(0)
				buttons.read()
				if vbuff then vbuff:blit(0,0) elseif back then back:blit(0,0) end

				local title = string.format("Extra Options")
				local w,h = screen.textwidth(title,1) + 125,130
				local x,y = 480 - (w/2), 272 - (h/2)

				draw.fillrect(x, y, w, h, color.new(0x2f,0x2f,0x2f,0xff))
					screen.print(480, y+8, title,1,color.white,color.black, __ACENTER)
					screen.print(480,y+40,SYMBOL_CROSS.." EBOOT.BIN",1,color.white,color.black, __ACENTER)
					screen.print(480,y+60,SYMBOL_TRIANGLE.." EBOOT.OLD",1,color.white,color.black, __ACENTER)
					screen.print(480,y+80,SYMBOL_CIRCLE.." BOOT.BIN",1,color.white,color.black, __ACENTER)
				screen.flip()

				if buttons.released.cross or buttons.released.circle or buttons.released.triangle then break end
			end

			-- Press X/△
			if buttons.released.cross then         -- Press X
				fp:write("EBOOT.BIN".."\n")
			elseif buttons.released.triangle then   -- Press △
				fp:write("EBOOT.OLD".."\n")
			elseif buttons.released.circle then      -- Press O
				fp:write("BOOT.BIN".."\n")
			end

		else
			--Inferno and eboot.bin (default)
			fp:write("INFERNO".."\n")
			fp:write("EBOOT.BIN".."\n")
		end--driver

		--PLUGINS ENABLE (default)
		fp:write("ENABLE".."\n")

		--STARDAT.PNG (default)
		fp:write("ENABLE".."\n")

		--Close
		fp:close()

		-- PIC1.PNG
		if pic then
			if pic:getw() != 480 or pic:geth() != 272 then
				local picscaled = image.copyscale(pic, 480,272)
				image.save(picscaled, ADRBUBBLESDB..id..".PNG")
			else
				image.save(pic, ADRBUBBLESDB..id..".PNG")
			end
		else
			files.copy("adrbblbooter/STARDAT.PNG", ADRBUBBLESDB)
			if files.exists(ADRBUBBLESDB..id..".PNG") then files.delete(ADRBUBBLESDB..id..".PNG") end
			files.rename(ADRBUBBLESDB.."STARDAT.PNG",id..".PNG")
			os.message("No PIC1.PNG was found, you can manually place your\n\n                              "
                  ..id..".PNG\n\n                       "..ADRBUBBLESDB)
		end

		--Update Tai Config
		tai.del(id,NOSTARTDAT)--old versions
		tai.del(id,ADRBBLBOOTER)
		tai.del(id,ADRENALINE)

		tai.put(id,ADRBBLBOOTER)
		tai.put(id,ADRENALINE)
		tai.sync()
		
	end--fp

	-- clean old files
	files.delete(work_dir)

	if os.message("Would you like to MOD another bubble ?",1) == 0 then
		if PowerReset then RestartV() end
	end

	ForceReload()

end

function bubbles.selection(obj,driver)

	buttons.interval(10,10)

	local vbuff = screen.toimage()
	local scroll = newScroll(bubbles.list, 16)
	local xscr = 830 - 144
	while true do
		--buttons.homepopup(0)
		buttons.read()
		if vbuff then vbuff:blit(0,0) end

		draw.fillrect(120,64,720,416, color.new(105,105,105,230))--0x64545353)--color.shadow)
		draw.rect(120,64,720,416,color.blue)

		screen.print(480,66,"Bubbles Availables", 1, color.white, color.blue, __ACENTER)
		screen.print(830,64,"Count: " + bubbles.len, 1, color.red, color.gray, __ARIGHT)

		if scroll.maxim > 0 then

			local py = 84
			if bubbles.list[scroll.sel].icon then
				bubbles.list[scroll.sel].icon:center()
				bubbles.list[scroll.sel].icon:blit(830 - 72, py + bubbles.list[scroll.sel].icon:geth()/2)
				py += bubbles.list[scroll.sel].icon:geth()
			else
				draw.fillrect(830 - 144, py, 144, 80, color.shine)
				draw.rect(830 - 144, py, 144, 80, color.black)
				py += 80
			end

			screen.print(830 - 72, py, bubbles.list[scroll.sel].id or "unk", 1, color.white,color.blue,__ACENTER)
			py += 20

			if bubbles.list[scroll.sel].picon then
				bubbles.list[scroll.sel].picon:center()
				bubbles.list[scroll.sel].picon:blit(830 - 72, py + bubbles.list[scroll.sel].picon:geth()/2)
				py += bubbles.list[scroll.sel].picon:geth()
			end

			if screen.textwidth(bubbles.list[scroll.sel].ptitle or "") > 144 then
				xscr = screen.print(xscr, py, bubbles.list[scroll.sel].ptitle or "",1,color.white,color.blue,__SLEFT,144)
			else
				screen.print(830 - 72, py, bubbles.list[scroll.sel].ptitle or "",1,color.white,color.blue,__ACENTER)
			end

			local y = 90
			for i=scroll.ini, scroll.lim do

				if i == scroll.sel then draw.fillrect(130,y-1,551,18,color.green) end

				screen.print(140,y,bubbles.list[i].id or "unk",1.0,color.white,color.blue,__ALEFT)
				if bubbles.list[i].clon then screen.print(275,y,"©",1.0,color.green,color.blue,__ALEFT) end
				if bubbles.list[i].dds_png then screen.print(302,y,"D",1.0,color.green,color.blue,__ALEFT) end
				screen.print(335,y,bubbles.list[i].title or "unk",1.0,color.white,color.blue,__ALEFT)

				y += 23
			end

			screen.print(480,460,"X: Select bubble | O: Cancel selection", 1, color.white, color.blue, __ACENTER)

		else
			screen.print(480,200,"No PSP content was found :( Try again later!", 1, color.white, color.red, __ACENTER)
		end

		screen.flip()

		if scroll.maxim > 0 then
			if (buttons.up or buttons.held.l or buttons.analogly < -60) then scroll:up() end
			if (buttons.down or buttons.held.r or buttons.analogly > 60) then scroll:down() end

			if buttons.cross then
				kick=true
					bubbles.install(obj, bubbles.list[scroll.sel],driver)
				kick=false
				return true
			end

		end

		if buttons.circle then
			return false
		end

	end
end
