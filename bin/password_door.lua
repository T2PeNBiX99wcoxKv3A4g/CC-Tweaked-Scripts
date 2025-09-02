assert(loadfile("/modules/global.lua", _ENV))()

local door = require("modules.password_door")
door()
