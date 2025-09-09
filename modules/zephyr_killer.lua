local expect              = require("cc.expect")
local expect, range       = expect.expect, expect.range

local class               = require("modules.class")
local vec3                = require("modules.vector3")
local angle               = require("modules.angle")
local fileHelper          = require("modules.file_helper")
local refuelHelper        = require("modules.refuel_helper")
local logHelper           = require("modules.log_helper")
local utils               = require("modules.utils")

---@class zephyrKiller
local zephyrKiller        = class("zephyrKiller")

---@type turtleMatic.shooting
zephyrKiller.bow          = nil
---@type turtleMatic.automata
zephyrKiller.automata     = nil
---@type refuelHelper
zephyrKiller.refuelHelper = refuelHelper(100, 3000)

function zephyrKiller:tick()
    --TODO
end

function zephyrKiller:init()
    ---@diagnostic disable-next-line: param-type-mismatch
    self.automata = assert(peripheral.find("automata"),
        "Automata is not found! Please install 'Turtlematic' then put automata inside") --[[@as turtleMatic.automata]]

    logHelper.title("ZephyrKiller")

    while true do
        self:tick()
        sleep(0)
    end
end

return zephyrKiller
