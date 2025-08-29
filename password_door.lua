local Door = {}

---@type number
Door.SleepTime = 10
---@type string
Door.DoorSide = "left"
---@type string
Door.Password = "2"
---@type string
Door.InputHint = "1 + 1 = ?"
---@type string
Door.InputPrefix = "Answer > "
---@type string
Door.LogPassMsg = "Pass!"
---@type string
Door.LogFailedMsg = "Failed!"
---@type string
Door.LogDoorOpenMsg = "Door will open in " .. Door.SleepTime .. " seconds"
---@type string
Door.LogRetryMsg = "Retry after " .. Door.SleepTime .. " seconds"

---@return nil
function Door:Init()
    while true do
        Door:InputPassword()
    end
end

---@return nil
function Door:InputPassword()
    print(self.InputHint)
    write(self.InputPrefix)

    if self:CheckPassword() then
        self:Pass()
        return
    end
    self:Failed()
end

---@return boolean
function Door:CheckPassword()
    return read("*") == self.Password
end

---@return nil
function Door:Pass()
    print(self.LogPassMsg)
    print(self.LogDoorOpenMsg)
    redstone.setOutput(self.DoorSide, true)
    sleep(self.SleepTime)
    redstone.setOutput(self.DoorSide, false)
end

---@return nil
function Door:Failed()
    print(self.LogFailedMsg)
    print(self.LogRetryMsg)
    sleep(self.SleepTime)
end

Door:Init()
