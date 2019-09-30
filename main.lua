package.path = package.path .. ';' .. love.filesystem.getSource() .. '/lua_modules/share/lua/5.1/?.lua'

require "pixelate" ()

local TILES_W = 24
local TILES_H = 24
local TILE_SIZE = 8
local CANVAS_SCALE = 3

local table2 = require "table2"
local state = require "state"

local nowState = state.player

local caveCanvas
local magicCanvas
local textCanvas

local cave
local level = 1

local player = require "player" : new()
local stairs = require "stairs" : new(0, 0)
local enemies = {}

local returnKey = require "key" : new("return")
--font = love.graphics.newFont("assets/fonts/pizerif.ttf", 10)
--font = love.graphics.newFont("assets/fonts/pop.ttf", 8)



function resetLevel(level)
	cave = require "cave" : new(TILES_W + math.floor(level / 2), TILES_H + math.floor(level / 2))
	local ban = {}
	putStairs(cave, ban)
	putPlayer(cave, ban, stairs)
	putEnemies(cave, ban, level + 2)
end

function putStairs(cave, ban)
	stairs.x, stairs.y = cave:getEmptyAtRandom(ban)
	table.insert(ban, {x = stairs.x, y = stairs.y})
end

function putPlayer(cave, ban, stairs)
	local x, y
	while true do
		x, y = cave:getEmptyAtRandom(ban)
		if cave:checkLink(x, y, stairs.x, stairs.y) then break end
	end
	player.x, player.y = x, y
	table.insert(ban, {x = x, y = y})
end

function putEnemies(cave, ban, length)
	enemies = {}
	for i=1,length do
		local x, y = cave:getEmptyAtRandom(ban)
		enemies[i] = require "enemy" :new(x, y)
		table.insert(ban, {x = x, y = y})
	end
end



function love.load(arg)

	love.window.setTitle( "MADOU" )
	--, borderless=true
	print(TILE_SIZE*(15 + 4)*CANVAS_SCALE, TILE_SIZE*15*CANVAS_SCALE +( 6*5 + 2) *CANVAS_SCALE)
	--love.window.setMode(TILE_SIZE*(15 + 4)*CANVAS_SCALE, TILE_SIZE*15*CANVAS_SCALE +( 6*5 + 2) *CANVAS_SCALE, {highdpi= true, resizable=false, borderless=true})
	caveCanvas = love.graphics.newCanvas(TILE_SIZE*15, TILE_SIZE*15)
	caveCanvas:setFilter('nearest')

	magicCanvas = love.graphics.newCanvas(TILE_SIZE*4, TILE_SIZE*15)
	magicCanvas:setFilter('nearest')

	textCanvas = love.graphics.newCanvas(TILE_SIZE*(15 + 4)*CANVAS_SCALE, 6*5 + 2)
	textCanvas:setFilter('nearest')

	love.graphics.setBackgroundColor(68/255, 68/255, 41/255)

	resetLevel(level)
	require "audio".source.bgm1:setVolume(0.3)
	require "audio".source.bgm2:setVolume(0.0)
	require "audio".play "bgm1"
	require "audio".play "bgm2"

end

function love.update(dt)
	player:update(dt)

	for _, enemy in ipairs(enemies) do
		enemy:update(dt)
	end

	if nowState == state.player then
		nowState = player:phase(dt, cave, stairs, enemies)
	elseif nowState == state.enemy then
		local enemyIsMoving = false
		for _, enemy in ipairs(enemies) do
			enemyIsMoving = enemyIsMoving or enemy:isMoving()
		end
		if not enemyIsMoving then
			for _, enemy in ipairs(enemies) do
				enemy:prePhase(cave, player, enemies)
			end

			for _, enemy in ipairs(enemies) do
				enemy:phase(dt, cave, player, enemies)
			end

			for _, e in ipairs(enemies) do
				if e.x == player.x and e.y == player.y then
					nowState = state.gameover
					return
				end
			end
			nowState = state.player
		end
	elseif nowState == state.levelchange then
		level = level + 1
		resetLevel(level)
		nowState = state.player
	elseif nowState == state.gameover then
		require "audio".source.bgm1:setVolume(0.0)
		require "audio".source.bgm2:setVolume(0.3)
		player:dying()

		returnKey:update(dt)
		if returnKey:isDowner() then
			require "audio".source.bgm1:setVolume(0.3)
			require "audio".source.bgm2:setVolume(0.0)
			level = 1

			player:reset()

			resetLevel(level)
			nowState = state.player
		end
	end
end


local function positionFromCamera(camera, s, w, h)
	return function (x, y)
		return w / 2 + s * (x - 1 - camera.x)-camera.ox, h / 2 + s * (y - 1 - camera.y)-camera.oy
	end
end


local magic = require "magic"

function love.draw()

	love.graphics.setFont(require "fonts".white)

  love.graphics.setCanvas(caveCanvas)
	local pos = positionFromCamera({x = player.x - 0.5, y = player.y - 0.5, ox=player.ox, oy=player.oy}, TILE_SIZE, caveCanvas:getWidth(), caveCanvas:getHeight())
	-- cave
	cave:draw(pos)

	-- stairs
	stairs:draw(pos)

	-- enemies
	local dying = {}
	for i,e in ipairs(enemies) do
		dying[i] = e.animKey == "dying"
		if not dying[i] then
			e:draw(pos)
		end
	end

	for i,e in ipairs(enemies) do
		if dying[i] then
			e:draw(pos)
		end
	end

	-- player
	player:draw(pos)

	love.graphics.setColor(1, 1, 1)

	if nowState == state.gameover then
		--[[
		local txt = "gameover"
		love.graphics.setColor(68/255, 68/255, 41/255)
		love.graphics.rectangle("fill", 45-2, 83-2, #txt * 4 + 3, 8)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(txt, 45, 83)]]
		local dy = math.floor(math.cos(love.timer.getTime() * math.pi /1.875 *4))
		txt = "press return key to restart."
		love.graphics.setColor(68/255, 68/255, 41/255)
		love.graphics.rectangle("fill", 5-2, 94-2 + dy, #txt * 4, 7)
		love.graphics.setColor(1, 1, 1)
		love.graphics.print(txt, 5, 94 + dy)
	end



	local l_txt = level.."F"
	love.graphics.setColor(68/255, 68/255, 41/255)
	love.graphics.rectangle("fill", 118 - #l_txt * 4, 0, #l_txt * 4 + 2, 6)
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(l_txt, 1 + 118 - #l_txt * 4, 1)

	love.graphics.setCanvas()

	love.graphics.setCanvas(magicCanvas)
	require "magicUI" (player.mp, player.maxMp, level)
	love.graphics.setCanvas()

	love.graphics.setCanvas(textCanvas)
	require "textUI" (player.mp, player.maxMp)
	love.graphics.setCanvas()


	love.graphics.push()
	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
	love.graphics.scale(CANVAS_SCALE, CANVAS_SCALE)
	love.graphics.draw(caveCanvas, 32)
	love.graphics.pop()

	love.graphics.push()
	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
	love.graphics.scale(CANVAS_SCALE, CANVAS_SCALE)
	love.graphics.draw(magicCanvas)
	love.graphics.pop()

	love.graphics.push()
	love.graphics.setColor(1.0, 1.0, 1.0, 1.0)
	love.graphics.scale(CANVAS_SCALE, CANVAS_SCALE)
	love.graphics.draw(textCanvas, 0, caveCanvas:getHeight())
	love.graphics.pop()
end
