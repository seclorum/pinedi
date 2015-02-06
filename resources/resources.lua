
-- set up resources: decks, quads, etc.

require("resources/env_debug")
require("resources/lua-enumerable")
-- use table.all() for sometable["index"]-style tables, and table.each() for sometable.somefield style

dump_environment_details()

require("resources/appdefs")

require("resources/anims")
require("resources/backgrounds")
require("resources/natures")
require("resources/souls")
require("resources/lorc_art")
require("resources/vehicles")
require("resources/fonts")
require("resources/messages")
require("resources/hudGUI")


function callWithDelay ( delay, func,...)
  local timer = MOAITimer.new ()
  timer:setSpan ( delay )
  timer:setListener ( MOAITimer.EVENT_TIMER_LOOP,
    function ()
      --timer:stop ()
      --timer = nil
      func ( unpack ( arg ))
    end
  )
  timer:start ()
end

table.all(anims, function (anim, index)
						anim.name = index
						anim.quad:setTexture ( anim.pngfile)
						anim.quad:setRect ( anim.x1, anim.y1, anim.x2, anim.y2)
-- TODO: strips, &etc.
					  end)

table.all(hudGUI, function (hudG, index)
						hudG.name = index
						hudG.quad:setTexture ( hudG.pngfile)
print("hudG coords:", hudG.x1, hudG.y1, hudG.x2, hudG.y2)
						hudG.quad:setRect ( hudG.x1, hudG.y1, hudG.x2, hudG.y2)
					  end)

table.all(backgrounds, function (background, index)
						background.name = index
						background.quad:setTexture ( background.pngfile)
						background.quad:setRect ( background.x1, background.y1, background.x2, background.y2)
					  end)

table.all(natures, function (nature, index)
						nature.name = index
						nature.quad:setTexture ( nature.pngfile)
						nature.quad:setRect ( nature.x1, nature.y1, nature.x2, nature.y2)
					  end)
table.all(lorc_art, function (lorc, index)
                        lorc.name = index
                        -- default deck (isaquad)
                        lorc.quad:setTexture ( lorc.pngfile)
                        lorc.quad:setRect ( lorc.x1, lorc.y1, lorc.x2, lorc.y2)
                        -- default prop
                        lorc.prop.name = index
                        lorc.prop:setDeck ( lorc.quad )
                      end)

table.all(souls, function (soul, index)
	print("soul named: ", index)
						soul.name = index
						-- default deck (isaquad)
						soul.quad:setTexture ( soul.pngfile)
						soul.quad:setRect ( soul.x1, soul.y1, soul.x2, soul.y2)
						-- default prop
						soul.prop.name = index
						soul.prop:setDeck ( soul.quad )
					  end)

table.all(vehicles, function (vehicle, index)
						vehicle.name = index
						vehicle.quad:setTexture ( vehicle.pngfile)
						vehicle.quad:setRect ( vehicle.x1, vehicle.y1, vehicle.x2, vehicle.y2)
					  end)

table.all(fonts, function(afont, index)
						afont.name = index
						afont.font:loadFromTTF(afont.ttf, afont.textcodes, afont.size, afont.dpi)
					end )

