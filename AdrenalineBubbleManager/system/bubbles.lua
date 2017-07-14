--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltaR4 & Wzjk.
	
]]

NOSTARTDAT, YESSTARTDAT = "ux0:adrbblbooter/adrbblbooter_nostartdat.suprx", "ux0:adrbblbooter/adrbblbooter.suprx"
ADRENALINE = "ux0:adrenaline/adrenaline.suprx"
--ADRBUBBLESDB = "ux0:adrbblbooter/bubblesdb/"

-- Adrbblbooter v.04??
if not files.exists(ADRBUBBLESDB) then files.mkdir(ADRBUBBLESDB) end
files.copy("adrbblbooter/adrbblbooter_nostartdat.suprx", "ux0:adrbblbooter/")
files.copy("adrbblbooter/adrbblbooter.suprx", "ux0:adrbblbooter/")

bubbles = {}

function bubbles.load()
	bubbles.list = {}
	local list = game.list(__PSPEMU)
	local len = #list
	for i=1, len do
		local entry = {
			id = list[i].id, 														-- TITLEID of the game.
			path = list[i].path,													-- Path to the folder of the game.
			location = list[i].path:sub(1,4),										-- Location "ux0:" or "ur0:".
			flag = 1,																-- 0: ur0 / 1: ux0.
			icon = game.geticon0(string.format("%s/eboot.pbp", list[i].path)),		-- Icon of the Game Eboot.
			picon = game.geticon0(string.format("%s/pboot.pbp", list[i].path)),		-- Icon of the Game PBOOT (Only if exists!)
			ptitle = nil,															-- Title of the PBOOT (Only if exists!)
		}

		if entry.location == "ur0:" then entry.flag = 0 end

		if entry.picon then
			local pinfo = game.info(string.format("%s/pboot.pbp", entry.path))
			entry.ptitle = pinfo.TITLE												-- if exists then text else nil :D
		end

		local info = game.info(string.format("%s/eboot.pbp", entry.path))
		if info then
			if info.CATEGORY and info.CATEGORY == "EG" then
				local sceid = game.sceid(string.format("%s/__sce_ebootpbp",entry.path))
				if sceid and sceid != "---" and sceid != entry.id then
					entry.clon = true
				end
			end
			entry.title = info.TITLE or entry.id
		end

		table.insert(bubbles.list, entry)											-- Insert entry in list of bubbles! :)

	end

	bubbles.len = #bubbles.list
	if bubbles.len > 0 then
		table.sort(bubbles.list ,function (a,b) return string.lower(a.id)<string.lower(b.id) end)
	end

end

function bubbles.install(src, dst) -- src = objet game to launch - dst = gamebase.

	if files.exists(dst.path.."/PBOOT.PBP") then
		if os.message("PBOOT.PBP was found\n\nYou want to overwrite ?",1) == 0 then
			return
		end
	end

	local id = dst.id or (files.nopath(dst.path):gsub("/",""))

	-- Custom PBOOT
	local work_dir = "ux0:data/lmanbootr/"
	if not files.exists(work_dir) then files.mkdir(work_dir) end

	-- ICON0
	local icon = nil
	if files.type(src.path) == 1 then
		game.unpack(src.path, work_dir)
	else
		icon = game.geticon0(src.path)
		if icon then image.save(icon, work_dir.."ICON0.PNG") end
	end
	if not files.exists(work_dir.."ICON0.PNG") then	files.copy("pboot/ICON0.PNG",work_dir) end
	if not icon then image.load("pboot/ICON0.PNG") end

	files.copy("pboot/DATA.PSP",work_dir)
	files.copy("pboot/PARAM.SFO",work_dir)

	-- TITLE
	local bubble_title,info_sfo = nil, game.info(src.path)
	if info_sfo then
		bubble_title = osk.init("Bubble's Title", info_sfo.TITLE or "Put here name", 1, 128)
	end

	if not bubble_title then bubble_title = src.name end

	-- Set SFO
	game.setsfo(work_dir.."PARAM.SFO", "TITLE", tostring(bubble_title), 0)

	-- Pack all in a new PBOOT :D
	game.pack(work_dir)

	if files.exists(work_dir.."EBOOT.PBP") then

		files.rename(work_dir.."EBOOT.PBP","PBOOT.PBP")
		files.move(work_dir.."PBOOT.PBP", dst.path)

		--Refresh&Insert
		bubbles.load()
		--dst.picon = icon
		--dst.ptitle = bubble_title

		os.message("Custom PBOOT.PBP Done!!!")
		local fp = io.open(ADRBUBBLESDB..id..".txt", "w+")
		if fp then
			local path2game = src.path:gsub(src.path:sub(1,4).."pspemu/", "ms0:/")

			fp:write(path2game.."\n")
			
			--tmp0.CATEGORY: ISO/CSO UG, PSN EG, HBs MG, PS1 ME, PBOOT.PBP PG
			if info_sfo.CATEGORY == "UG" then
				if os.message("Would you like to use M33 Driver ??",1) == 1 then
					fp:write("MARCH33".."\n")

					buttons.read()
					local vbuff = screen.toimage()
					while true do
						buttons.read()
						if vbuff then vbuff:blit(0,0) elseif back then back:blit(0,0) end
						local title = string.format("Extra Options")
						local w,h = screen.textwidth(title,1) + 110,115
						local x,y = 480 - (w/2), 272 - (h/2)
						draw.fillrect(x, y, w, h, color.new(0x2f,0x2f,0x2f,0xff))
						screen.print(480, y+5, title,1,color.white,color.black, __ACENTER)
						screen.print(x+10,y+35,SYMBOL_CROSS.." BOOT.BIN")
						screen.print(x+10,y+55,SYMBOL_TRIANGLE.." EBOOT.OLD")
						screen.print(x+10,y+75,SYMBOL_CIRCLE.." Nothing")
						screen.flip()

						if buttons.released.cross or buttons.released.circle or buttons.released.triangle then
							break
						end
					end--while

					if buttons.released.cross then -- Press X
						fp:write("BOOT.BIN".."\n")
					elseif buttons.released.triangle then -- Press △
						fp:write("EBOOT.OLD".."\n")
					end
				end
			end--CAT
			fp:close()

			if files.exists(ADRBUBBLESDB..id..".txt") then
				local SUPRX = NOSTARTDAT
				if os.message("Would you like to use selected content's PIC1 as STARTDAT ??",1) == 1 then
					SUPRX = YESSTARTDAT
					-- PIC1
					local pic = game.getpic1(src.path)
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
						os.message("No PIC1.PNG was found, you can manually place your\n\n                              "..id..".PNG\n\n                       "..ADRBUBBLESDB)
					end
				end

				--Updata Tai Config
				--bubbles.tai(id)

				tai.del(id,NOSTARTDAT)
				tai.del(id,YESSTARTDAT)
				tai.del(id,ADRENALINE)
				tai.put(id,SUPRX)
				tai.put(id,ADRENALINE)
				tai.sync()

				if os.message("Would you like to mod another bubble ?",1) == 0 then
					-- clean old files
					files.delete(work_dir)
					UpdateDB()
				else
					ForceReset()
				end
			end

		end--fp
	end
	-- clean old files
	files.delete(work_dir)
end

function bubbles.selection(obj)

	buttons.interval(10,10)

	local vbuff = screen.toimage()
	local scroll = newScroll(bubbles.list, 16)
	local xscr = 830 - 144
	while true do

		buttons.read()
		if vbuff then vbuff:blit(0,0) end

		draw.fillrect(120,64,720,416, color.new(105,105,105,230))--0x64545353)--color.shadow)
		draw.rect(120,64,720,416,color.blue)

		screen.print(480,66,"Bubbles Availables", 1, color.white, color.blue, __ACENTER)
		screen.print(830,64,"Count: " + bubbles.len, 1, color.red, color.gray, __ARIGHT)

		if scroll.maxim > 0 then

			local py = 84
			if bubbles.list[scroll.sel].icon then
				--screen.clip(830-64,35+64, 128/2)
				bubbles.list[scroll.sel].icon:center()
				bubbles.list[scroll.sel].icon:blit(830 - 72, py + bubbles.list[scroll.sel].icon:geth()/2)
				--screen.clip()
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

				if bubbles.list[i].clon then screen.print(270,y,"©",1.0,color.white,color.blue,__ALEFT) end

				local ccolor = color.green
				if bubbles.list[i].flag == 0 then ccolor = color.yellow end

				screen.print(300,y,bubbles.list[i].location or "unk",1.0,ccolor,color.blue,__ALEFT)
				screen.print(360,y,bubbles.list[i].title or "unk",1.0,color.white,color.blue,__ALEFT)

				y += 23
			end

			screen.print(480,460,"X: Select bubble | O: Cancel selection", 1, color.white, color.blue, __ACENTER)

		else
			screen.print(480,200,"No PSP content was found :( Try again late!", 1, color.white, color.red, __ACENTER)
		end

		screen.flip()

		if scroll.maxim > 0 then
			if (buttons.up or buttons.held.l or buttons.analogly < -60) then scroll:up() end
			if (buttons.down or buttons.held.r or buttons.analogly > 60) then scroll:down() end

			if buttons.cross then
				bubbles.install(obj, bubbles.list[scroll.sel])
				return true
			end

		end

		if buttons.circle then
			return false
		end

	end
end

function bubbles.tai(id)
	local bubblesman = {
		cfg = {},					-- Have original state of file.
		list = {},					-- Handle list of plugins.
	}

	local path = "ux0:tai/config.txt"
	if not files.exists(path) then path = "ur0:tai/config.txt" end

	bubblesman.cfg = {} -- Set to Zero
	bubblesman.list = {} -- Set to Zero

	if files.exists(path) then
		local id_sect,i = nil, 1

		for line in io.lines(path) do

			table.insert(bubblesman.cfg,line)

			if line:find("*",1) then -- Section Found
				if line:sub(2) == id then
					id_sect = id
					if not bubblesman.list[id_sect] then bubblesman.list[id_sect] = {line = i, suprxline = line, dels=true } end
					table.insert(bubblesman.list[id_sect], {line = i, suprxline = line, dels=true })
				else
					id_sect = nil
				end
			else

				if id_sect then
					local tmp = line:gsub('#',''):lower()
					if tmp == NOSTARTDAT or tmp == YESSTARTDAT or tmp == ADRENALINE then
						table.insert(bubblesman.list[id_sect], {line = i, suprxline = line, dels=true })
					elseif line:sub(1,4) == "ux0:" or line:sub(1,4) == "ur0:" then
						table.insert(bubblesman.list[id_sect], {line = i, suprxline = line, dels=false })
					end
				end
			end

			i += 1
		end--for
	end

	if bubblesman.list[id] then
		for i=#bubblesman.list[id],1,-1 do
			table.remove(bubblesman.cfg, bubblesman.list[id][i].line)
		end

		local _write,countdels = true,0 
		for i=#bubblesman.list[id],1,-1 do
			if not bubblesman.list[id][i].dels then
				countdels += 1
				if _write then
					table.insert(bubblesman.cfg, "*"..id)
					table.insert(bubblesman.cfg, SUPRX)
					table.insert(bubblesman.cfg, ADRENALINE)
					_write = false
				end
				table.insert(bubblesman.cfg, bubblesman.list[id][i].suprxline)
			end
		end--for

		if countdels == 0 then
			table.insert(bubblesman.cfg, "*"..id)
			table.insert(bubblesman.cfg, SUPRX)
			table.insert(bubblesman.cfg, ADRENALINE)
		end
	else
			table.insert(bubblesman.cfg, "*"..id)
			table.insert(bubblesman.cfg, SUPRX)
			table.insert(bubblesman.cfg, ADRENALINE)
	end
	files.write(path, table.concat(bubblesman.cfg, '\n'))

end
