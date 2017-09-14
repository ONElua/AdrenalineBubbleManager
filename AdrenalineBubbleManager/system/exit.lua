PowerReset,kick=false,false

function ForcePowerReset()
	PowerReset = true
end

local scr_flip = screen.flip
function screen.flip() -- Hook flip! :D
	scr_flip()

	-- In any section, if press start go to livearea or restart vita if is needed! :)
	if buttons.released.start and not kick then
		if PowerReset then RestartV() end
		os.exit() 
	end
end
