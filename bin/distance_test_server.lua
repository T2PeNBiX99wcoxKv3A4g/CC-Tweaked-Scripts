assert(loadfile("/modules/global.lua", _ENV))()

local distanceTestServer = require("modules.distance_test_server")
distanceTestServer()
