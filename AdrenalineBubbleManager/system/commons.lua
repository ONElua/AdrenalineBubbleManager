--[[

    Licensed by Creative Commons Attribution-ShareAlike 4.0
   http://creativecommons.org/licenses/by-sa/4.0/
   
   Designed By Gdljjrod & DevDavisNunez.
   Collaborators: BaltaR4 & Wzjk.
   
]]

game.close()
color.loadpalette()

-- Set ux0 folder path
local pathABM 	= "ux0:data/ABM/"
__PATHINI		= "ux0:data/ABM/config.ini"

__PATHSETS = "ux0:ABM/"
files.mkdir(__PATHSETS)

files.mkdir(pathABM)
files.mkdir(pathABM.."lang/")
files.mkdir(pathABM.."font/")
files.mkdir(pathABM.."resources/")

-- Loading language file
__LANG = os.language()

dofile("resources/lang/english_us.txt")
if not files.exists("ux0:data/ABM/lang/english_us.txt") then files.copy("resources/lang/english_us.txt","ux0:data/ABM/lang/") end
if files.exists("ux0:data/ABM/lang/"..__LANG..".txt") then dofile("ux0:data/ABM/lang/"..__LANG..".txt")	end
if files.exists("resources/lang/"..__LANG..".txt") then dofile("resources/lang/"..__LANG..".txt") end

-- Loading custom font
if files.exists(pathABM.."font/font.ttf") then
	fnt = font.load(pathABM.."font/font.ttf")
elseif files.exists(pathABM.."font/font.pgf") then
	fnt = font.load(pathABM.."font/font.pgf")
elseif files.exists(pathABM.."font/font.pvf") then
	fnt = font.load(pathABM.."font/font.pvf")
end
if fnt then	font.setdefault(fnt) end

-- Background image must be (960x554 png or jpg image. Priority to back.png)
if files.exists(pathABM.."resources/back.png") then back = image.load(pathABM.."resources/back.png")
	elseif files.exists(pathABM.."resources/back.jpg") then back = image.load(pathABM.."resources/back.jpg")
		else back = image.load("resources/back.png")
end

-- Background2 image must be (960x554 png or jpg image. Priority to back2.png)
if files.exists(pathABM.."resources/back1.png") then back1 = image.load(pathABM.."resources/back1.png")
	elseif files.exists(pathABM.."resources/back1.jpg") then back1 = image.load(pathABM.."resources/back1.jpg")
		else back1 = image.load("resources/back1.png")
end

-- Background2 image must be (960x554 png or jpg image. Priority to back2.png)
if files.exists(pathABM.."resources/back2.png") then back2 = image.load(pathABM.."resources/back2.png")
	elseif files.exists(pathABM.."resources/back2.jpg") then back2 = image.load(pathABM.."resources/back2.jpg")
		else back2 = image.load("resources/back2.png")
end

-- Popup message background (must be 706x274 png image)
if files.exists(pathABM.."resources/box.png") then box = image.load(pathABM.."resources/box.png")
else box = image.load("resources/box.png") end

-- Loading default GFX from app folder
buttonskey = image.load("resources/buttons.png",20,20)
buttonskey2 = image.load("resources/buttons2.png",30,20)

SYMBOL_CROSS	= string.char(0xe2)..string.char(0x95)..string.char(0xb3)
SYMBOL_SQUARE	= string.char(0xe2)..string.char(0x96)..string.char(0xa1)
SYMBOL_TRIANGLE	= string.char(0xe2)..string.char(0x96)..string.char(0xb3)
SYMBOL_CIRCLE	= string.char(0xe2)..string.char(0x97)..string.char(0x8b)

accept,cancel = "cross","circle"
accept_x = 1
SYMBOL_BACK = SYMBOL_CIRCLE
SYMBOL_BACK2 = SYMBOL_CROSS
STRING_PRESS = SCAN_PRESS_CROSS
if buttons.assign()==0 then
	accept,cancel = "circle","cross"
	accept_x = 0
	SYMBOL_BACK = SYMBOL_CROSS
	SYMBOL_BACK2 = SYMBOL_CIRCLE
	STRING_PRESS = SCAN_PRESS_CIRCLE
end

colors = { 	
			color.new(224,224,224), -- new default color, closely resembles official bubbles, dont modify this color (defect color)...
			color.black, color.red, color.green, color.blue, color.cyan, color.gray, color.magenta,
			color.yellow, color.maroon, color.grass, color.navy, color.turquoise, color.violet, color.olive,
			color.white, color.orange, color.chocolate
			--you can add more colors :D
		}

-- Debug utilities :D
debug_print={}
function init_msg(msg)
	table.insert(debug_print,msg)
	if back2 then back2:blit(0,0) end
	local y=30
	if #debug_print<=20 then I=1 else I=#debug_print-19 end 
	for i=I, #debug_print do
		screen.print(10,y,debug_print[i],1)
		y+=25
	end
	screen.flip()
	os.delay(5)
end

sort_games = { SCAN_SORT_TITLE, SCAN_SORT_MTIME, SCAN_SORT_INSTALLED, SCAN_SORT_CATEGORY, SCAN_SORT_GAMEID, SCAN_SORT_DEVICE }
sort_mode = { "title", "mtime", "install", "type", "gameid", "device" }

__SORT = tonumber(ini.read(__PATHINI,"sort","sort","3"))
__COLOR = tonumber(ini.read(__PATHINI,"color","color","1"))
__UPDATE = tonumber(ini.read(__PATHINI,"update","update","1"))
__CHECKADR = tonumber(ini.read(__PATHINI,"check_adr","check_adr","1"))
__SET = tonumber(ini.read(__PATHINI,"resources","set","0"))
__8PNG = tonumber(ini.read(__PATHINI,"convert","8bits","1"))
__CUSTOM = tonumber(ini.read(__PATHINI,"custom","customized","1"))

__SORT = math.minmax(__SORT, 1, #sort_mode)
_sort,sort_type = __SORT, sort_games[__SORT]
_color = __COLOR
if __UPDATE == 1 then _update = STRINGS_OPTION_MSG_YES else _update = STRINGS_OPTION_MSG_NO end
if __CHECKADR == 1 then _adr = STRINGS_OPTION_MSG_YES else _adr = STRINGS_OPTION_MSG_NO end
if __SET == 0 then setpack = STRINGS_OPTION_MSG_NO elseif __SET == 6 then setpack = STRINGS_PSP_PSX_BUBBLES else setpack = SCAN_SETPACK..__SET end
if __8PNG == 1 then _png = STRINGS_OPTION_MSG_YES else _png = STRINGS_OPTION_MSG_NO end
if __CUSTOM == 1 then _custom = STRINGS_OPTION_MSG_YES else _custom = STRINGS_OPTION_MSG_NO end
TOTAL_SET = 6

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

function image.startup(img)
    local w,h = img:getw(), img:geth()

	if w != 280 or h != 158 then
		w,h = 280,158
		img = img:copyscale(w,h)
	end

	local px,py = 0, 192-h --34
	local sheet = image.new(280, 192, 0x0)
	for y=0,h-1 do
		for x=0,w-1 do
			local c = img:pixel(x,y)
			if c:a() == 0 then c = 0x0 end 
			sheet:pixel(px+x, py+y, c)
		end
	end
	return sheet
end

function image.nostretched(img,cc)
    local w,h = img:getw(), img:geth()
	
	--[[if w != 80 or h != 80 then w,h = 108,60
	else w,h = 90,90 end 
	img = img:copyscale(w,h)
	]]
	if w != 80 or h != 80 then
		w,h = 100,55
		img = img:copyscale(w,h)
	end

	local px,py = 64 - (w/2),64 - (h/2)
	local sheet = image.new(128, 128, cc)
	for y=0,h-1 do
		for x=0,w-1 do
			local c = img:pixel(x,y)
			if c:a() == 0 then c = cc end 
			--sheet:pixel(px+x, py+y, c)
			if h % 2 == 0 then sheet:pixel(px+x, py+y, c) else sheet:pixel(px+x, py+y+1, c) end
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
	xopt1 = 360 - (screen.textwidth(STRINGS_OPTION_MSG_YES)/2)
	xopt2 = 600 - (screen.textwidth(STRINGS_OPTION_MSG_NO)/2)

	buttons.read()
	local result = false
	while true do
		buttons.read()
		if buff then buff:blit(0,0) end
		if box then	box:blit(480,272) end

		screen.print(480,165, STRINGS_CUSTOM_TITLE_MSG, 1, color.white, color.gray, __ACENTER)
		screen.print(xtext,200, printtext,1, color.gray)

		if mode == 0 then
			screen.print(xopt1+120,363, SYMBOL_BACK2.." : "..STRINGS_OPTION_MSG_OK,1.02, color.gray)
		else
			screen.print(xopt1,363, SYMBOL_BACK2.." : "..STRINGS_OPTION_MSG_YES,1.02, color.gray)
			screen.print(xopt2,363, SYMBOL_BACK.." : "..STRINGS_OPTION_MSG_NO,1.02, color.gray)
		end

		screen.flip()

		if buttons[accept] and mode != 2 then-- Accept
			result = true
			break
		end

		if buttons[cancel] and mode != 0 then-- Cancel
			result = false
			break
		end
	end
	buttons.read()

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

function isTouched(x,y,sx,sy)
	if math.minmax(touch.front[1].x,x,x+sx)==touch.front[1].x and math.minmax(touch.front[1].y,y,y+sy)==touch.front[1].y then
		return true
	end
	return false
end

-- Convert 4 bytes (32 bit) string to number int...
function str2int(str)
	local b1, b2, b3, b4 = string.byte(str, 1, 4)
	return (b4 << 24) + (b3 << 16) + (b2 << 8) + b1
end

-- Convert Number (32bit) to a string 4 bytes...
function int2str(data)
	return string.char((data)&0xff)..string.char(((data)>>8)&0xff)..string.char(((data)>>16)&0xff)..string.char(((data)>>24)&0xff)
end

partitions = { "ux0:", "uma0:", "ur0:", "imc0:", "xmc0:" }
function AutoMakeBootBin(obj)

	local path2game, _find = "", false
	local drivers = { "ENABLE", "INFERN0", "MARCH", "NP9660" }		--0,0, 1,2
	local bins = { "ENABLE", "EBOOT.BIN", "EBOOT.OLD", "BOOT.BIN" }	--0,0 1,2

	---Searching game in partitions
	local path_game = ini.read(obj.path.."/data/boot.inf", "PATH", "ENABLE")

	if path_game == "ENABLE" then path_game = "ms0:/nogame"
	else
		for j=1, #partitions do
			path2game = path_game:gsub("ms0:/", partitions[j].."pspemu/")
			if files.exists(path2game) then _find=true break end
		end
	end

	if not _find then path2game = path_game:gsub("ms0:/", "ux0:pspemu/") end
	
	local driver = ini.read(obj.path.."/data/boot.inf", "DRIVER", "ENABLE")
	local bin = ini.read(obj.path.."/data/boot.inf", "EXECUTE", "ENABLE")

	--Fill boot.bin
	files.copy("bubbles/pspemuxxx/data/boot.bin", obj.path.."/data/")

	local fp = io.open(obj.path.."/data/boot.bin", "r+")
	if fp then
		local number = 0
							
		--Driver
		fp:seek("set",0x04)
		for j=1,#drivers do
			if driver:upper() == drivers[j] then
				if j == 1 then number = 0 else number = j - 2 end
				break
			end
		end
		fp:write(int2str(number))

		number = 0

		--Execute
		fp:seek("set",0x08)
		for j=1,#bins do
			if bin:upper() == bins[j] then
				if j == 1 then number = 0 else number = j - 2 end
				break
			end
		end
		fp:write(int2str(number))

		--Customized is ready in boot.bin (default)
		--fp:seek("set",0x0C)
		--fp:write(int2str(1))

		--Path2game
		fp:seek("set",0x20)
		local fill = 256 - #path2game
		for j=1,fill do
			path2game = path2game..string.char(00)
		end
		fp:write(path2game)

		--Close
		fp:close()

	end--fp

end

function message_wait(message)
	local mge = (message or MESSAGE_WAIT)
	local titlew = string.format(mge)
	local w,h = screen.textwidth(titlew,1) + 30,70
	local x,y = 480 - (w/2), 272 - (h/2)

	draw.fillrect(x,y,w,h,color.shine)
	draw.rect(x,y,w,h,color.white)
		screen.print(480,y+13, titlew,1,color.white,color.black,__ACENTER)
	screen.flip()
end
