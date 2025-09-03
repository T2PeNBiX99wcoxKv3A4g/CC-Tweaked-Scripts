assert(loadfile("/modules/global.lua", _ENV))()

local elevator = require("modules.elevator")
elevator()
