--[[ 
	Adrenaline Bubble Manager VPK.
	Create and organize your direct adrenaline bubbles.
	
	Licensed by GNU General Public License v3.0
	
	Designed By:
	- Gdljjrod (https://twitter.com/gdljjrod).
	- DevDavisNunez (https://twitter.com/DevDavisNunez).
]]

if os.access() == 0 then
	os.message("UNSAFE MODE is required for this Homebrew !!!",0)
	os.exit()
end

game.close()
buttons.homepopup(0)	-- Lock exit to livearea! :)
color.loadpalette()		-- Load palette of colors!

buttons.read()
back = image.load("resources/back.png")
buttonskey = image.load("resources/buttons.png",20,20)
buttonskey2 = image.load("resources/buttons2.png",30,20)

dofile("git/updater.lua")

ADRENALINE = "ux0:app/PSPEMUCFW"
ADRENALINEK = ADRENALINE.."/sce_module/adrenaline_kernel.skprx"

oncopy = false
if game.exists("PSPEMUCFW") and files.exists("ux0:app/PSPEMUCFW") and
	files.exists("ux0:app/PSPEMUCFW/eboot.bin") and files.exists("ux0:app/PSPEMUCFW/eboot.pbp") then

	dofile("system/exit.lua")
	dofile("system/tai.lua")
	dofile("system/callbacks.lua")

	tai.load()
	if not tai.find("KERNEL",ADRENALINEK) then
		tai.put("KERNEL",ADRENALINEK)
		tai.sync()
		ForcePowerReset()
	end

	if not files.exists(ADRENALINE.."/sce_module/adrbubblebooter.suprx") then
		oncopy = true
		files.copy("sce_module/", ADRENALINE)

		os.message("AdrBubbleBooter plugin has been installed... \nWe need to restart your PSVita... :)")
		os.delay(500)
		power.restart()
	end

	dofile("system/commons.lua")

	dofile("system/scan.lua")
	dofile("system/bubbles.lua")


	scan.games()
	scan.show()

else
	os.message("Adrenaline v6 has not been installed...")
end

buttons.homepopup(1)	-- Unlock exit to livearea! :)
