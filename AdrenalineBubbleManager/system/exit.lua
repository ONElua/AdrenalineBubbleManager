PowerReset,kick=false,false

function ForcePowerReset()
	PowerReset = true
end

function RestartV()
	os.delay(50)
	os.message("Your PSVita will restart...")
	os.delay(1000)
	power.restart()
end

local scr_flip = screen.flip
function screen.flip() -- Hook flip! :D
	scr_flip()

	if buttons.released.start and not kick then
		if PowerReset then RestartV() end
		os.exit() 
	end
end
