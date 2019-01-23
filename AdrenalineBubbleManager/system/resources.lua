--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

__PATH_TMP = "ux0:data/ABM/tmp/"
__PATH_RESOURCES = "ux0:ABM/"
files.mkdir(__PATH_TMP)
APP_REPO = "ONElua"
APP_PROJECT = "VitaBubbles"

BUBBLES_PORT_I = channel.new("BUBBLES_PORT_I")
BUBBLES_PORT_O = channel.new("BUBBLES_PORT_O")
THID_THEME = thread.new("system/thread_bubbles.lua")

pic_alpha = 0

function bubbles.online(obj, simg)

	local list,maxim,xscr1,xscr2 = {},10,705,705

	local mge = BUBBLES_NOTRESOURCES

	local path_json = "https://raw.githubusercontent.com/%s/%s/master/database.json"
	local onNetGetFileOld = onNetGetFile; onNetGetFile = nil
	local raw = http.get(string.format(path_json, APP_REPO, APP_PROJECT))
	local url = "https://raw.githubusercontent.com/ONElua/VitaBubbles/master/"
	
	if raw then
		local not_err = true
		not_err, list = pcall(json.decode, raw)
		if not_err then
			if list then
				for i=1,#list do
					if not files.exists(__PATH_TMP..list[i].id..".png") then
						BUBBLES_PORT_O:push({ id = list[i].id })
					end
				end
			end
		else
			mge = STRINGS_RESOURCES_ERROR_DECODE
		end
	else
		mge = STRINGS_RESOURCES_ERROR_BASE
	end
	onNetGetFile = onNetGetFileOld
	os.delay(50)

	if #list > 1 then table.sort(list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end) end

	local scroll = newScroll(list, maxim)

	local preview = nil
	buttons.interval(12,5)
	while true do
		buttons.read()

		if back2 then back2:blit(0,0) end
		if math.minmax(tonumber(os.date("%d%m")),2512,2512)== tonumber(os.date("%d%m")) then stars.render() end

		screen.print(480,5,STRINGS_RESOURCES_ONLINE,1,color.green,color.gray,__ACENTER)
		screen.print(950,5,scroll.maxim, 1, color.red, color.shine, __ARIGHT)

		if scroll.maxim > 0 then

			local y = 70
			for i=scroll.ini,scroll.lim do
				if i == scroll.sel then

					if not preview then

						if pic_alpha < 255 then
							pic_alpha += 02
							if not angle then angle = 0 end
							angle += 20
							if angle > 360 then angle = 0 end
							draw.framearc(825, 145, 20, color.shine:a(125), 0, 360, 20, 30)
							draw.framearc(825, 145, 20, color.gray:a(200), angle, 90, 20, 30)--gira
						else
							pic_alpha = 0
						end

						preview = image.load(__PATH_TMP..list[i].id..".png")
						if preview then preview:resize(200,128)	end
					end

					screen.print(700+128, 230, "' "..STRINGS_RESOURCES_AUTHOR.." '",1,color.green:a(200),color.gray,__ACENTER)
					if screen.textwidth(list[i].author or "unk") > 255 then
						xscr1 = screen.print(xscr1, 250, list[i].author or "unk",1,color.white,color.gray,__SLEFT,250)
					else
						screen.print(700+128, 250, list[i].author or "unk",1,color.white,color.gray,__ACENTER)
					end

					screen.print(700+128, 290, "' "..STRINGS_RESOURCES_ID.." '",1,color.green:a(200),color.gray,__ACENTER)
					if screen.textwidth(list[i].author or "unk") > 255 then
						xscr2 = screen.print(xscr2, 310, list[i].id or "unk",1,color.white,color.gray,__SLEFT,250)
					else
						screen.print(700+128, 310, list[i].id or "unk",1,color.white,color.gray,__ACENTER)
					end

					draw.fillrect(5,y-3,680,25,color.shine)
				end
				screen.print(20,y,list[i].title,1,color.white,color.black)
				y+=26
			end

			draw.fillrect(720,80, 210,138, color.shine)
			if preview then	preview:blit(700+25,85) end

		else
			screen.print(480,230, mge, 1, color.white, color.red, __ACENTER)
		end

		local x1 = screen.print(15,430, BUBBLES_EDIT_BB, 1, color.white, color.blue, __ALEFT)
			screen.print(15,455, obj.id, 1, color.white, color.blue, __ALEFT)
		local x2 = screen.print(15,490, obj.title, 1, color.white, color.blue, __ALEFT)

		if simg then
			local px = x1
			if x1 > x2 then px = x1 + 100 else px = x2 + 100 end
			screen.clip(px,450, 120/2)
				simg:center()
				simg:blit(px,450)
			screen.clip()
		end
		screen.print(480,523, SYMBOL_BACK..": "..BUBBLES_GOTOBACK, 1, color.white, color.blue, __ACENTER)
		draw.fillrect(0,516,960,30, 0x64545353)--Down

		screen.flip()

		if scroll.maxim > 0 then

			if buttons.up or buttons.analogly < -60 then
				if scroll:up() then xscr1,xscr2 = 705,705
					pic_alpha = 0
					if preview then preview = nil end
				end
			end
			if buttons.down or buttons.analogly > 60 then
				if scroll:down() then xscr1,xscr2 = 705,705
					pic_alpha = 0
					if preview then preview = nil end
				end
			end

			if buttons[accept] then

				local vbuff = screen.toimage()
				if vbuff then vbuff:blit(0,0) elseif back then back:blit(0,0) end
				message_wait()
				os.delay(15)

				local url_bubbles = string.format("https://raw.githubusercontent.com/%s/%s/master/%s.zip", APP_REPO, APP_PROJECT, list[scroll.sel].id)
				local path = string.format(__PATH_TMP.."%s.zip", list[scroll.sel].id)
				if http.getfile(url_bubbles, path) then
					if files.extract(path, __PATH_RESOURCES) == 1 then
						mge = STRINGS_RESOURCES_INSTALLED
					else
						mge = STRINGS_RESOURCES_ERROR_UNPACK
					end
					files.delete(path)
				else
					mge = STRINGS_RESOURCES_ERROR_DOWNLOAD
				end

				os.message(tostring(mge))
			end
		end

		if buttons.released[cancel] then
			buttons.read()
			collectgarbage("collect")
			os.delay(150)
			break
		end
	
	end--while
end

