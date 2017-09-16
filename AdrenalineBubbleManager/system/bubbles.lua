--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

-- src = objet game to launch
function bubbles.install(src, driver)

	files.delete("ux0:data/ABMVPK/")

	game.close()
	os.message("Getting the resources ready for your new bubble")

	local i=0
	while game.exists(string.format("%s%03d",string.sub("PSPEMU00",1,-3),i)) do
		i+=1
	end
	local lastid = string.format("%s%03d",string.sub("PSPEMU00",1,-3),i)

	local work_dir = "ux0:data/ABMVPK/"
	if not files.exists(work_dir) then files.mkdir(work_dir) end
	local work_res = "ux0:data/ABMVPK/"..lastid.."/resources/"

	if files.exists(work_dir+lastid) then files.delete(work_dir+lastid) end
	files.copy("system/pspemuxxx",work_dir)
	files.rename(work_dir.."pspemuxxx", lastid)
	work_dir += lastid.."/"
	os.message("TITLEID: "..lastid)

	local bubble_title,info_sfo = nil, game.info(src.path)
	if info_sfo then
		bubble_title = osk.init("Bubble's Title", info_sfo.TITLE or "Put here name", 1, 128)
	end
	if not bubble_title then bubble_title = src.name end

	--Resources
	if files.type(src.path) == 1 then
		game.unpack(src.path, work_res)
		if files.exists(work_res.."DATA.PSP")	then files.delete(work_res.."DATA.PSP")		end
		if files.exists(work_res.."PARAM.SFO")	then files.delete(work_res.."PARAM.SFO")	end
		if files.exists(work_res.."PIC0.PNG")	then files.delete(work_res.."PIC0.PNG")		end
		if files.exists(work_res.."ICON1.PMF")	then files.delete(work_res.."ICON1.PMF")	end
		if files.exists(work_res.."ICON1.PNG")	then files.delete(work_res.."ICON1.PNG")	end
		if files.exists(work_res.."SND0.AT3")	then files.delete(work_res.."SND0.AT3")		end
	else
		local icon = game.geticon0(src.path)
		if icon then image.save(icon, work_res.."ICON0.PNG") end
		icon = game.getpic1(src.path)
		if icon then image.save(icon, work_res.."PIC1.PNG") end
	end

	-- Set SFO & TITLE
	if files.exists(work_dir.."sce_sys/PARAM.SFO") then
		game.setsfo(work_dir.."sce_sys/PARAM.SFO", "STITLE", tostring(bubble_title), 0)
		game.setsfo(work_dir.."sce_sys/PARAM.SFO", "TITLE", tostring(bubble_title), 0)
		game.setsfo(work_dir.."sce_sys/PARAM.SFO", "TITLE_ID", tostring(lastid), 0)
	end

	---boot.inf
	val=5
	if src.path:sub(1,2) != "um" then val=4 end
	local path2game = src.path:gsub(src.path:sub(1,val).."pspemu/", "ms0:/")

	--Path ISO/CSO/PBP
	ini.write(work_dir.."data/boot.ini","PATH",path2game)

	local mode_driver = "INFERNO"
	local mode_execute = "EBOOT.BIN"

	--not psx... only iso/cso/hb/psp psn
	if driver then
		buttons.read()
		local vbuff = screen.toimage()
		while true do
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

			--if buttons.released.cross or buttons.released.circle or buttons.released.triangle then break end
			if buttons.released.cross then mode_driver = "INFERNO" break
			elseif buttons.released.triangle then mode_driver = "MARCH33" break
			elseif buttons.released.circle then mode_driver = "NP9660" break end
		end--while

		buttons.read()--fflush
		os.delay(2000)

		--Boot mode bin
		while true do
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

			if buttons.released.cross then mode_execute = "EBOOT.BIN" break
			elseif buttons.released.triangle then mode_execute = "EBOOT.OLD" break
			elseif buttons.released.circle then mode_execute = "BOOT.BIN" break end
		end

	end--driver

	ini.write(work_dir.."data/boot.ini","DRIVER",mode_driver)
	ini.write(work_dir.."data/boot.ini","EXECUTE",mode_execute)

	--PLUGINS ENABLE (default)
	ini.write(work_dir.."data/boot.ini","PLUGINS","ENABLE")

	--Update boot.ini to boot.inf
	if files.exists(work_dir.."data/boot.inf") then
		files.delete(work_dir.."data/boot.inf")
	end
	files.rename(work_dir.."data/boot.ini","boot.inf")

	--Install Bubble
	if game.installdir(work_dir) == 1 then
		os.message("Bubble Installed...Updating resources")
		update_resources(lastid, false)
	else
		os.message("Sorry, there was an instalation error")
	end
	----------------------------------------------------------------------------------------------------------------------------
	files.delete("ux0:data/ABMVPK/")

	if os.message("Would you like to Create Another Bubble ?",1) == 0 then
		if PowerReset then RestartV() end
	end

end
