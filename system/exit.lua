ReloadConfigTxt,PowerReset,kick=false,false,false

function ForceReload()
	ReloadConfigTxt = true
end

function ForcePowerReset()
	PowerReset = true
end

local scr_flip = screen.flip
function screen.flip() -- Hook flip! :D
	scr_flip()

	-- In any section, if press start go to livearea or restart vita if is needed! :)
	if buttons.released.start and not kick then
		if PowerReset then RestartV() end
		if ReloadConfigTxt then
			os.taicfgreload()
			os.message("Reload taiHEN Done!!")
		end
		os.exit() 
	end
end
