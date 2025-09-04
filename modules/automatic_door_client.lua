local class = require("modules.class")
local vec3 = require("modules.vector3")

---@class autoDoorClient
local autoDoorClient = class("autoDoorClient")

---@type boolean
autoDoorClient.gpsAvailable = false
---@type ccTweaked.peripherals.Modem
autoDoorClient.modem = nil
---@type string
autoDoorClient.protocol = "autoDoor"

---@class autoDoorClient.data
---@field currentPosition vec3

---@class autoDoorClient.message
---@field currentPosition vec3Table

function autoDoorClient:sendMessage()
    local ids = { rednet.lookup(self.protocol) }
    local data = {
        currentPosition = vec3(gps.locate(2, false))
    }

    for _, id in pairs(ids) do
        rednet.send(id, data, self.protocol)
    end
end

function autoDoorClient:redNetSetup()
    ---@type ccTweaked.peripherals.Modem|nil
    local modem = peripheral.find("modem") --[[@as ccTweaked.peripherals.Modem|nil]]
    if not modem then return end

    rednet.open(peripheral.getName(modem))

    self.modem = modem
end

---@return boolean
function autoDoorClient:gpsCheck()
    return gps.locate(1, false) and true or false
end

function autoDoorClient:init()
    self:redNetSetup()

    term.clear()
    term.setCursorPos(1, 1)
    print("Send position to the door using gps...")

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

return autoDoorClient
