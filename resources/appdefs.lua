--defaults.lua
appDefs = {}

-- dpi of iPad Mini Retina, design target
appDefs.dDPI = 220
appDefs.tDPI = MOAIEnvironment.DPI or 326

appDefs.dp2px = function(dp)
    return dp * (appDefs.dDPI / appDefs.tDPI)
end

appDefs.DPI = appDefs.dp2px(appDefs.dDPI / appDefs.tDPI)


-- TODO: replace with device-specific proportions.
-- Apple select 'minimum'
appDefs.SELECT_WIDTH = appDefs.dp2px(44)
appDefs.SELECT_HEIGHT = appDefs.dp2px(44)
appDefs.SELECT_SPIN_SPEED = 0.125
-- Microsoft
-- appDefs.SELECT_WIDTH = 34
-- appDefs.SELECT_HEIGHT = 26

-- iPad Mini Retina design target
appDefs.STAGE_WIDTH =  MOAIEnvironment.horizontalResolution or 2048 / 2
appDefs.STAGE_HEIGHT =  MOAIEnvironment.verticalResolution or 1536 / 2

appDefs.GROUND_HEIGHT = appDefs.STAGE_HEIGHT / (appDefs.STAGE_HEIGHT / 2)
appDefs.GROUND_Y_POS = -(appDefs.STAGE_HEIGHT / 2) + appDefs.GROUND_HEIGHT
appDefs.SKY_Y_POS = (appDefs.STAGE_HEIGHT / 2) - appDefs.GROUND_HEIGHT

appDefs.SOUL_WIDTH = appDefs.SELECT_WIDTH
appDefs.SOUL_HEIGHT = appDefs.SELECT_WIDTH
appDefs.SOUL_SPAN = appDefs.SOUL_WIDTH / 2
appDefs.HUD_X_POS = -320
appDefs.HUD_Y_POS = 0.5
appDefs.HUD_WIDTH = appDefs.SELECT_WIDTH * 2
appDefs.HUD_SPAN = appDefs.HUD_WIDTH / 2
appDefs.HUD_SPIN_SPEED = appDefs.SELECT_SPIN_SPEED
