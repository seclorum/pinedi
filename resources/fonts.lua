
-- application fonts
local asciiTextCodes = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-'

fonts = {}
fonts["latobol"] 			= {ttf='resources/fonts/Lato-Bol.ttf', textcodes=asciiTextCodes, font=MOAIFont.new(), size=12, dpi=163}

defaultFont = "latobol"

