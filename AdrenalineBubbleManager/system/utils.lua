SYMBOL_CROSS = string.char(0xe2)..string.char(0x95)..string.char(0xb3)-- "\xE2\x95\xB3"
SYMBOL_SQUARE = string.char(0xe2)..string.char(0x96)..string.char(0xa1)-- "\xE2\x96\xA1"
SYMBOL_TRIANGLE = string.char(0xe2)..string.char(0x96)..string.char(0xb3)-- "\xE2\x96\xB3"
SYMBOL_CIRCLE = string.char(0xe2)..string.char(0x97)..string.char(0x8b)-- "\xE2\x97\x8B"

function RestartV()
	os.delay(100)
	os.message("Your PSVita will restart...")
	os.delay(1500)
	power.restart()
end

function UpdateDB()
	os.delay(100)
	os.updatedb()
	os.message("Your PSVita will restart...\nand your database will be update")
	os.delay(1500)
	power.restart()
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

function files.write(path,data,mode) -- Write a file.
	local fp = io.open(path, mode or "w+");
	if fp == nil then return end
	fp:write(data);
	fp:flush();
	fp:close();
end

function files.read(path,mode) -- Read a file.
	local fp = io.open(path, mode or "r")
	if not fp then return nil end
	local data = fp:read("*a")
	fp:close()
	return data
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

-- Ajust string width w/newline char...
function wordwrap(text,width,w) 
	if not w then w = 1.0 end
	lines = 1                                     
	out = ""                                       
	int = ""                                      
  	for word in string.gmatch(text,"%S+") do       
    		if screen.textwidth (int.." "..word,w) > width then
      			out = out..'\n'                            
     			int = ""                                   
     			lines = lines + 1                         
    		end
  		out = out.." "..word                           
  		int = int.." "..word                           
  	end
  	return out                            
end
