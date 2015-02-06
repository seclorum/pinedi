-- pixels never die
MAIN_APP_NAME="pixelsneverdie"
-- some sort of game about proving the livelihood of
-- pixels.
--
-- main is where all main* tables are defined and used
-- including everything needed to boot up in order to
-- get to the game logic, use physics, do GUI, and so on.
--

-- resources point to the tables in resources/ where art
-- resources: png/ogg/3d*/etc. materials are found
-- resources defines a dictionary of actors in play
require ("resources/resources")

-- and so we start.
gameIsOver = false

print("appDefs.STAGE_WIDTH " .. appDefs.STAGE_WIDTH .. "appDefs.STAGE_HEIGHT " .. appDefs.STAGE_HEIGHT)
print("appDefs.GROUND_HEIGHT " .. appDefs.GROUND_HEIGHT .. "appDefs.GROUND_Y_POS " .. appDefs.GROUND_Y_POS)

-- set up the basics
MOAISim.openWindow ( MAIN_APP_NAME, appDefs.STAGE_WIDTH, appDefs.STAGE_HEIGHT )

mainViewport = MOAIViewport.new ()
mainViewport:setSize ( appDefs.STAGE_WIDTH, appDefs.STAGE_HEIGHT )
mainViewport:setScale ( appDefs.STAGE_WIDTH, appDefs.STAGE_HEIGHT )
--mainViewport:setOffset(-1, 1)

-- and now it is time for the camera:
mainCamera = MOAICamera.new ()
--mainCamera:moveLoc ( 256, 128, 1)
mainPartition = MOAIPartition.new ()

-- MOAI init: layers, box2d, HUD, &etc.
mainLayers = {}
mainLayers["HUD"] 			= MOAILayer2D.new()
mainLayers["tools"]			= MOAILayer2D.new()
mainLayers["main"] 			= MOAILayer2D.new()
mainLayers["background"] 	= MOAILayer2D.new()

table.all (mainLayers, function(gameLayer, index)
						 gameLayer:setViewport(mainViewport)
					   end )

-- just to be clear about priorities:
hudPriority = 1
mainGamePriority = 5
mainLayers["HUD"]:setPriority(hudPriority)
mainLayers["tools"]:setPriority(mainGamePriority)
mainLayers["main"]:setPriority(mainGamePriority)
mainLayers["background"]:setPriority(mainGamePriority + 10)

-- heads-up display / programmer console / ui thingy ..
require("hud")

-- game props
mainProps = {}

-- splash background
mainProps["background"] = MOAIProp2D.new ()
mainProps["background"].name = "background"
-- grid
mainProps["gridref"] = MOAIProp2D.new ()
mainProps["gridref"].name = "gridref"

mainProps["background"]:setDeck ( backgrounds["background"].quad )
mainProps["gridref"]:setDeck ( backgrounds["gridref_horizon"].quad )
mainProps["gridref"]:setPriority ( mainGamePriority - 1)

mainLayers["background"]:insertProp ( mainProps["background"] )
mainLayers["background"]:insertProp ( mainProps["gridref"] )

--mainPartition:insertProp(mainProps["background"])

-- text console
mainTextConsole = MOAITextBox.new()
mainTextConsole:setFont(fonts[defaultFont].font)
mainTextConsole:setTextSize(fonts[defaultFont].size)
--mainTextConsoleFont:getScale())

mainTextConsole:setString(messages["welcome"])

function msgLog()
	mainTextConsole:setString(message_colors["console"] .. messages["console"] .. "\n" .. messages["hud"] .. "\n" .. message_colors["pick"] .. messages["pick"] .. "\n" .. message_colors["hud_pick"] .. messages["hud_pick"])
end

mainTextConsole:setRect(-appDefs.STAGE_WIDTH/2, -(appDefs.STAGE_HEIGHT / 2) + fonts[defaultFont].size, (appDefs.STAGE_WIDTH / 2), (appDefs.STAGE_HEIGHT / 2))
print(" x1: " .. -appDefs.STAGE_WIDTH/2 .. " y1: " .. -(appDefs.STAGE_HEIGHT / 2) .. " x2:" .. 0 .. " y2: " .. (appDefs.STAGE_HEIGHT / 2))
mainTextConsole:setYFlip(true)

mainLayers["main"]:insertProp(mainTextConsole)
mainPartition:insertProp ( mainTextConsole )

-- layer system
mainLayers["main"]:setPartition ( mainPartition )

mainGameRenderables = {}
mainGameRenderables[#mainGameRenderables+1] = mainLayers["background"]
mainGameRenderables[#mainGameRenderables+1] = mainLayers["main"]
mainGameRenderables[#mainGameRenderables+1] = mainLayers["tools"]
mainGameRenderables[#mainGameRenderables+1] = mainLayers["HUD"]

MOAIRenderMgr.setRenderTable(mainGameRenderables)

-- squeek! try to touch the mouse.
mouseX = 0
mouseY = 0
-- hud is active
-- hud_hide()
hud_setup_UI()
-- say hi
hud_show()

showGrid = false
shouldDebugBox2D = false

require("userdata")
-- physics is active
require("physics")

--if shouldDebugBox2D then
	mainLayers["main"]:setBox2DWorld(physBoxWorld)
--end

function onResize ( width, height )
    mainViewport:setSize ( width or STAGE_WIDTH, height or STAGE_HEIGHT )
    mainViewport:setScale ( width or STAGE_WIDTH, height or STAGE_HEIGHT )
end

MOAIGfxDevice.setListener ( MOAIGfxDevice.EVENT_RESIZE, onResize )

onResize(STAGE_WIDTH, STAGE_HEIGHT)

--
function pointerCallback ( x, y )

	local oldX = mouseX
	local oldY = mouseY

	mouseX, mouseY = mainLayers["background"]:wndToWorld ( x, y )
	hud_lastX, hud_lastY = hudX, hudY
	hudX, hudY =  mainLayers["HUD"]:wndToWorld(x, y)

--	pick = mainPartition:propForPoint ( mouseX, mouseY )

	if pick then
		messages["pick"] = "pointerpick: " .. (pick.name or ":noname:") .. table.show(pick, "pick:")

		if pick.body ~= nil then
			if pick.name ~= "crosshairs" then
				pick.body:setTransform(mouseX, mouseY)
			end
		end

		msgLog()

	end
end

-- note that this is the main callback - HUD events are handled here too
-- TODO: Utterly re-write the event handling nature of this function !J!
function clickCallback ( down )
	pick = mainPartition:propForPoint ( mouseX, mouseY ) -- 0, MOAILayer.SORT_PRIORITY_ASCENDING )
	hud_pick = hudPartition:propForPoint ( hudX, hudY ) -- 0, MOAILayer.SORT_PRIORITY_ASCENDING )

	if down then
		-- item was selected from the programmer menu
		if pick then	--	 a non-HUD selection was made ..

			messages["pick"] = "clickpick: " .. (pick.name or ":noname:") .. table.show(pick, "pick:")

			pick:setPriority ( mainGamePriority )
			mainGamePriority = mainGamePriority + 1
	--pick:moveScl ( 0.25, 0.25, 0.125, MOAIEaseType.EASE_IN )
			messages["console"] = "console: pick: " .. table.show( pick, (pick.name or ":noname:"))

			user_data.saved_points = hudDrawPoints
			sync_user_data()
		end
		if hud_pick then
			messages["hud_pick"] = "hud_pick: " .. (hud_pick.name or ":noname:") .. " obj: " .. table.show(hud_pick, "hud_pick:")
			if hud_pick.name == "makephysedges" then
				if (hudIsDrawingPoints) then
					addEdgesToWorld(hudDrawPoints)
					hudDrawPoints = {}
					hudIsDrawingPoints = false
				else
					hudIsDrawingPoints = true
				end
			end
		end
		if hudIsDrawingPoints then
			print('lastX: ' .. hud_lastX .. ' lastY: ' .. hud_lastY .. ' hudX: ' .. hudX .. ' hudY: ' .. hudY)
			table.insert ( hudDrawPoints, hudX )
			table.insert ( hudDrawPoints, hudY )
			hud_lastX = hudX
			hud_lastY = hudY
		end

	else -- up b
		if pick then
	--pick:moveScl ( -0.25, -0.25, 0.125, MOAIEaseType.EASE_IN )
			pick = nil
			messages["pick"] = "pick: <nix>"
		end

		if hud_pick then
			--hud_pick:moveScl ( -0.25, -0.25, 0.125, MOAIEaseType.EASE_IN )
			messages["hud_pick"] = "hud_pick: <HUD>" .. hud_pick.name .. " obj: " .. table.show(hud_pick, "hud_pick:")

			if hud_pick.name == "home" then
				if hud_visible == true then
					hud_hide()
				else
					hud_show()
				end
			end
			if hud_pick.name == "reset" then
				reset = 1
				hudDrawPoints = {}
				-- histogram
				MOAISim.setHistogramEnabled(true)
				MOAISim.reportHistogram()
			end
			if hud_pick.name == "makephysedges" then

			end
			if hud_pick.name == "showGrid" then
				if showGrid == true then
					showGrid = false
					MOAIDebugLines.setStyle ( MOAIDebugLines.PARTITION_CELLS, 2, 1, 1, 1 )
					MOAIDebugLines.setStyle ( MOAIDebugLines.PARTITION_PADDED_CELLS, 1, 0.5, 0.5, 0.5 )
					MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 0.75, 0.75, 0.75 )

					mainLayers["background"]:insertProp(mainProps["gridref"])
				else
					showGrid = true
					MOAIDebugLines.showStyle(MOAIDebugLines.PARTITION_CELLS, false)
					MOAIDebugLines.showStyle(MOAIDebugLines.PARTITION_PADDED_CELLS, false)
					MOAIDebugLines.showStyle(MOAIDebugLines.PROP_WORLD_BOUNDS, false)

					mainLayers["background"]:removeProp(mainProps["gridref"])
				end
			end

		end

		msgLog()

	end

end

if MOAIInputMgr.device.pointer then
	-- mouse input
	MOAIInputMgr.device.pointer:setCallback ( pointerCallback )
	MOAIInputMgr.device.mouseLeft:setCallback ( clickCallback )
else
	-- touch input
	MOAIInputMgr.device.touch:setCallback (

		function ( eventType, idx, x, y, tapCount )
			pointerCallback ( x, y )
			if eventType == MOAITouchSensor.TOUCH_DOWN then
				clickCallback ( true )
			elseif eventType == MOAITouchSensor.TOUCH_UP then
				clickCallback ( false )
			end
		end
	)
end

function gameActionTimeLine ()
    -- we yield, and mainAction yields too
    local function yieldWhile ( action )
        while action:isBusy () do coroutine:yield () end
    end
    -- shift game objects around a bit, examples
	--mainProps["background"]:setScl(2.0, 2.0)
	--mainProps["background"]:setLoc(-1,0)
	--mainProps["background"]:moveRot(45, 5)
	--mainProps["background"]:moveLoc(64,0,1.5)
	--mainProps["background"]:moveScl(1,2,1.5)
    --yieldWhile ( mainProps["background"]:moveRot ( 360, 1.5 ))
    --yieldWhile ( mainProps["background"]:moveRot ( 360, 5 ))
    --yieldWhile ( mainProps["background"]:moveRot ( 360, 10 ))
    --yieldWhile ( mainProps["background"]:moveRot ( 360, 15 ))
    --yieldWhile ( mainProps["background"]:moveLoc ( 1.5, 0, 1 ))
    --yieldWhile ( mainProps["background"]:moveScl ( 1.5, 1.5, 1 ))
    --yieldWhile ( mainProps["background"]:moveScl ( 0.2, 0.15, 2 ))
    -- table.all(mainProps, function (prop)
    -- 	yieldWhile ( prop:moveRot( 45, 0.125) )
    -- 	yieldWhile ( prop:moveScl( 2, 2, 0.25) )
    -- 	yieldWhile ( prop:moveScl( -2, -2, 1.25) )
    -- 	yieldWhile ( prop:moveRot( -45, 0.125) )
    -- end)
	-- yieldWhile ( mainProps["stand5"]:moveLoc( 64, 0, 1.5) )
	-- yieldWhile ( mainProps["stand5"]:moveRot( 45, 1) )
	-- yieldWhile ( mainProps["stand5"]:moveRot( 45, 2) )
	-- yieldWhile ( mainProps["stand5"]:moveRot( 45, 3) )
	-- yieldWhile ( mainProps["stand5"]:moveRot( 45, 4) )
	-- yieldWhile ( mainProps["stand5"]:moveRot( 45, 5) )
    --yieldWhile ( mainProps["background"]:moveScl ( 1.5, 1.5, 10 ))
    --yieldWhile ( mainProps["background"]:moveScl ( 1.5, 1.5, 15 ))

end

function gameMainAct()
	local lframes = 0   --

	while not gameIsOver do
		coroutine.yield ()
		lframes = lframes + 1
		if (reset == 1) then
			-- TODO: Level reset ..
			-- TODO: +Levels, at all..
			MOAISim.setHistogramEnabled(false)
			reset = 0
		end
		-- AI, stages, levels, etc.
	end
end

if (user_data.new_edges ~= nil) then
	addEdgesToWorld(user_data.new_edges)
end


local gameActionThread = MOAIThread.new ()
gameActionThread:run ( gameActionTimeLine )

local gameMainThread = MOAIThread.new ()
gameMainThread:run ( gameMainAct )

-- table.all(lorc_art, function (lorc, index)
-- 	dropASoul(lorc)
-- end)
table.all(souls, function (soul, index)
	dropASoul(soul)
end)
--dropASoul("caspas_muetze")
