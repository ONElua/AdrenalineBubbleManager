--[[ 
	Adrenaline Bubble Manager VPK.
	Create and organize your direct adrenaline bubbles.
	
	Licensed by GNU General Public License v3.0
	
	Designed By:
	- Gdljjrod (https://twitter.com/gdljjrod).
	- DevDavisNunez (https://twitter.com/DevDavisNunez).
]]

dofile("system/commons.lua")
if os.access() == 0 then
	if back then back:blit(0,0) end
	screen.flip()
	custom_msg(strings.unsafe,0)
	os.exit()
end

local wstrength = wlan.strength()
if wstrength then
	if wstrength > 55 then dofile("git/updater.lua") end
end

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
