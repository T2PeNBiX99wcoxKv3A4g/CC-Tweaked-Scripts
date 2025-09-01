-- Rename to startup.lua to run at startup

---@diagnostic disable: lowercase-global

hook = require("modules.hook")

---@diagnostic enable: lowercase-global

local destroyer = require("modules.destroyer")

destroyer()
