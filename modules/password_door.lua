local class = require("modules.class")
local fileHelper = require("modules.file_helper")

---@class door
local door = class("door")

---@type number
door.sleepTime = 10
---@type string
door.doorSide = "left"
---@type string
door.password = "2"
---@type string
door.inputHint = "1 + 1 = ?"
---@type string
door.inputPrefix = "Answer > "
---@type string
door.logPassMsg = "Pass!"
---@type string
door.logFailedMsg = "Failed!"
---@type string
door.logDoorOpenMsg = string.format("Door will open in %d seconds", door.sleepTime)
---@type string
door.logRetryMsg = string.format("Retry after %d seconds", door.sleepTime)
---@type fileHelper
door.dataHelper = fileHelper(fileHelper.type.data, "password_door_config.json")

function door:inputPassword()
    term.clear()
    term.setCursorPos(1, 1)
    print(self.inputHint)
    write(self.inputPrefix)

    if self:checkPassword() then
        self:pass()
        return
    end
    self:failed()
end

---@return boolean
function door:checkPassword()
    return read("*") == self.password
end

function door:pass()
    print(self.logPassMsg)
    print(self.logDoorOpenMsg)
    redstone.setOutput(self.doorSide, true)
    sleep(self.sleepTime)
    redstone.setOutput(self.doorSide, false)
end

function door:failed()
    print(self.logFailedMsg)
    print(self.logRetryMsg)
    sleep(self.sleepTime)
end

function door:init()
    local config = self.dataHelper:load()

    if config and config.sleepTime and config.doorSide and config.password and config.inputHint and config.inputPrefix and config.logPassMsg and config.logFailedMsg then
        self.sleepTime = config.sleepTime
        self.doorSide = config.doorSide
        self.password = config.password
        self.inputHint = config.inputHint
        self.inputPrefix = config.inputPrefix
        self.logPassMsg = config.logPassMsg
        self.logFailedMsg = config.logFailedMsg
    else
        local configTable = {
            sleepTime = self.sleepTime,
            doorSide = self.doorSide,
            password = self.password,
            inputHint = self.inputHint,
            inputPrefix = self.inputPrefix,
            logPassMsg = self.logPassMsg,
            logFailedMsg = self.logFailedMsg
        }

        self.dataHelper:delete()
        self.dataHelper:save(configTable)
    end

    self.logDoorOpenMsg = string.format("Door will open in %d seconds", self.sleepTime)
    self.logRetryMsg = string.format("Retry after %d seconds", self.sleepTime)

    while true do
        self:inputPassword()
        sleep(0)
    end
end

return door
