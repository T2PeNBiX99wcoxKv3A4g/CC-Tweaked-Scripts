local class = require("modules.class")
local vec3 = require("modules.vector3")

---@class distanceTestClient
local distanceTestClient = class("distanceTestClient")

---@type boolean
distanceTestClient.gpsAvailable = false
---@type ccTweaked.peripherals.Modem
distanceTestClient.modem = nil
---@type string
distanceTestClient.protocol = "distanceTest"

---@class distanceTestClient.data
---@field currentPosition vec3

---@class distanceTestClient.message
---@field currentPosition vec3Table

function distanceTestClient:sendMessage()
    local ids = { rednet.lookup(self.protocol) }
    local data = {
        currentPosition = vec3(gps.locate(2, false))
    }

    for _, id in pairs(ids) do
        rednet.send(id, data, self.protocol)
    end
end

function distanceTestClient:redNetSetup()
    ---@type ccTweaked.peripherals.Modem|nil
    local modem = peripheral.find("modem") --[[@as ccTweaked.peripherals.Modem|nil]]
    if not modem then return end

    local modemSide = peripheral.getName(modem)

    if not rednet.isOpen(modemSide) then
        rednet.open(modemSide)
    end

    self.modem = modem
end

---@return boolean
function distanceTestClient:gpsCheck()
    return gps.locate(1, false) and true or false
end

function distanceTestClient:init()
    self:redNetSetup()

    term.clear()
    term.setCursorPos(1, 1)
    print("Send position to the host...")

    while true do
        self.gpsAvailable = self:gpsCheck()

        if not self.gpsAvailable then
            printError("GPS Is not Available!")
            sleep(10)
            goto continue
        end

        self:sendMessage()
        sleep(0)
        ::continue::
    end
end

return distanceTestClient
