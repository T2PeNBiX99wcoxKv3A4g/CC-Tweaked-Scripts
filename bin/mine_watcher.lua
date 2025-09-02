assert(loadfile("/modules/global.lua", _ENV))()

local mineWatcher = require("modules.mine_watcher")
mineWatcher()
