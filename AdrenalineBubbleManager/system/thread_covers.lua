--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By RG & Gdljjrod.
   
]]

PATH_COVERS = "ux0:data/ABM/tmp/"

COVERS_PORT_O = channel.new("COVERS_PORT_I")
COVERS_PORT_I = channel.new("COVERS_PORT_O")

while true do
	if COVERS_PORT_I:available() > 0 then
		local entry = COVERS_PORT_I:pop()
		while true do
			if (not files.exists(PATH_COVERS..entry.id..".jpg") and
				http.getfile('https://raw.githubusercontent.com/ONElua/VitaBubbles/master/'..entry.id..".jpg", PATH_COVERS.."tmpcover.jpg"))
					or (files.exists(PATH_COVERS..entry.id..".jpg")) then
					files.rename(PATH_COVERS.."tmpcover.jpg", entry.id..".jpg")
						break
			end
			os.delay(5)
		end
	end
	os.delay(5)
end

