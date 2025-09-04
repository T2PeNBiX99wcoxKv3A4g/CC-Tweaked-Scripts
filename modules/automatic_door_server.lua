local class = require("modules.class")
local vec3 = require("modules.vector3")
local fileHelper = require("modules.file_helper")
local utils = require("modules.utils")

---@class autoDoorServer
local autoDoorServer = class("autoDoorServer")

---@type boolean
autoDoorServer.gpsAvailable = false
---@type ccTweaked.peripherals.Modem
autoDoorServer.modem = nil
---@type string
autoDoorServer.protocol = "autoDoor"
---@type string
autoDoorServer.hostName = "myAutoDoor"
---@type table<number, autoDoorClient.data>
autoDoorServer.positionList = {}
---@type fileHelper
autoDoorServer.configHelper = fileHelper(fileHelper.type.data, "automatic_door.json")
---@type number
autoDoorServer.openDistance = 20
---@type string
autoDoorServer.outPutSide = "top"

---@type string[]
local messageCheck = {
    "currentPosition",
}

function autoDoorServer:handleMessage()
    local id, message = rednet.receive(self.protocol)
    if not id then return end
    if type(message) ~= "table" or not utils.tableKeyCheck(message, messageCheck) then return end
    local gpsMsg = message --[[@as autoDoorClient.message]]
    ---@type autoDoorClient.data
    local data = {
        currentPosition = vec3.fromTable(gpsMsg.currentPosition) or vec3.zero()
    }

    self.positionList[id] = data
end

function autoDoorServer:checkPosition()
    term.clear()
    term.setCursorPos(1, 1)
    print("Players GPS List: ")

    local shouldOpen = false
    ---@type vec3
    local gpsPosition = vec3(gps.locate(2, false))

    for id, data in pairs(self.positionList) do
        print(string.format("ID %d:\n  Pos - %s", id, data.currentPosition))
        if data.currentPosition:distanceTo(gpsPosition) < self.openDistance then
            shouldOpen = true
        end
    end

    redstone.setOutput(self.outPutSide, shouldOpen)
end

function autoDoorServer:redNetSetup()
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
function autoDoorServer:gpsCheck()
    return gps.locate(1, false) and true or false
end

---@class autoDoorServer.config
---@field openDistance number
---@field outPutSide string
---@field hostName string

---@type string[]
local configCheck = {
    "openDistance",
    "outPutSide",
    "hostName"
}

---@type table<string, boolean>
local sideCheck = {
    top = true,
    bottom = true,
    right = true,
    left = true,
    front = true,
    back = true
}

function autoDoorServer:init()
    self:redNetSetup()

    local config = self.configHelper:load()

    if config and utils.tableKeyCheck(config, configCheck) then
        local validConfig = config --[[@as autoDoorServer.config]]
        self.openDistance = validConfig.openDistance
        self.outPutSide = validConfig.outPutSide
        self.hostName = validConfig.hostName
    else
        term.clear()
        term.setCursorPos(1, 1)
        print("Enter the distance will open the door (default 20): ")
        write("> ")
        local openDistance = tonumber(read()) or self.openDistance

        term.clear()
        term.setCursorPos(1, 1)
        print("Enter the output side to open door (default 'top'): ")
        write("> ")
        local outPutSide = read()
        outPutSide = sideCheck[outPutSide] and outPutSide or self.outPutSide

        term.clear()
        term.setCursorPos(1, 1)
        print("Enter the host name to server (default 'myAutoDoor'): ")
        write("> ")
        local hostName = read()
        hostName = #hostName > 0 and hostName or self.hostName

        ---@type autoDoorServer.config
        local configTable = {
            openDistance = openDistance,
            outPutSide = outPutSide,
            hostName = hostName
        }

        self.configHelper:delete()
        self.configHelper:save(configTable)
    end

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

return autoDoorServer
