assert(loadfile("/modules/global.lua", _ENV))()

local destroyer = require("modules.destroyer")
destroyer()
