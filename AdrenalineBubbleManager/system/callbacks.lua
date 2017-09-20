--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

function onAppInstall(step, size_argv, written, file, totalsize, totalwritten)

	if vbuff then vbuff:blit(0,0) elseif back then back:blit(0,0) end

	if step == 1 then												-- Only msg of state
		draw.fillrect(0,0,960,30, color.green:a(100))
		screen.print(10,10,"Preparing to install !!!")
		screen.flip()
	elseif step == 2 then											-- Warning Vpk confirmation!
		os.delay(100)
		return 10 -- Ok
	elseif step == 4 then											-- Promote or install
		draw.fillrect(0,0,960,30, color.green:a(100))
		screen.print(10,10,"Installing ...")
		screen.flip()
	end
end

function onPbpUnpack(size, written, name)

	if vbuff then vbuff:blit(0,0) elseif back then back:blit(0,0) end

	draw.fillrect(0,0,960,30, color.green:a(100))
	screen.print(10,10,"Getting the resources...")
	screen.print(925,10,math.floor((written*100)/size).." %",1.0,color.white, color.black, __ARIGHT)
	screen.print(10,35," File: "..tostring(name))

	screen.print(480,100,"Please wait...", 1, color.white, color.black, __ACENTER)
	os.delay(500)

	screen.flip()

end

function onCopyFiles(size,written,file)

	if oncopy then
		if vbuff then vbuff:blit(0,0) elseif back then back:blit(0,0) end
		draw.fillrect(0,0,__DISPLAYW,30, color.shine)

		screen.print(925,10,math.floor((written*100)/size).." %",1.0,color.white, color.black, __ARIGHT)
		screen.print(10,10," File: "..tostring(file))

		screen.flip()
	end
end
