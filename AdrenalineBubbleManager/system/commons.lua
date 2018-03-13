--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

game.close()
color.loadpalette()

-- Set ux0 folder path
local pathABM = "ux0:data/ABM/"
files.mkdir(pathABM)
files.mkdir(pathABM.."lang/")
files.mkdir(pathABM.."resources/")

-- Background image must be (960x554 png or jpg image. Priority to back.png)
if files.exists(pathABM.."resources/back.png") then back = image.load(pathABM.."resources/back.png")
	elseif files.exists(pathABM.."resources/back.jpg") then back = image.load(pathABM.."resources/back.jpg")
		else back = image.load("resources/back.png")
end

-- Popup message background (must be 706x274 png image)
if files.exists(pathABM.."resources/box.png") then box = image.load(pathABM.."resources/box.png")
else box = image.load("resources/box.png") end

-- Loading default GFX from app folder
buttonskey = image.load("resources/buttons.png",20,20)
buttonskey2 = image.load("resources/buttons2.png",30,20)

-- Loading language file
__LANG = os.language()
__STRINGS		= 49

-- reading lang strings from ux0:data/ABM/ if exist
if files.exists(pathABM.."lang/"..__LANG..".txt") then dofile(pathABM.."lang/"..__LANG..".txt")
	local cont = 0
	for key,value in pairs(strings) do cont += 1 end
	if cont != __STRINGS then files.copy("resources/lang/english_us.txt",pathABM.."lang/") dofile("resources/lang/english_us.txt") end
else 
-- reading lang strings fom app folder if exist
	if files.exists("resources/lang/"..__LANG..".txt") then
		dofile("resources/lang/"..__LANG..".txt")
		local cont = 0
		for key,value in pairs(strings) do cont += 1 end
		if cont != __STRINGS then files.copy("resources/lang/english_us.txt",pathABM.."lang/") dofile("resources/lang/english_us.txt") end
-- reading default lang strings if no one translations founded
	else files.copy("resources/lang/english_us.txt",pathABM.."lang/") dofile("resources/lang/english_us.txt") end
end
if not files.exists(pathABM.."lang/english_us.txt") then files.copy("resources/lang/english_us.txt",pathABM.."lang/") end

-- Loading custom ttf font if exits
if files.exists(pathABM.."/resources/"..__LANG..".ttf") then font.setdefault(pathABM.."/resources/"..__LANG..".ttf") end

boot = { "PATH", "DRIVER", "EXECUTE", "PLUGINS" }

SYMBOL_CROSS	= string.char(0xe2)..string.char(0x95)..string.char(0xb3)
SYMBOL_SQUARE	= string.char(0xe2)..string.char(0x96)..string.char(0xa1)
SYMBOL_TRIANGLE	= string.char(0xe2)..string.char(0x96)..string.char(0xb3)
SYMBOL_CIRCLE	= string.char(0xe2)..string.char(0x97)..string.char(0x8b)

selcolor = 1
colors = { 	
			color.black,		-- <--- dont modify this color (defect color)...
			--you can add more colors :D
			color.red, color.green, color.blue, color.cyan, color.gray, color.magenta, color.yellow,
			color.maroon, color.grass, color.navy, color.turquoise, color.violet, color.olive,
			color.white, color.orange, color.chocolate
		}

-- Debug utilities :D
debug_print={}
function init_msg(msg)
	table.insert(debug_print,msg)
	if back then back:blit(0,0) end
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
		if obj.sel>obj.ini then obj.sel=obj.sel-1 return true
		elseif obj.ini-1>=obj.minim then
			obj.ini,obj.sel,obj.lim=obj.ini-1,obj.sel-1,obj.lim-1
			return true
		end
	end

	function obj:down()
		if obj.sel<obj.lim then obj.sel=obj.sel+1 return true
		elseif obj.lim+1<=obj.maxim then
			obj.ini,obj.sel,obj.lim=obj.ini+1,obj.sel+1,obj.lim+1
			return true
		end
	end

	if a and b then
		obj:set(a,b,c)
	end

	return obj

end

function image.nostretched(img,cc)
    local w,h = img:getw(), img:geth()
	if w != 80 or h != 80 then w,h = 108,60
	else w,h = 90,90 end 
	img = img:copyscale(w,h)
	local px,py = 64 - (w/2),64 - (h/2)
	local sheet = image.new(128, 128, cc)
	for y=0,h-1 do
		for x=0,w-1 do
			local c = img:pixel(x,y)
			if c:a() == 0 then c = cc end 
			sheet:pixel(px+x, py+y, c)
		end
	end
	return sheet
end

function custom_msg(printtext,mode)
	local buff = screen.toimage()
	if box then box:center() end

	for i=0,102,6 do

		if buff then buff:blit(0,0) end
		if box then
			box:scale(i)
			box:blit(960/2,544/2)
		end

		screen.flip()
	end

	xtext = 480 - (screen.textwidth(printtext)/2)
	xopt1 = 360 - (screen.textwidth(strings.option1_msg)/2)
	xopt2 = 600 - (screen.textwidth(strings.option2_msg)/2)

	buttons.read()
	local result = false
	while true do
		buttons.read()
		if buff then buff:blit(0,0) end
		if box then	box:blit(480,272) end

		screen.print(480,165, strings.title_msg, 1, color.white, color.gray, __ACENTER)
		screen.print(xtext,200, printtext,1, color.gray)

		if mode == 0 then
			screen.print(xopt1+120,360, SYMBOL_CROSS.." : "..strings.option_msg,1.02, color.gray)
		else
			screen.print(xopt1,360, SYMBOL_CROSS.." : "..strings.option1_msg,1.02, color.gray)
			screen.print(xopt2,360, SYMBOL_CIRCLE.." : "..strings.option2_msg,1.02, color.gray)
		end

		screen.flip()

		if buttons.released.cross and mode != 2 then-- Accept
			result = true
			break
		end

		if buttons.released.circle and mode != 0 then-- Cancel
			result = false
			break
		end
	end

	for i=102,0,-6 do

		if buff then buff:blit(0,0) end
		if box then
			box:scale(i)
			box:blit(960/2,544/2)
		end

		screen.flip()
	end

	if result then return true else return false end

end

function files.read(path,mode)
	local fp = io.open(path, mode or "r")
	if not fp then return nil end

	local data = fp:read("*a")
	fp:close()
	return data
end
