assert(loadfile("/modules/global.lua", _ENV))()

local bridgeBuilder = require("modules.bridge_builder")
bridgeBuilder()
