local class = require("modules.class")
local vec3 = require("modules.vector3")
local utils = require("modules.utils")

---@class distanceTestServer
local distanceTestServer = class("distanceTestServer")

---@type boolean
distanceTestServer.gpsAvailable = false
---@type ccTweaked.peripherals.Modem
distanceTestServer.modem = nil
---@type string
distanceTestServer.protocol = "distanceTest"
---@type string
distanceTestServer.hostName = "myDistanceTest"
---@type table<number, distanceTestClient.data>
distanceTestServer.positionList = {}

---@type string[]
local messageCheck = {
    "currentPosition",
}

function distanceTestServer:handleMessage()
    local id, message = rednet.receive(self.protocol)
    if not id then return end
    if type(message) ~= "table" or not utils.tableKeyCheck(message, messageCheck) then return end
    local gpsMsg = message --[[@as distanceTestClient.message]]
    ---@type distanceTestClient.data
    local data = {
        currentPosition = vec3.fromTable(gpsMsg.currentPosition) or vec3.zero()
    }

    self.positionList[id] = data
end

function distanceTestServer:checkPosition()
    term.clear()
    term.setCursorPos(1, 1)
    print("Players GPS List: ")

    ---@type vec3
    local gpsPosition = vec3(gps.locate(2, false))

    for id, data in pairs(self.positionList) do
        print(string.format("ID %d:\n  Pos - %s\n  Distance - %d", id, data.currentPosition,
            data.currentPosition:distanceTo(gpsPosition)))
    end
end

function distanceTestServer:redNetSetup()
    ---@type ccTweaked.peripherals.Modem|nil
    local modem = peripheral.find("modem") --[[@as ccTweaked.peripherals.Modem|nil]]
    if not modem then return end

    local modemSide = peripheral.getName(modem)

    if not rednet.isOpen(modemSide) then
        rednet.open(modemSide)
    end

    rednet.host(self.protocol, self.hostName)

    self.modem = modem
end

---@return boolean
function distanceTestServer:gpsCheck()
    return gps.locate(1, false) and true or false
end

function distanceTestServer:init()
    self:redNetSetup()

    term.clear()
    term.setCursorPos(1, 1)
    print("Search player position using gps...")

    while true do
        self.gpsAvailable = self:gpsCheck()

        if not self.gpsAvailable then
            printError("GPS Is not Available!")
            sleep(10)
            goto continue
        end

        self:handleMessage()
        self:checkPosition()
        sleep(0)
        ::continue::
    end
end

return distanceTestServer
