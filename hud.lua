--
-- hud - requires mainLayers["HUD"] to be managed elsewhere.. and
-- for all HUD event handling to be done in main.lua along with the
-- other event for the app..
--
hudProps   = {}
btnProps   = {}
hudDecks   = {}
hud_visible   = false

-- where the HUD should go
HUD_X_POS         = appDefs.HUD_X_POS
HUD_Y_POS         = appDefs.HUD_Y_POS

hudX = 0
hudY = 0
hud_lastX = 0
hud_lastY = 0

-- The HUD can use its own physics if it wishes
hudPolygons = {}
hudBodies = {}
hudFixtures = {}

-- note: we assume mainLayers["HUD"] is initialized for us..
hudPartition = MOAIPartition.new()
mainLayers["HUD"]:setPartition(hudPartition)

-- Deck to draw the crosshairs/points with 2D methods
hudDecks["crosshairs"] = MOAIScriptDeck.new()
hudDecks["drawpoints"] = MOAIScriptDeck.new()

hudDrawPointsPriority = 5
hudCrossHairsPriority = 5
hudButtonsPriority = 50
hudDrawPoints = { }
hudIsDrawingPoints = false

hudBoxWorld = MOAIBox2DWorld.new ()

function hud_crosshairs_script(index, xOff, yOff, xScale, yScale)
--for _, id in ipairs{touchSensor:getActiveTouches()} do
--	local hudX, hudY = touchSensor:getTouch(id)
--end TODO: Make Multi-Touch

	-- draw the HUD crosshairs
	MOAIGfxDevice.setPenColor(1, 1, 1, 0.75)
	MOAIDraw.fillCircle (hudX, hudY, 10, 10)
	MOAIGfxDevice.setPenColor(0, 0, 1, 0.75)
	MOAIGfxDevice.setPenWidth(2)
	MOAIDraw.drawLine (hudX, -appDefs.STAGE_WIDTH, hudX, appDefs.STAGE_HEIGHT)
	MOAIDraw.drawLine (-appDefs.STAGE_WIDTH, hudY, appDefs.STAGE_HEIGHT, hudY)
	messages["hud"] = "hudX:" .. hudX .. " hudY: " .. hudY .. table.show(hudDrawPoints, "drawpoints")

end

function hud_drawpoints_script(index, xOff, yOff, xScale, yScale)
	-- draw the DrawPoints if there are any ..
	MOAIGfxDevice.setPenColor(0, 1, 1, 0.75)
	MOAIGfxDevice.setPenWidth(8)
    MOAIDraw.drawLine ( unpack ( hudDrawPoints ) )
end


function hud_setup_crosshairs()
	--local touchSensor = MOAIInputMgr.device.touch
	hudDecks["crosshairs"]:setDrawCallback(hud_crosshairs_script)
	hudDecks["crosshairs"]:setRect(-appDefs.STAGE_WIDTH, -appDefs.STAGE_HEIGHT, appDefs.STAGE_WIDTH, appDefs.STAGE_HEIGHT)
	hudProps["crosshairs"] = MOAIProp2D.new()
	hudProps["crosshairs"]:setDeck(hudDecks["crosshairs"])
	hudProps["crosshairs"]:setPriority(hudCrossHairsPriority)
	hudProps["crosshairs"].name = "crosshairs"
	hudProps["crosshairs"]:setBlendMode(MOAIProp2D.BLEND_ADD)
	--hudPartition:insertProp(hudProps["crosshairs"])
	mainLayers["HUD"]:insertProp(hudProps["crosshairs"])
end

function hud_setup_drawpoints()
	hudDecks["drawpoints"]:setDrawCallback(hud_drawpoints_script)
	hudDecks["drawpoints"]:setRect(-appDefs.STAGE_WIDTH, -appDefs.STAGE_HEIGHT, appDefs.STAGE_WIDTH, appDefs.STAGE_HEIGHT)
	hudProps["drawpoints"] = MOAIProp2D.new()
	hudProps["drawpoints"]:setDeck(hudDecks["drawpoints"])
	hudProps["drawpoints"]:setPriority(hudDrawPointsPriority)
	hudProps["drawpoints"].name = "drawpoints"
	hudProps["drawpoints"]:setBlendMode(MOAIProp2D.BLEND_ADD)
	mainLayers["tools"]:insertProp(hudProps["drawpoints"])
end

function hud_setup_UI()
	hud_setup_drawpoints()
	hud_setup_crosshairs()
end

-- put the HUD somewhere
function hud_setXY(x, y)
	local hud_was_visible = hud_visible or true
	HUD_X_POS, HUD_Y_POS = x,y
	hud_hide()

	if hud_was_visible then
		hud_show()
	end
end

-- hide the HUD
function hud_hide()
	table.all(btnProps, function (btnProp, i)
		-- TODO: find a better way to do this
		if ((i ~= "home")  and (i ~= "crosshairs") and i ~= "drawpoints") then
			print("1 btnProp modified: " .. i)
			-- btnProp:setScl(2, 2)
			btnProp:seekLoc(HUD_X_POS, HUD_Y_POS, appDefs.SELECT_SPIN_SPEED)
			btnProp:moveRot(180, appDefs.HUD_SPIN_SPEED)
		end

		if (i == "home") then
			print("1btnProp home modified: " .. i)
			-- btnProp:setScl(2, 2)
			btnProp:seekLoc(HUD_X_POS, HUD_Y_POS, appDefs.SELECT_SPIN_SPEED)
		end
	end)
	hud_visible = false
end

-- show the HUD
function hud_show()
	bpos = 1
	menuAngleTot = 45
	table.all(btnProps, function (btnProp, i)
		if ((i ~= "home") and (i ~= "crosshairs") and (i ~= "drawpoints")) then
			print("2btnProp modified: " .. i)
			-- btnProp:setScl(2, 2)
			btnProp:setLoc( HUD_X_POS, HUD_Y_POS )
			btnProp:moveRot(180, appDefs.HUD_SPIN_SPEED)
			btnProp:moveLoc(math.sin(bpos * menuAngleTot) * 4.75 * 8, math.cos(bpos * menuAngleTot) * 4.75 * 8, appDefs.SELECT_SPIN_SPEED)
			bpos = bpos + 1
		end
		if (i == "home") then
			print("2btnProp modified: " .. i)
			btnProp:setPriority(hudButtonsPriority)
		end
	end)
	hud_visible = true
end

-- add a button to the HUD
function hud_add_button(hudGUIname, button_name, priority)

	-- get to the end of the table
	bpos = 1
	for i in pairs(btnProps) do
		bpos=bpos+1
	end
	print ("hudGUIName: " .. hudGUIname .. " button_name: " .. button_name .. "\n")
	btnProps[button_name] = MOAIProp2D.new()
	btnProps[button_name]:setParent(hudBodies[button_name])

	btnProps[button_name]:setDeck(hudGUI[hudGUIname].quad)
	btnProps[button_name]:setLoc ( HUD_X_POS, HUD_Y_POS )
	-- btnProps[button_name]:setScl(1.8, 1.8)

	btnProps[button_name].name = button_name
	btnProps[button_name].btn_num = bpos

    btnProps[button_name].textbox = MOAITextBox.new ()
    btnProps[button_name].textbox:setParent(btnProps[button_name])
    btnProps[button_name].textbox:setLoc ( HUD_X_POS, HUD_Y_POS )
    btnProps[button_name].textbox:setString (button_name ) --"<c:F52>" ..
    btnProps[button_name].textbox:setFont (fonts[defaultFont].font)
	btnProps[button_name].textbox:setTextSize(fonts[defaultFont].size)
    btnProps[button_name].textbox:setRect ( -80, -40, 80, 40 )
    btnProps[button_name].textbox:setYFlip ( true )

    btnProps[button_name].textbox:setAttrLink(MOAITransform.ATTR_X_LOC, btnProps[button_name], MOAITransform.ATTR_WORLD_X_LOC)
    btnProps[button_name].textbox:setAttrLink(MOAITransform.ATTR_Y_LOC, btnProps[button_name], MOAITransform.ATTR_WORLD_Y_LOC)
    btnProps[button_name].textbox:setAttrLink(MOAITransform.INHERIT_LOC, btnProps[button_name], MOAITransform.ATTR_WORLD_X_LOC)
    btnProps[button_name].textbox:setAttrLink(MOAITransform.INHERIT_LOC, btnProps[button_name], MOAITransform.ATTR_WORLD_Y_LOC)

	btnProps[button_name]:setPriority(priority)

	-- hudBodies[button_name] = hudBoxWorld:addBody( MOAIBox2DWorld.DYNAMIC )
	-- hudBodies[button_name]:setTransform()
	-- hudFixtures[button_name] = hudBodies[button_name]:addRect ( - math.random ( 10, 20 ), - math.random ( 10, 30 ),  math.random ( 10, 30 ),  math.random ( 10, 15 ) )
	-- btnProps[button_name]:setParent(hudBodies[button_name])
	--[[
	menuAngleTot = 45
	if (button_name ~= "home") then
		btnProps[button_name]:moveRot(360, 0.75)
		btnProps[button_name]:moveLoc(math.sin(bpos * menuAngleTot) * 4.75,
		math.cos(bpos * menuAngleTot) * 4.75, 0.75)
	end
	]]
	hudPartition:insertProp(btnProps[button_name])
	mainLayers["HUD"]:insertProp(btnProps[button_name])
end

mainLayers["HUD"]:setBox2DWorld(hudBoxWorld)

if (hudBoxWorld ~= nil) then
	hudBoxWorld:setGravity ( -0, -9 )
	hudBoxWorld:setUnitsToMeters ( 1/30, 10 )
	hudBoxWorld:start ()
else
	print("hudBoxWorld: nil")
end

hud_add_button("spacebutton", "reset", hudButtonsPriority - 5)
hud_add_button("flightbutton", "makephysedges", hudButtonsPriority - 5)
hud_add_button("islandbutton", "showGrid", hudButtonsPriority - 5)
hud_add_button("homebutton", "home", hudButtonsPriority)

hud_visible = true
hud_setXY(appDefs.HUD_X_POS, appDefs.HUD_Y_POS)
