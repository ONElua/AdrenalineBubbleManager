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

buttons.read()
back = image.load("resources/back.png")
buttonskey = image.load("resources/buttons.png",20,20)
buttonskey2 = image.load("resources/buttons2.png",30,20)
local pathABM = "ux0:data/ABM/"
files.mkdir(pathABM)
if files.exists(pathABM.."font.ttf") then font.setdefault(pathABM.."font.ttf") end
if files.exists(pathABM.."lang.lua") then dofile(pathABM.."lang.lua")
else files.copy("system/lang.lua",pathABM) dofile("system/lang.lua") end

if os.access() == 0 then
	if back then back:blit(0,0) end
	screen.flip()
	os.message(strings.unsafe,0)
	os.exit()
end

dofile("git/updater.lua")

ADRENALINE = "ux0:app/PSPEMUCFW"
ADRENALINEK = ADRENALINE.."/sce_module/adrenaline_kernel.skprx"
oncopy = false

dofile("system/commons.lua")
dofile("system/callbacks.lua")

if back then back:blit(0,0) end
screen.flip()

if game.exists("PSPEMUCFW") and files.exists(ADRENALINE) and
	files.exists(ADRENALINE.."/eboot.bin") and files.exists(ADRENALINE.."/eboot.pbp") then

	if not files.exists(ADRENALINE.."/sce_module/adrbubblebooter.suprx") then
		oncopy = true
		files.copy("sce_module/", ADRENALINE)

		os.delay(100)
		os.message(strings.adrinst)
		os.delay(500)
		power.restart()
	end

	dofile("iosk/utf8.lua")
	dofile("iosk/iosk.lua")
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
