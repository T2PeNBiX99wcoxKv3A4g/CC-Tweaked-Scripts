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
---@type table<number, autoDoorServer.data>
autoDoorServer.positionList = {}
---@type fileHelper
autoDoorServer.configHelper = fileHelper(fileHelper.type.data, "automatic_door.json")
---@type number
autoDoorServer.openDistance = 3
---@type string
autoDoorServer.outPutSide = "top"
---@type number
autoDoorServer.timeOutSeconds = 2

---@class autoDoorServer.data
---@field currentPosition vec3
---@field timeOutTime number

---@type string[]
local messageCheck = {
    "currentPosition",
}

function autoDoorServer:handleMessage()
    local id, message = rednet.receive(self.protocol, 2)
    if not id then return end
    if type(message) ~= "table" or not utils.tableKeyCheck(message, messageCheck) then return end
    local gpsMsg = message --[[@as autoDoorClient.message]]
    ---@type autoDoorServer.data
    local data = {
        currentPosition = vec3.fromTable(gpsMsg.currentPosition) or vec3.zero(),
        timeOutTime = os.clock() + self.timeOutSeconds
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
        if data.timeOutTime < os.clock() then
            table.remove(self.positionList, id)
            goto continue
        end

        local distance = data.currentPosition:distanceTo(gpsPosition)

        print(string.format("ID %d:\n  Pos - %s\n  Distance - %d", id, data.currentPosition, distance))

        if distance <= self.openDistance then
            shouldOpen = true
        end
        ::continue::
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
---@field timeOutSeconds number

---@type string[]
local configCheck = {
    "openDistance",
    "outPutSide",
    "hostName",
    "timeOutSeconds"
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
    local config = self.configHelper:load()

    if config and utils.tableKeyCheck(config, configCheck) then
        local validConfig = config --[[@as autoDoorServer.config]]
        self.openDistance = validConfig.openDistance
        self.outPutSide = validConfig.outPutSide
        self.hostName = validConfig.hostName
        self.timeOutSeconds = validConfig.timeOutSeconds
    else
        term.clear()
        term.setCursorPos(1, 1)
        print(("Enter the distance will open the door (default %d): "):format(self.openDistance))
        write("> ")
        local openDistance = tonumber(read()) or self.openDistance

        term.clear()
        term.setCursorPos(1, 1)
        print(("Enter the output side to open door (default '%s'): "):format(self.outPutSide))
        write("> ")
        local outPutSide = read()
        outPutSide = sideCheck[outPutSide] and outPutSide or self.outPutSide

        term.clear()
        term.setCursorPos(1, 1)
        print(("Enter the host name to server (default '%s'): "):format(self.hostName))
        write("> ")
        local hostName = read()
        hostName = #hostName > 0 and hostName or self.hostName

        term.clear()
        term.setCursorPos(1, 1)
        print(("Enter the time out seconds of GPS info (default %d): "):format(self.timeOutSeconds))
        write("> ")
        local timeOutSeconds = tonumber(read()) or self.timeOutSeconds

        ---@type autoDoorServer.config
        local configTable = {
            openDistance = openDistance,
            outPutSide = outPutSide,
            hostName = hostName,
            timeOutSeconds = timeOutSeconds
        }

        self.configHelper:delete()
        self.configHelper:save(configTable)
    end

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

return autoDoorServer
