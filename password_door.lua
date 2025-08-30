---@class door
local door = {}

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

---@return nil
function door:init()
    while true do
        door:inputPassword()
    end
end

---@return nil
function door:inputPassword()
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

---@return nil
function door:pass()
    print(self.logPassMsg)
    print(self.logDoorOpenMsg)
    redstone.setOutput(self.doorSide, true)
    sleep(self.sleepTime)
    redstone.setOutput(self.doorSide, false)
end

---@return nil
function door:failed()
    print(self.logFailedMsg)
    print(self.logRetryMsg)
    sleep(self.sleepTime)
end

door:init()
