-- Rename to startup.lua to run at startup

package.path = package.path .. ";/?;/?.lua;/?/init.lua;/modules/?;/modules/?.lua;/modules/?/init.lua"

local door = require("modules.password_door")

door()
