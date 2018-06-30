--[[ 
	Adrenaline Bubble Manager VPK.
	Create and organize your direct adrenaline bubbles.
	
	Licensed by GNU General Public License v3.0
	
	Designed By:
	- Gdljjrod (https://twitter.com/gdljjrod).
	- DevDavisNunez (https://twitter.com/DevDavisNunez).
]]

--Show splash ...
splash.zoom("resources/splash.png")

dofile("crc.lua")
dofile("system/commons.lua")
dofile("system/callbacks.lua")

if os.access() == 0 then
	if back2 then back2:blit(0,0) end
	screen.flip()
	os.message(strings.unsafe)
	os.exit()
end

dofile("git/shared.lua")
if __UPDATE == 1 then
	local wstrength = wlan.strength()
	if wstrength then
		if wstrength > 55 then dofile("git/updater.lua") end
	end
end

ADRENALINE = "ux0:app/PSPEMUCFW"
ADRENALINEB = ADRENALINE.."/sce_module/adrbubblebooter.suprx"
ADRENALINEK = ADRENALINE.."/sce_module/adrenaline_kernel.skprx"
ADRENALINEU = ADRENALINE.."/sce_module/adrenaline_user.suprx"
ADRENALINEV = ADRENALINE.."/sce_module/adrenaline_vsh.suprx"
oncopy = false

if game.exists("PSPEMUCFW") and files.exists(ADRENALINE) and
	files.exists(ADRENALINE.."/eboot.bin") and files.exists(ADRENALINE.."/eboot.pbp") then

	if __CHECKADR == 1 then
		if not files.exists(ADRENALINEB) then
			oncopy = true
			files.copy("sce_module/", ADRENALINE)

		else

			if not files.exists(ADRENALINEB) then
				oncopy = true
				files.copy("sce_module/adrbubblebooter.suprx", ADRENALINE.."/sce_module/")
			else
				if os.crc32(files.read(ADRENALINEB) ) != __CRCADRBOOTER then
					oncopy = true
					files.copy("sce_module/adrbubblebooter.suprx", ADRENALINE.."/sce_module/")
				end
			end

			if not files.exists(ADRENALINEK) then
				oncopy = true
				files.copy("sce_module/adrenaline_kernel.skprx", ADRENALINE.."/sce_module/")
			else
				if os.crc32(files.read(ADRENALINEK) ) != __CRCKERNEL then
					oncopy = true
					files.copy("sce_module/adrenaline_kernel.skprx", ADRENALINE.."/sce_module/")
				end
			end

			if not files.exists(ADRENALINEU) then
				oncopy = true
				files.copy("sce_module/adrenaline_user.suprx", ADRENALINE.."/sce_module/")
			else
				if os.crc32(files.read(ADRENALINEU)) != __CRCUSER then
					oncopy = true
					files.copy("sce_module/adrenaline_user.suprx", ADRENALINE.."/sce_module/")
				end
			end

			if not files.exists(ADRENALINEV) then
				oncopy = true
				files.copy("sce_module/adrenaline_vsh.suprx", ADRENALINE.."/sce_module/")
			else
				if os.crc32(files.read(ADRENALINEV)) != __CRCVSH then
					oncopy = true
					files.copy("sce_module/adrenaline_vsh.suprx", ADRENALINE.."/sce_module/")
				end
			end
		end

		if oncopy then
			if back2 then back2:blit(0,0) end
			screen.flip()
			os.message(strings.adrinst)
			os.delay(500)
		end

	end--__CHECKADR

	if oncopy then

		--Make Bubbles compatible with new boot.bin
		local list = game.list(__GAME_LIST_APP)
		table.sort(list ,function (a,b) return string.lower(a.id)<string.lower(b.id) end)

		oncopy = false
		for i=1, #list do
			
			if files.exists(list[i].path.."/data/boot.inf") then
				if not files.exists(list[i].path.."/data/boot.bin") then
				
					if back2 then back2:blit(0,0) end
					message_wait(strings.upd_bubbles..list[i].id)
					os.delay(50)

					local path_game = ini.read(list[i].path.."/data/boot.inf", "PATH", "ENABLE")

					---searching game in partitions ux0
					local partitions = { "ux0:", "uma0:", "ur0:", "imc0:", }
					local path2game, _find = "", false
					for j=1, #partitions do
						path2game = path_game:gsub("ms0:/", partitions[j].."pspemu/")
						if files.exists(path2game) then _find=true break end
					end

					local drivers = { "ENABLE", "INFERN0", "MARCH", "NP9660", }--0,0, 1,2
					local bins = { "ENABLE", "EBOOT.BIN", "EBOOT.OLD", "BOOT.BIN", }--0,0 1,2
					
					local driver = ini.read(list[i].path.."/data/boot.inf", "DRIVER", "ENABLE")
					local bin = ini.read(list[i].path.."/data/boot.inf", "EXECUTE", "ENABLE")

					--Fill boot.bin
					if _find then

						files.copy("bubbles/pspemuxxx/data/boot.bin",list[i].path.."/data/")

						local fp = io.open(list[i].path.."/data/boot.bin", "r+")
						if fp then
							local number = 0
							
							--Driver
							fp:seek("set",0x04)
							for y=1,#drivers do
								if driver:upper() == drivers[y] then
									if y == 1 then number = 0 else number = y - 2 end
									break
								end
							end
							fp:write(int2str(number))

							--Execute
							fp:seek("set",0x08)
							number = 0
							for y=1,#bins do
								if bin:upper() == bins[y] then
									if y == 1 then number = 0 else number = y - 2 end
									break
								end
							end
							fp:write(int2str(number))

							--Customized
							fp:seek("set",0x0C)
							fp:write(int2str(0))

							--Path 2 game
							fp:seek("set",0x20)
							local fill = 256 - #path2game
							for y=1,fill do
								path2game = path2game..string.char(00)
							end
							fp:write(path2game)

							--Close
							fp:close()

						end--fp
					end--find

				end
			end
		end--for
		power.restart()
	end

	dofile("system/stars.lua")
	dofile("system/scan.lua")
	dofile("system/bubbles.lua")

	os.cpu(444)
		bubbles.scan()
		scan.games()
	os.cpu(333)
	scan.show()

else
	os.message(strings.notadr)
end
