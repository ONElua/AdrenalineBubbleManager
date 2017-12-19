--[[ 
	Adrenaline Bubble Manager VPK.
	Create and organize your direct adrenaline bubbles.
	
	Licensed by GNU General Public License v3.0
	
	Designed By:
	- Gdljjrod (https://twitter.com/gdljjrod).
	- DevDavisNunez (https://twitter.com/DevDavisNunez).
]]

game.close()
color.loadpalette()

-- Set ux0 folder path
local pathABM = "ux0:data/ABM/"
files.mkdir(pathABM)
files.mkdir(pathABM.."lang/")
files.mkdir(pathABM.."resources/")

-- Loading custom GFX from ux0:data/ABM/resources if exist
-- Background image must be (960x554 png or jpg image. Priority to back.png)
if files.exists(pathABM.."resources/back.png") then back = image.load(pathABM.."resources/back.png")
	elseif files.exists(pathABM.."resources/back.jpg") then back = image.load(pathABM.."resources/back.jpg")
		else back = image.load("resources/back.png")
end

-- Popup message background (must be 706x274 png image)
if files.exists(pathABM.."resources/box.png") then box = image.load(pathABM.."resources/box.png")
else box = image.load("resources/box.png") end

-- Loading default GFX from app folder
buttonskey = image.load("resources/buttons.png",20,20)
buttonskey2 = image.load("resources/buttons2.png",30,20)

-- Loading language file
__LANG = os.language()
__STRINGS		= 55
-- reading lang strings from ux0:data/ABM/ if exist
if files.exists(pathABM.."lang/"..__LANG..".txt") then dofile(pathABM.."lang/"..__LANG..".txt")
else 
-- reading lang strings fom app folder if exist
	if files.exists("resources/lang/"..__LANG..".txt") then
		dofile("resources/lang/"..__LANG..".txt")
		local cont = 0
		for key,value in pairs(strings) do cont += 1 end
		if cont < __STRINGS then files.copy("resources/lang/english_us.txt",pathABM.."lang/") dofile("resources/lang/english_us.txt") end
-- reading default lang strings if no one translations founded
	else files.copy("resources/lang/english_us.txt",pathABM.."lang/") dofile("resources/lang/english_us.txt") end
end

-- Loading custom ttf font if exits
if files.exists(pathABM.."/resources/"..__LANG..".ttf") then font.setdefault(pathABM.."/resources/"..__LANG..".ttf")
else
	if files.exists("resources/"..__LANG..".ttf") then font.setdefault("resources/"..__LANG..".ttf") end
end

dofile("system/commons.lua")
if os.access() == 0 then
	if back then back:blit(0,0) end
	screen.flip()
	custom_msg(strings.unsafe,0)
	os.exit()
end

dofile("git/updater.lua")

ADRENALINE = "ux0:app/PSPEMUCFW"
ADRENALINEK = ADRENALINE.."/sce_module/adrenaline_kernel.skprx"
oncopy = false

dofile("system/callbacks.lua")

if back then back:blit(0,0) end
screen.flip()

if game.exists("PSPEMUCFW") and files.exists(ADRENALINE) and
	files.exists(ADRENALINE.."/eboot.bin") and files.exists(ADRENALINE.."/eboot.pbp") then

	if not files.exists(ADRENALINE.."/sce_module/adrbubblebooter.suprx") then
		oncopy = true
		files.copy("sce_module/", ADRENALINE)

		os.delay(100)
		custom_msg(strings.adrinst,0)
		os.delay(500)
		power.restart()
	end

	dofile("iosk/utf8.lua")
	dofile("iosk/iosk.lua")
	dofile("system/stars.lua")
	dofile("system/scan.lua")
	dofile("system/bubbles.lua")

	os.cpu(444)
		bubbles.scan()
		scan.games()
	os.cpu(333)
	scan.show()

else
	custom_msg(strings.notadr,0)
end
