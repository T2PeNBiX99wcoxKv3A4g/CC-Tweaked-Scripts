-- Rename to startup.lua to run at startup

---@diagnostic disable: lowercase-global

vec3 = require("vector3")
hook = require("hook")
logHelper = require("log_helper")
saveHelper = require("save_helper")
refuelHelper = require("refuel_helper")
moveHelper = require("move_helper")

---@diagnostic enable: lowercase-global

local mine = require("mine")

mine:init()
