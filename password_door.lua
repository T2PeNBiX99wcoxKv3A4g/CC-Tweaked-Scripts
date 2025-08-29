local C = {}

---@type number
C.SleepTime = 10
---@type string
C.DoorSide = "left"
---@type string
C.Password = "2"
---@type string
C.InputHint = "1 + 1 = ?"
---@type string
C.InputPrefix = "Answer > "
---@type string
C.LogPassMsg = "Pass!"
---@type string
C.LogFailedMsg = "Failed!"
---@type string
C.LogDoorOpenMsg = "Door will open in " .. C.SleepTime .. " seconds"
---@type string
C.LogRetryMsg = "Retry after " .. C.SleepTime .. " seconds"

---@return nil
function C:Init()
    while true do
        C:InputPassword()
    end
end

---@return nil
function C:InputPassword()
    print(self.InputHint)
    write(self.InputPrefix)

    if self:CheckPassword() then
        self:Pass()
        return
    end
    self:Failed()
end

---@return boolean
function C:CheckPassword()
    return read("*") == self.Password
end

---@return nil
function C:Pass()
    print(self.LogPassMsg)
    print(self.LogDoorOpenMsg)
    redstone.setOutput(self.DoorSide, true)
    sleep(self.SleepTime)
    redstone.setOutput(self.DoorSide, false)
end

---@return nil
function C:Failed()
    print(self.LogFailedMsg)
    print(self.LogRetryMsg)
    sleep(self.SleepTime)
end

C:Init()
