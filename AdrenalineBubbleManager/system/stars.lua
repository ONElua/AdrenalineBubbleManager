--[[ 
	Particles FX library.
	Draw a shower of particles.
	
	Licensed by GNU General Public License v3.0
	
	Designed By:
	- DevDavisNunez (https://twitter.com/DevDavisNunez).

	Modes:
	- "snow" : white (December)
	- "mx"   : green / white / red (16 September)
]]

stars = {math={}} -- module stars! :D

-- Mx: verde, blanco, rojo
local COL_GREEN = color.new(0, 104, 71)
local COL_WHITE = color.new(255, 255, 255)
local COL_RED   = color.new(206, 17, 38)

function stars.init(mode)
	math.randomseed(os.clock())
	mode = mode or "snow"

	local palette
	if mode == "mx" then
		palette = { COL_GREEN, COL_WHITE, COL_RED }
	else
		-- default snow
		palette = { COL_WHITE }
	end

	stars.mode = mode
	stars.math = {}
	for i=1,100 do
		stars.math[i] = {
			x = math.random(0,960),
			y = math.random(0,544),
			s = (math.random(0,3) + math.random(0,2)),
			a = math.random(0,255),
			c = palette[math.random(1, #palette)]
		}
	end
end

function stars.render()
	for i=1,100 do
		stars.math[i].y += stars.math[i].s
		stars.math[i].a -= 1
		if stars.math[i].y >= 544 then
			stars.math[i].x = math.random(0,960)
			stars.math[i].y = 0
		end
		if stars.math[i].a <= 0 then
			stars.math[i].a = 255
		end
		draw.circle(stars.math[i].x, stars.math[i].y, 3, stars.math[i].c:a(stars.math[i].a))
	end
end

-- default until script.lua calls stars.init with the right mode
stars.init("snow")
