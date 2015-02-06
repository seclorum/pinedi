
-- game messages
messages = {}
message_colors = {}
messages["goal"] = "try to stack.."
messages["purpose"] = "get all the pixels.."
messages["allsymstest"] = "<c:2CF>welcome<c>get<c:F52>all<c:2CF>pixels\n\n<c>ABCDEFGHIJKLMNOPQRSTUVWXYZ\nabcdefghijklmnopqrstuvwxyz\n0123456789\n .,:;!?()&/-'"
messages["pick"] = "info about picked object"
message_colors["console"] = "<c:222>"
messages["console"] = "console info here"
message_colors["pick"] = "<c:2CF>"
messages["hud_pick"] = "interaction with the HUD"
message_colors["hud_pick"] = "<c:F52>"
messages["welcome"] = messages["goal"] .. "\n" .. 
						messages["purpose"] .. "\n" .. 
						messages["allsymstest"] .. "\n" .. 
						message_colors["pick"] .. messages["pick"] .. "\n" .. 
						message_colors["hud_pick"] .. messages["hud_pick"] .."\n"

