assert(loadfile("/modules/global.lua", _ENV))()

local autoDoorServer = require("modules.automatic_door_server")
autoDoorServer()
