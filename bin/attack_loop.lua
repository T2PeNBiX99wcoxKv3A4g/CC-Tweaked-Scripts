package.path = package.path .. ";/?;/?.lua;/?/init.lua;/modules/?;/modules/?.lua;/modules/?/init.lua"

local attack = require("modules.attack_loop")

attack()
