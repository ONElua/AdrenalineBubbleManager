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

function update_resources(gameid, update_res)
	-----------------------------------      ur0:appmeta      --------------------------------------------------------------------
	local appmeta = string.format("ur0:appmeta/%s",gameid)
	local path = "ux0:app/"..gameid.."/resources/"
	local upd = false

	if files.exists(path.."ICON0.PNG") then

		files.copy(path.."ICON0.PNG", appmeta)
		if files.exists(appmeta.."/livearea/contents/startup.png") then
			files.delete(appmeta.."/livearea/contents/startup.png")
		end
		files.copy(path.."ICON0.PNG", appmeta.."/livearea/contents/")
		files.rename(appmeta.."/livearea/contents/ICON0.PNG","startup.png")

		ForcePowerReset()
		upd = true
	end

	if files.exists(path.."PIC1.PNG") then

		files.copy(path.."PIC1.PNG", appmeta)
		if files.exists(appmeta.."/PIC0.PNG") then
			files.delete(appmeta.."/PIC0.PNG")
		end
		files.rename(appmeta.."/PIC1.PNG","PIC0.PNG")

		if files.exists(appmeta.."/livearea/contents/BG0.PNG") then
			files.delete(appmeta.."/livearea/contents/BG0.PNG")
		end
		files.copy(path.."PIC1.PNG", appmeta.."/livearea/contents/")
		files.rename(appmeta.."/livearea/contents/PIC1.PNG","BG0.PNG")

		ForcePowerReset()
		upd = true
	end

	if update_res and upd then os.message("Update Bubble: "..gameid) end

end
