
local UpdateDataBase = false;

function ForceReset()
	UpdateDataBase = true;
end

local scr_flip = screen.flip
function screen.flip() -- Hook flip! :D
	scr_flip()
	if buttons.released.start then -- buttons.home then -- In any section, if press start go to livearea or updatedb if is needed! :)
		if UpdateDataBase then UpdateDB() end	
		os.exit()
	end
end