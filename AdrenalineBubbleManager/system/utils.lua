--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

--Globlals
ADRENALINEK = "ux0:app/PSPEMUCFW/sce_module/adrenaline_kernel.skprx"
bubbles = {}

SCEMODULE = "ux0:app/PSPEMUCFW/sce_module" 
if not files.exists(SCEMODULE.."/adrbubblebooter.suprx") then 
	files.copy("sce_module/adrbubblebooter.suprx", SCEMODULE) 
	files.copy("sce_module/adrenaline_kernel.skprx", SCEMODULE) 
	files.copy("sce_module/adrenaline_user.suprx", SCEMODULE) 
	files.copy("sce_module/adrenaline_vsh.suprx", SCEMODULE) 
	files.copy("sce_module/usbdevice.skprx", SCEMODULE) 
end
