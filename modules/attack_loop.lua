local class = require("modules.class")
local fileHelper = require("modules.file_helper")

---@class attack
local attack = class("attack")

---@type string
attack.weaponSide = "right"
---@type fileHelper
attack.dataHelper = fileHelper(fileHelper.type.data, "attack_loop_config.json")

function attack:toAttack()
    turtle.attack(self.weaponSide)
end

function attack:checkAnyItem()
    for i = 1, 16 do
        local count = turtle.getItemCount(i)
        if count > 0 then
            turtle.select(i)
            turtle.dropDown(count)
        end
    end
end

function attack:init()
    term.clear()
    term.setCursorPos(1, 1)

    print("Attack loop is start")

    local config = self.dataHelper:load()

    if config and config.weaponSide then
        self.weaponSide = config.weaponSide
    else
        local configTable = {
            weaponSide = self.weaponSide
        }

        self.dataHelper:delete()
        self.dataHelper:save(configTable)
    end

    while true do
        self:toAttack()
        sleep(0)
    end
end

return attack
