local Door = {}

---@type number
Door.sleepTime = 10
---@type string
Door.doorSide = "left"
---@type string
Door.password = "2"
---@type string
Door.inputHint = "1 + 1 = ?"
---@type string
Door.inputPrefix = "Answer > "
---@type string
Door.logPassMsg = "Pass!"
---@type string
Door.logFailedMsg = "Failed!"
---@type string
Door.logDoorOpenMsg = string.format("Door will open in %d seconds", Door.sleepTime)
---@type string
Door.logRetryMsg = string.format("Retry after %d seconds", Door.sleepTime)

---@return nil
function Door:init()
    while true do
        Door:inputPassword()
    end
end

---@return nil
function Door:inputPassword()
    print(self.inputHint)
    write(self.inputPrefix)

    if self:checkPassword() then
        self:pass()
        return
    end
    self:failed()
end

---@return boolean
function Door:checkPassword()
    return read("*") == self.password
end

---@return nil
function Door:pass()
    print(self.logPassMsg)
    print(self.logDoorOpenMsg)
    redstone.setOutput(self.doorSide, true)
    sleep(self.sleepTime)
    redstone.setOutput(self.doorSide, false)
end

---@return nil
function Door:failed()
    print(self.logFailedMsg)
    print(self.logRetryMsg)
    sleep(self.sleepTime)
end

Door:init()
