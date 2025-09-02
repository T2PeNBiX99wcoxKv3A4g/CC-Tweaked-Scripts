local class = require("modules.class")
local vec3 = require("modules.vector3")
local utils = require("modules.utils")

---@class mineWatcher
local mineWatcher = class("mineWatcher")

---@type string
mineWatcher.protocol = "mineGPS"

---@type table<number, mineGPS.data>
mineWatcher.AllPos = {}

local messageCheck = {
    "currentStatus",
    "currentPosition",
    "currentDirection"
}

function mineWatcher:handleMessage()
    local id, message = rednet.receive(self.protocol)
    if not id then return end
    if type(message) ~= "table" or not utils.tableKeyCheck(message, messageCheck) then return end
    local gpsMsg = message --[[@as mineGPS.data]]
    ---@type mineGPS.data
    local data = {
        currentStatus = gpsMsg.currentStatus,
        currentPosition = gpsMsg.currentPosition:copy()
    }

    self.AllPos[id] = data
end

function mineWatcher:refreshWatcher()
    if table.isEmpty(self.AllPos) then return end
    term.clear()
    term.setCursorPos(1, 1)
    print(self.AllPos)
end

function mineWatcher:init()
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        print("Trying get all miner infos...")
        self:handleMessage()
        self:refreshWatcher()
    end
end

return mineWatcher
