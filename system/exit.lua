UpdateDataBase, ReloadConfigTxt, PowerReset= false,false,false

function ForceReload()
   ReloadConfigTxt = true
end

function ForceUpdateDb()
   UpdateDataBase = true
end

function ForcePowerReset()
   PowerReset = true
end

local scr_flip = screen.flip
function screen.flip() -- Hook flip! :D
	scr_flip()
	if buttons.released.start then -- buttons.home then -- In any section, if press start go to livearea or updatedb if is needed! :)
		if UpdateDataBase then UpdateDB() end
		if PowerReset then RestartV() end
		if ReloadConfigTxt then
			os.taicfgreload()
			os.message("Reload taiHEN Done!!")
		end
		os.exit() 
	end
end
