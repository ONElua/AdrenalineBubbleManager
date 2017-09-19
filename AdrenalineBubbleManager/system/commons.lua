--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

SYMBOL_CROSS	= string.char(0xe2)..string.char(0x95)..string.char(0xb3)
SYMBOL_SQUARE	= string.char(0xe2)..string.char(0x96)..string.char(0xa1)
SYMBOL_TRIANGLE	= string.char(0xe2)..string.char(0x96)..string.char(0xb3)
SYMBOL_CIRCLE	= string.char(0xe2)..string.char(0x97)..string.char(0x8b)

function files.write(path,data,mode) -- Write a file.
	local fp = io.open(path, mode or "w+")
	if fp == nil then return end
	fp:write(data)
	fp:flush()
	fp:close()
end

function files.read(path,mode) -- Read a file.
	local fp = io.open(path, mode or "r")
	if not fp then return nil end
	local data = fp:read("*a")
	fp:close()
	return data
end

-- Debug utilities :D
debug_print={}
function init_msg(msg)
	table.insert(debug_print,msg)
	back:blit(0,0)
	local y=5
	if #debug_print<=20 then I=1 else I=#debug_print-19 end 
	for i=I, #debug_print do
		screen.print(10,y,debug_print[i],1)
		y+=25
	end
	screen.flip()
	os.delay(5)
end

--[[
	## Library Scroll ##
	Designed By DevDavis (Davis Nuñez) 2011 - 2016.
	Based on library of Robert Galarga.
	Create a obj scroll, this is very usefull for list show
	]]
function newScroll(a,b,c)
	local obj = {ini=1,sel=1,lim=1,maxim=1,minim = 1}

	function obj:set(tab,mxn,modemintomin) -- Set a obj scroll
		obj.ini,obj.sel,obj.lim,obj.maxim,obj.minim = 1,1,1,1,1
		--os.message(tostring(type(tab)))
		if(type(tab)=="number")then
			if tab > mxn then obj.lim=mxn else obj.lim=tab end
			obj.maxim = tab
		else
			if #tab > mxn then obj.lim=mxn else obj.lim=#tab end
			obj.maxim = #tab
		end
		if modemintomin then obj.minim = obj.lim end
	end

	function obj:max(mx)
		obj.maxim = #mx
	end

	function obj:up()
		if obj.sel>obj.ini then obj.sel=obj.sel-1
		elseif obj.ini-1>=obj.minim then
			obj.ini,obj.sel,obj.lim=obj.ini-1,obj.sel-1,obj.lim-1
		end
	end

	function obj:down()
		if obj.sel<obj.lim then obj.sel=obj.sel+1
		elseif obj.lim+1<=obj.maxim then
			obj.ini,obj.sel,obj.lim=obj.ini+1,obj.sel+1,obj.lim+1
		end
	end

	if a and b then
		obj:set(a,b,c)
	end

	return obj

end

-- Functions Imgs
--image_convert(work_res, work_dir, "ICON0.PNG", "startup.png", 128,128)
--image_convert(work_res, work_dir, "PIC1.PNG", "bg0.png", 960, 544)
function image_convert(wres, wdir, img1, img2, w)

	if files.exists(wres..img1) then
		files.rename(wres..img1, "TMP8.PNG")
		files.copy(wres.."TMP8.PNG", wdir.."sce_sys/")

		local tmp = image.load(wdir.."sce_sys/TMP8.PNG")
		if tmp then

			local scalew,scaleh = 128,128

			if img1 == "ICON0.PNG" then
				if tmp:getrealw() == 144 and tmp:getrealh() == 80 then
					files.copy(wdir.."sce_sys/TMP8.PNG", wdir.."sce_sys/livearea/contents/")
					files.rename(wdir.."sce_sys/livearea/contents/TMP8.PNG", "startup.png")
				end
			end

			if w == 960 then scalew,scaleh = 960,544 end
			image.save(tmp:copyscale(scalew,scaleh), wdir.."sce_sys/"..img1)

			
			if w == 960 then scalew,scaleh = 840,500 end
			if not files.exists(wdir.."sce_sys/livearea/contents/"..img2) then
				image.save(tmp:copyscale(scalew,scaleh), wdir.."sce_sys/livearea/contents/"..img2)
			end

			local imgtmp = img1
			if w == 960 then imgtmp = "PIC0.PNG" end

			files.write(wdir.."sce_sys/"..imgtmp, image.compress(files.read(wdir.."sce_sys/"..img1)))
			os.message(imgtmp.." 8 bits")
			files.write(wdir.."sce_sys/livearea/contents/"..img2, image.compress(files.read(wdir.."sce_sys/livearea/contents/"..img2)))

			files.delete(wdir.."sce_sys/TMP8.PNG")
		end

		files.rename(wres.."TMP8.PNG", img1)
	else
		local imgtmp = img1
		if w == 960 then imgtmp = "PIC0.PNG" end
		files.copy(wdir.."sce_sys_lman/"..imgtmp, wdir.."sce_sys")
		files.copy(wdir.."sce_sys_lman/livearea/contents/"..img2, wdir.."sce_sys/livearea/contents/")
	end
end
