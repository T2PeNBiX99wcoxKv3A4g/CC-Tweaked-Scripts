assert(loadfile("/modules/global.lua", _ENV))()

local mine = require("modules.mine")
mine()
