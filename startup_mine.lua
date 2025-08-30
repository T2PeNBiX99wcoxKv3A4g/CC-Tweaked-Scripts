-- Rename to startup.lua to run at startup

local mine = require("mine")

---@diagnostic disable: lowercase-global
moveHelper = require("move_helper")
refuelHelper = require("refuel_helper")
logHelper = require("log_helper")
saveHelper = require("save_helper")
hook = require("hook")
vec3 = require("vector3")
---@diagnostic enable: lowercase-global

mine:init()
