assert(loadfile("/modules/global.lua", _ENV))()

local distanceTestClient = require("modules.distance_test_client")
distanceTestClient()
