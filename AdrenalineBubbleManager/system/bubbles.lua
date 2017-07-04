--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
	http://creativecommons.org/licenses/by-sa/4.0/
	
	Designed By Gdljjrod & DevDavisNunez.
	Collaborators: BaltaR4 & Wzjk.
	
]]

__NOSTARTDAT, __YESSTARTDAT = "ux0:adrbblbooter/adrbblbooter_nostartdat.suprx", "ux0:adrbblbooter/adrbblbooter.suprx"
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
			--cat = "Unknow",
		}

		if entry.location == "ur0:" then entry.flag = 0; end

		if entry.picon then
			local pinfo = game.info(string.format("%s/pboot.pbp", entry.path));
			entry.ptitle = pinfo.TITLE;												-- if exists then text else nil :D
		end

		local info = game.info(string.format("%s/eboot.pbp", entry.path))
		if info then
			if info.CATEGORY and info.CATEGORY == "EG" then
				local sceid = game.sceid(string.format("%s/__sce_ebootpbp",entry.path))
				if sceid and sceid != "---" and sceid != entry.id then
					entry.clon = true
				end
			end
			entry.title = info.TITLE or entry.id;
			--entry.cat = info.CATEGORY or "Unknow";
		end

		table.insert(bubbles.list, entry);											-- Insert entry in list of bubbles! :)

	end

	bubbles.len = #bubbles.list
	if bubbles.len > 0 then
		table.sort(bubbles.list ,function (a,b) return string.lower(a.id)<string.lower(b.id); end)
	end

end

function bubbles.install(src, dst) -- src = game to launch - dst = gamebase.

	if files.exists(dst.path.."/PBOOT.PBP") then
		if os.message("PBOOT.PBP was found\n\nYou want to overwrite ?",1) == 0 then
			return
		end
	end

	local id = dst.id or (files.nopath(dst.path):gsub("/",""))

	-- Custom PBOOT
	local work_dir = "ux0:data/lmanbootr/"
	files.mkdir(work_dir)

	files.copy("pboot/DATA.PSP",work_dir)
	files.copy("pboot/PARAM.SFO",work_dir)
	files.copy("pboot/ICON0.PNG",work_dir)

	-- ICON0
	local icon = game.geticon0(src)
	if icon then image.save(icon, work_dir.."ICON0.PNG") end

	-- TITLE
	local bubble_title = nil
	local info_sfo = game.info(src)
	if info_sfo then
		bubble_title = osk.init("Titulo de la burbuja", info_sfo.TITLE or "Put here name", 1, 128)
	end
	if not bubble_title then bubble_title = "Put here name" end

	-- Set SFO
	game.setsfo(work_dir.."PARAM.SFO", bubble_title)

	-- Pack all in a new PBOOT :DATA
	game.pack(work_dir)

	if files.exists(work_dir.."EBOOT.PBP") then

		files.rename(work_dir.."EBOOT.PBP","PBOOT.PBP")
		files.move(work_dir.."PBOOT.PBP", dst.path)
		--print("PBOOT.PBP Done!!!\n")

		--Aqui insertar el nuevo icono y title del pboot en bubbles.list (asi como el bubbles.load)
		dst.picon = icon;
		dst.ptitle = bubble_title;
		--dst.cat = info_sfo.CATEGORY or "Unknow";
		
		-- Adrbblbooter ??
		if not files.exists("ux0:adrbblbooter/bubblesdb/") then files.mkdir("ux0:adrbblbooter/bubblesdb/") end
		if not files.exists(__NOSTARTDAT) then
			files.copy("adrbblbooter/adrbblbooter_nostartdat.suprx", __NOSTARTDAT)
		end
		if not files.exists(__YESSTARTDAT) then
			files.copy("adrbblbooter/adrbblbooter.suprx", __YESSTARTDAT)
		end

		local fp = io.open("ux0:adrbblbooter/bubblesdb/"..id..".txt", "w+");
		if fp then
			local path2game = src:gsub(src:sub(1,4).."pspemu/", "ms0:/")

			fp:write(path2game)
			fp:close()

			if files.exists("ux0:adrbblbooter/bubblesdb/"..id..".txt") then
				
				local plugin = {prxline = 0, sectln = 0}
				function plugin.check()

					local path = "ux0:tai/config.txt"
					if not files.exists(path) then path = "ur0:tai/config.txt" end
	
					plugin.cfg = {}
					plugin.state = false
					if files.exists(path) then
						local id_sect,i = false, 1

						for line in io.lines(path) do

							table.insert(plugin.cfg,line)
							
							if id_sect then
								if line:gsub('#',''):lower() == __NOSTARTDAT or line:gsub('#',''):lower() == __YESSTARTDAT then
									plugin.state = true;
									plugin.prxline = i
								end
							end
							
							if line:find("*",1) then -- Secction Found
								if line:sub(2) == id and not plugin.state then
									id_sect = true;
									plugin.sectln = i;
								else
									id_sect = false;
								end
							end
			
							i += 1
						end--for
					end
				end

				function plugin.set(state)
					local __SUPRX = __YESSTARTDAT
					if os.message("Would you like to disable the STARTDAT image \n\nat game start ??",1) == 1 then
						__SUPRX = __NOSTARTDAT
					end
					if state and not plugin.state then
						if plugin.sectln != 0 then
							table.insert(plugin.cfg, plugin.sectln+1, __SUPRX)
							table.insert(plugin.cfg, plugin.sectln+2, "ux0:adrenaline/adrenaline.suprx")
						else
							table.insert(plugin.cfg, "*"..id)
							table.insert(plugin.cfg, __SUPRX)
							table.insert(plugin.cfg, "ux0:adrenaline/adrenaline.suprx")
						end
						files.write("ux0:tai/config.txt", table.concat(plugin.cfg, '\n'))
						plugin.state = true
					end

					if not state and plugin.state then
						table.remove(plugin.cfg, plugin.prxline)
						--if not plugin.cfg[plugin.prxline]:sub(1,4) == "ux0:" then -- no have another prx in the secction...
							--table.remove(plugin.cfg, plugin.sectln)
						--end
						files.write("ux0:tai/config.txt", table.concat(plugin.cfg, '\n'))
						plugin.state = false
					end

				end

				plugin.check()
				plugin.set(true)
				
				-- clean old files
				files.delete(work_dir)
				if os.message("Would you like to mod anhoter bubble ?",1) == 0 then
					os.updatedb()
					os.message("Your PSVita will restart...\nand your database will be update")
					power.restart()
				else
					ForceReset()
				end
				--print("Restart! :D\n")
			end
		end--fp
	end

	--print("error\n")
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
			screen.print(480,200,"Not have any PSPEmu Game :( Try again late!", 1, color.white, color.red, __ACENTER)
		end

		screen.flip()

		if scroll.maxim > 0 then
			if (buttons.up or buttons.held.l or buttons.analogly < -60) then scroll:up() end
			if (buttons.down or buttons.held.r or buttons.analogly > 60) then scroll:down() end

			if buttons.cross then
				bubbles.install(obj.path, bubbles.list[scroll.sel])
				return true
			end

		end

		if buttons.circle then
			return false
		end

	end
end
