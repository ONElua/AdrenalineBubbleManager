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
PROJECT_BUBBLES = "VitaBubbles"

--BUBBLES_PORT_I = channel.new("BUBBLES_PORT_I")
--BUBBLES_PORT_O = channel.new("BUBBLES_PORT_O")
--THID_THEME = thread.new("system/thread_bubbles.lua")
local urlb = 'https://raw.githubusercontent.com/ONElua/VitaBubbles/master/'

pic_alpha,sorting = 0,0
function bubbles.online(obj, simg)

	local mge = BUBBLES_NOTRESOURCES
			files.delete("ux0:data/ABM/NEWdatabase.json")
	local path_json = "https://raw.githubusercontent.com/%s/%s/master/NEWdatabase.json"
	local onNetGetFileOld = onNetGetFile; onNetGetFile = nil

	local raw = nil
	if not listbubbles then

		listbubbles = {}
		authors = {}
		if __ITLS then
			raw = http.get(string.format(path_json, APP_REPO, PROJECT_BUBBLES))
		else
			files.delete("ux0:data/ABM/NEWdatabase.json")
			http.download(string.format(path_json, APP_REPO, PROJECT_BUBBLES), "ux0:data/ABM/NEWdatabase.json")
			if files.exists("ux0:data/ABM/NEWdatabase.json") then raw = files.read("ux0:data/ABM/NEWdatabase.json") end
		end

		--Parsing JSON
		if raw then
			local not_err,supertb = true,{}
			not_err, supertb = pcall(json.decode, raw)
			if not_err then
				if supertb then
					local list = supertb["content"]
					authors = supertb["authors"]
					if #list > 1 then table.sort(list ,function (a,b) return string.lower(a.title)<string.lower(b.title) end) end
					if #authors > 1 then table.sort(authors, function (a,b) return string.lower(a)<string.lower(b) end) end

					for i=1,#authors do
						listbubbles[i] = {}
					end

					for i=1,#list do
						for j=1,#authors do
							if (string.lower(list[i].author) == string.lower(authors[j])) then
								table.insert(listbubbles[j],list[i])
								listbubbles.total = #list
							end
						end
					end

				end
			else
				mge = STRINGS_RESOURCES_ERROR_DECODE
			end
		else
			mge = STRINGS_RESOURCES_ERROR_BASE
		end

	end--not listbubbles
	onNetGetFile = onNetGetFileOld

	local maxim,xscr1,xscr2,xscr3,sel = 10,25,720,30,1
	--Scrolls
	if #authors > 0 then
		for i=1,#authors do
			listbubbles[i].scroll = newScroll(listbubbles[i],maxim)
		end
	else
		listbubbles[sel] = {}
		listbubbles[sel].scroll = newScroll(listbubbles[sel],maxim)
	end

	local onNetGetFileOld = onNetGetFile; onNetGetFile = nil
	--Get previews
	if #listbubbles[sel] > 0 then
		for i=1,#listbubbles[sel] do
			power.tick(__POWER_TICK_ALL)

			if back2 then back2:blit(0,0) end
			message_wait(STRINGS_RESOURCES_ONLINE.."\n\n         "..i.."/"..#listbubbles[sel])

			if listbubbles[sel][i].icon0 then
				if not files.exists(__PATH_TMP..listbubbles[sel][i].icon0) then
					http.download(urlb..listbubbles[sel][i].icon0, __PATH_TMP..listbubbles[sel][i].icon0)
				--	BUBBLES_PORT_O:push({ icon0 = listbubbles[sel][i].icon0, itls = tostring(__ITLS) })
				end
				listbubbles[sel][i].preview = image.load(__PATH_TMP..listbubbles[sel][i].icon0)
				if listbubbles[sel][i].preview then
					--listbubbles[sel][i].preview:resize(200,128)
					listbubbles[sel][i].preview:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
				end
			end

		end
	end
	onNetGetFile = onNetGetFileOld
	os.delay(25)

	buttons.interval(12,5)
	while true do
		buttons.read()

		if back2 then back2:blit(0,0) end
		if snow then stars.render() end

		screen.print(480,5,STRINGS_RESOURCES_ONLINE,1,color.red, color.shine,__ACENTER)

		if listbubbles[sel].scroll.maxim > 0 then

			screen.print(950,5,listbubbles[sel].scroll.maxim.."/"..listbubbles.total, 1, color.red, color.shine, __ARIGHT)
			screen.print(10,5, sel.."/"..#authors, 1, color.yellow:a(200),color.gray, __ALEFT)

			if screen.textwidth(STRINGS_RESOURCES_AUTHOR.." : "..listbubbles[sel][listbubbles[sel].scroll.sel].author) > 715 then
				xscr1 = screen.print(xscr1, 35,STRINGS_RESOURCES_AUTHOR.." : "..listbubbles[sel][listbubbles[sel].scroll.sel].author,1,color.yellow:a(200),color.gray,__SLEFT,700)
			else
				screen.print(25, 35,STRINGS_RESOURCES_AUTHOR.." : "..listbubbles[sel][listbubbles[sel].scroll.sel].author,1,color.yellow:a(200),color.gray,__ALEFT)
			end

			local y = 76
			for i=listbubbles[sel].scroll.ini,listbubbles[sel].scroll.lim do

				if i == listbubbles[sel].scroll.sel then draw.fillrect(13,y-4,702,26,color.shine) end

				screen.clip(0,32,710,390)
					if files.exists(__PATH_RESOURCES..listbubbles[sel][i].id) then colora = color.green else colora = color.white end

					if i == listbubbles[sel].scroll.sel then

						if screen.textwidth(listbubbles[sel][i].title) > 600 then
							xscr3 = screen.print(xscr3, y, listbubbles[sel][i].title, 1, colora, color.gray, __SLEFT, 680)
						else
							screen.print(28,y, listbubbles[sel][i].title, 1, colora, color.gray)
						end
					else
						screen.print(28,y, listbubbles[sel][i].title, 1, colora, color.gray)
					end

					if listbubbles[sel][i].update then screen.print(17,y,'*',1,color.green,color.shine:a(135)) end
				screen.clip()

				y+=30

			end--for

			draw.fillrect(720,70, 138,138, color.shine)--210,138, color.shine)
			if listbubbles[sel][listbubbles[sel].scroll.sel].preview then
				listbubbles[sel][listbubbles[sel].scroll.sel].preview:blit(700+25,75)
			else
				if pic_alpha < 255 then
					pic_alpha += 02
					if not angle then angle = 0 end
					angle += 20
					if angle > 360 then angle = 0 end
					draw.framearc(790, 140, 20, color.shine:a(125), 0, 360, 20, 30)
					draw.framearc(790, 140, 20, color.gray:a(200), angle, 90, 20, 30)--gira
				else
					pic_alpha = 0
				end
			end

			screen.print(915, 125, listbubbles[sel].scroll.sel.."/"..listbubbles[sel].scroll.maxim,1,color.white,color.gray,__ACENTER)

			--Blit Info
			screen.print(700+128, 220, "' "..STRINGS_RESOURCES_ID.." '",1,color.green:a(200),color.gray,__ACENTER)
			if screen.textwidth(listbubbles[sel][listbubbles[sel].scroll.sel].id or "unk") > 215 then
				xscr2 = screen.print(xscr2, 240, listbubbles[sel][listbubbles[sel].scroll.sel].id or "unk",1,color.white,color.gray,__SLEFT,205)
			else
				screen.print(700+128, 240, listbubbles[sel][listbubbles[sel].scroll.sel].id or "unk",1,color.white,color.gray,__ACENTER)
			end

			screen.print(700+128, 280, "' "..STRINGS_RESOURCES_MANUAL.." '",1,color.green:a(200),color.gray,__ACENTER)
			if listbubbles[sel][listbubbles[sel].scroll.sel].manual then
				screen.print(700+128, 300, STRINGS_OPTION_MSG_YES,1,color.white,color.gray,__ACENTER)
			else
				screen.print(700+128, 300, STRINGS_OPTION_MSG_NO,1,color.white,color.gray,__ACENTER)
			end

			--Bar Scroll
			local ybar, h = 74, (maxim*30)-2
			draw.fillrect(3, ybar-2, 8, h, color.shine)
			local pos_height = math.max(h/listbubbles[sel].scroll.maxim, maxim)
			draw.fillrect(3, ybar-2 + ((h-pos_height)/(listbubbles[sel].scroll.maxim-1))*(listbubbles[sel].scroll.sel-1), 8, pos_height, color.new(0,255,0))

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

		--if buttons.select then error("FTP") end

		--Ctrls
		if listbubbles[sel].scroll.maxim > 0 then

			if buttons.released.left or buttons.released.right then

				--local vbuff = screen.buffertoimage()
				for i=1,#listbubbles[sel] do
					listbubbles[sel][i].preview = nil
				end
				collectgarbage("collect")
				os.delay(500)

				if buttons.released.left then sel -=1 else sel +=1 end
				if sel > #authors then sel = 1 end
				if sel < 1 then sel = #authors end

				if vbuff then vbuff:blit(0,0) elseif back2 then back2:blit(0,0) end
				message_wait()
				os.delay(50)

				pic_alpha,xscr1 = 0,25
				local onNetGetFileOld = onNetGetFile; onNetGetFile = nil
				if #listbubbles[sel] > 0 then
					for i=1,#listbubbles[sel] do
						power.tick(__POWER_TICK_ALL)

						if vbuff then vbuff:blit(0,0) elseif back2 then back2:blit(0,0) end
						message_wait(STRINGS_RESOURCES_ONLINE.."\n\n         "..i.."/"..#listbubbles[sel])

						if listbubbles[sel][i].icon0 then
							if not files.exists(__PATH_TMP..listbubbles[sel][i].icon0) then
								http.download(urlb..listbubbles[sel][i].icon0, __PATH_TMP..listbubbles[sel][i].icon0)
								--BUBBLES_PORT_O:push({ icon0 = listbubbles[sel][i].icon0, itls = tostring(__ITLS) })
							end
							listbubbles[sel][i].preview = image.load(__PATH_TMP..listbubbles[sel][i].icon0)
							if listbubbles[sel][i].preview then
								--if listbubbles[sel][i].preview:getrealw() != 128 and listbubbles[sel][i].preview:getrealw() != 128 then
								--	os.dialog(listbubbles[sel][i].icon0)idolmaster
								--end
								--listbubbles[sel][i].preview:resize(200,128)
								listbubbles[sel][i].preview:setfilter(__IMG_FILTER_LINEAR, __IMG_FILTER_LINEAR)
							end
						end

					end
				end
				onNetGetFile = onNetGetFileOld
			end

			if buttons.up or buttons.analogly < -60 then
				if listbubbles[sel].scroll:up() then xscr2,xscr3 = 720,30
					pic_alpha = 0
					
				end
			end
			if buttons.down or buttons.analogly > 60 then
				if listbubbles[sel].scroll:down() then xscr2,xscr3 = 720,30
					pic_alpha = 0
					
				end
			end

			if buttons.square then
				listbubbles[sel][listbubbles[sel].scroll.sel].update = not listbubbles[sel][listbubbles[sel].scroll.sel].update
			end

			if buttons.triangle then
				for i=1,#listbubbles do
					listbubbles[i].update = false
				end
			end

			if buttons.accept then

				listbubbles[sel][listbubbles[sel].scroll.sel].update = true

				local cont_resources = 0
				for i=1,#listbubbles[sel] do
					if listbubbles[sel][i].update then cont_resources += 1 end
				end
				TResources = cont_resources

				NResources = 0
				for i=1,#listbubbles[sel] do
					if listbubbles[sel][i].update then

						local url_bubbles = string.format("https://raw.githubusercontent.com/%s/%s/master/%s.zip", APP_REPO, PROJECT_BUBBLES, listbubbles[sel][i].id)
						local path = string.format(__PATH_TMP.."%s.zip", listbubbles[sel][i].id)

						bubble_id = listbubbles[sel][i].id
						NResources += 1
						iconpreview = image.load(__PATH_TMP..listbubbles[sel][i].icon0)
						--if iconpreview then iconpreview:resize(200,128) end

						if __ITLS then http.getfile(url_bubbles, path) else http.download(url_bubbles, path) end
						if files.exists(path) then
							if files.extract(path, __PATH_RESOURCES) == 1 then
								mge = listbubbles[sel][i].id..'\n\n'..STRINGS_RESOURCES_INSTALLED
							else
								mge = listbubbles[sel][i].id..'\n\n'..STRINGS_RESOURCES_ERROR_UNPACK
							end
						else
							mge = listbubbles[sel][i].id..'\n\n'..STRINGS_RESOURCES_ERROR_DOWNLOAD
						end
						--Clean
						files.delete(path)
						bubble_id,iconpreview = "",nil
						listbubbles[sel][i].update = nil

						if back2 then back2:blit(0,0) end
							message_wait(mge)
						os.delay(500)
						
					end
				end	--for list
				NResources, TResources = 0,0
				os.delay(500)
			end

		end

		if buttons.released.cancel then
			buttons.read()
			collectgarbage("collect")
			os.delay(500)
			break
		end
	
	end--while
end
