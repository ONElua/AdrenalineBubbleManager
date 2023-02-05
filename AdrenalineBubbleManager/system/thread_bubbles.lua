--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By RG & Gdljjrod.
   
]]

PATH_PREVIEWS= "ux0:data/ABM/tmp/"

BUBBLES_PORT_O = channel.new("BUBBLES_PORT_I")
BUBBLES_PORT_I = channel.new("BUBBLES_PORT_O")

local urlb = 'https://raw.githubusercontent.com/ONElua/VitaBubbles/master/'
while true do
	if BUBBLES_PORT_I:available() > 0 then
		local entry = BUBBLES_PORT_I:pop()
		if entry.itls then
			while true do
				if (not files.exists(PATH_PREVIEWS..entry.icon0) and http.getfile(urlb..entry.icon0, PATH_PREVIEWS.."tmpcover"))
					or (files.exists(PATH_PREVIEWS..entry.icon0)) then
					files.rename(PATH_PREVIEWS.."tmpcover", entry.icon0)
					break
				end
--[[
				if (not files.exists(PATH_PREVIEWS..entry.id..".jpg") and http.getfile(urlb..entry.id..".jpg", PATH_PREVIEWS.."tmpcover.jpg"))
						or (files.exists(PATH_PREVIEWS..entry.id..".jpg")) then
					files.rename(PATH_PREVIEWS.."tmpcover.jpg", entry.id..".jpg")
					break
				end
]]
				--os.delay(5)
				os.delay(20)
			end

		else
			while true do
				if (not files.exists(PATH_PREVIEWS..entry.icon0) and http.download(urlb..entry.icon0, PATH_PREVIEWS.."tmpcover").success)
					or (files.exists(PATH_PREVIEWS..entry.icon0)) then
					files.rename(PATH_PREVIEWS.."tmpcover", entry.icon0)
					break
				end
--[[
				if (not files.exists(PATH_PREVIEWS..entry.id..".jpg") and http.download(urlb..entry.id..".jpg", PATH_PREVIEWS.."tmpcover.jpg").success)
						or (files.exists(PATH_PREVIEWS..entry.id..".jpg")) then
					files.rename(PATH_PREVIEWS.."tmpcover.jpg", entry.id..".jpg")
					break
				end
]]
				--os.delay(5)
				os.delay(20)
			end
		end
	end
	os.delay(25)
end
