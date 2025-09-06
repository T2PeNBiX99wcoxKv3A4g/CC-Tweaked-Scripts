local class = require("modules.class")

---@class lavaClear
local lavaClear = class("lavaClear")

---@type lavaBucket
lavaClear.lavaBucket = nil

function lavaClear:clearItems()
    for slot = 1, 16 do
        turtle.select(slot)
        self.lavaBucket.void()
    end
    turtle.select(1)
end

function lavaClear:init()
    ---@diagnostic disable-next-line: param-type-mismatch
    self.lavaBucket = assert(peripheral.find("lava_bucket"),
        "Lava bucket is not found! Please install 'Turtlematic' then put lava bucket inside") --[[@as lavaBucket]]

    while true do
        term.clear()
        term.setCursorPos(1, 1)
        print("Input 'y/yes' to clear up items")
        local ret = read()
        if ret ~= "y" and ret ~= "yes" then
            goto continue
        end

        self:clearItems()
        ::continue::
        sleep(0)
    end
end

return lavaClear
