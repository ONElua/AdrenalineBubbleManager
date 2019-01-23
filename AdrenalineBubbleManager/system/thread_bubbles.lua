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
			if (not files.exists(PATH_PREVIEWS..entry.id..".png") and http.getfile(urlb..entry.id..".png", PATH_PREVIEWS.."tmpcover.png"))
					or (files.exists(PATH_PREVIEWS..entry.id..".png")) then
					files.rename(PATH_PREVIEWS.."tmpcover.png", entry.id..".png")
						break
			end
			os.delay(5)
		end
	end
	os.delay(5)
end

