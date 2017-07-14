--[[ 
	Adrenaline Bubble Manager.
	Create and organize your direct adrenaline bubbles.
	
	Licensed by GNU General Public License v3.0
	
	Designed By:
	- Gdljjrod (https://twitter.com/gdljjrod).
	- DevDavisNunez (https://twitter.com/DevDavisNunez).
]]

buttons.homepopup(0) -- Lock exit to livearea! :)
color.loadpalette() -- Load palette of colors!

buttons.read()
--if buttons.held.r then debug_mode = true end
debug_mode = true

back = image.load("system/back.png")
buttonskey = image.load("system/buttons.png",20,20)
buttonskey2 = image.load("system/buttons2.png",30,20)

dofile("git/updater.lua")
dofile("system/exit.lua")
dofile("system/tai.lua")
dofile("system/utils.lua")
dofile("system/scan.lua")
dofile("system/bubbles.lua")

tai.load()
scan.scan()
bubbles.load()

scan.show()

buttons.homepopup(1) -- Unlock exit to livearea! :)
