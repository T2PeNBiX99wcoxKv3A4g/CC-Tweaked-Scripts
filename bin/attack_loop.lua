assert(loadfile("/modules/global.lua", _ENV))()

local attack = require("modules.attack_loop")
attack()
