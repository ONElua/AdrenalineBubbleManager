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
		while true do
			if (not files.exists(PATH_PREVIEWS..entry.id..".jpg") and http.download(urlb..entry.id..".jpg", PATH_PREVIEWS.."tmpcover.jpg").success)
					or (files.exists(PATH_PREVIEWS..entry.id..".jpg")) then
					files.rename(PATH_PREVIEWS.."tmpcover.jpg", entry.id..".jpg")
					break
			end
			--os.delay(5)
			os.delay(20)
		end
	end
	os.delay(25)
end
