package.path = package.path .. ";/?;/?.lua;/?/init.lua;/modules/?;/modules/?.lua;/modules/?/init.lua"

---@diagnostic disable: lowercase-global

hook = require("modules.hook")

---@diagnostic enable: lowercase-global

local destroyer = require("modules.destroyer")

destroyer()
