assert(loadfile("/modules/global.lua", _ENV))()

local zephyrKiller = require("modules.zephyr_killer")
zephyrKiller()
