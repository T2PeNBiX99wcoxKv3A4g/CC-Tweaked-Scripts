-- Rename to startup.lua to run at startup

---@diagnostic disable: lowercase-global

vec3 = require("vector3")
hook = require("hook")
logHelper = require("log_helper")
fileHelper = require("file_helper")
refuelHelper = require("refuel_helper")
moveHelper = require("move_helper")

---@diagnostic enable: lowercase-global

local bridgeBuilder = require("bridge_builder")

bridgeBuilder:init()
