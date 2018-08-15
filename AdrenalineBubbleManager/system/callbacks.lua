--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]
bubble_id, reinstall = "",false

function onAppInstall(step, size_argv, written, file, totalsize, totalwritten)

	if vbuff then vbuff:blit(0,0) elseif back2 then back2:blit(0,0) end

	if step == 2 then											-- Warning Vpk confirmation!
		os.delay(100)
		return 10 -- Ok
	elseif step == 4 then										-- Promote or install
		draw.fillrect(0,0,__DISPLAYW,30, color.shine)
		if reinstall then
			screen.print(10,10,UPDATING_BUBBLES.." "..bubble_id)
		else
			screen.print(10,10,INSTALLING_BUBBLE.." "..bubble_id)
		end

		screen.flip()
	end
end

function onCopyFiles(size,written,file)

	if oncopy then
		if vbuff then vbuff:blit(0,0) elseif back2 then back2:blit(0,0) end
		draw.fillrect(0,0,__DISPLAYW,30, color.shine)

		screen.print(925,10,math.floor((written*100)/size).." %",1.0,color.white, color.black, __ARIGHT)
		screen.print(10,10,STRING_FILE.." "..tostring(file))

		screen.flip()
	end
end

