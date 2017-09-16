--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

ADRENALINEK = "ur0:adrenaline/adrenaline.skprx"

NOSTARTDAT		=	"ux0:adrbblbooter/adrbblbooter_nostartdat.suprx"
ADRBBLBOOTER	=	"ur0:adrbblbooter/adrbblbooter.suprx"
ADRBUBBLESDB	=	"ur0:adrbblbooter/bubblesdb/"

ADRENALINE =	"ur0:adrenaline/adrenaline.suprx"
if not files.exists(ADRENALINE) then
ADRENALINE =	"ux0:adrenaline/adrenaline.suprx"						--Adrenaline old
end

-- Adrbblbooter v.05
if not files.exists(ADRBUBBLESDB) then files.mkdir(ADRBUBBLESDB) end
files.copy("system_old/adrbblbooter/adrbblbooter.suprx", "ur0:adrbblbooter/")
files.copy("system_old/adrbblbooter/readme.txt", "ur0:adrbblbooter/")
