-- Rename to startup.lua to run at startup

local mine = require("mine")

---@diagnostic disable: lowercase-global
moveHelper = require("move_helper")
refuelHelper = require("refuel_helper")
hook = require("hook")
---@diagnostic enable: lowercase-global

mine:init()
