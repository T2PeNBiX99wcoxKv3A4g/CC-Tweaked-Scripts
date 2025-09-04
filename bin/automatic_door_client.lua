assert(loadfile("/modules/global.lua", _ENV))()

local autoDoorClient = require("modules.automatic_door_client")
autoDoorClient()
