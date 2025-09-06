assert(loadfile("/modules/global.lua", _ENV))()

local protector = require("modules.protector")
protector()
