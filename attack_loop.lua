local Attack = {}

Attack.WeaponSide = "right"

function Attack:Init()
    print("Ender man Killer is start")
    while true do
        self:Do()
        sleep(0.05)
    end
end

function Attack:Do()
    self:ToAttack()
    -- self:CheckAnyItem()
end

function Attack:ToAttack()
    turtle.attack(self.WeaponSide)
end

function Attack:CheckAnyItem()
    for i = 1, 16 do
        local count = turtle.getItemCount(i)
        if count > 0 then
            turtle.select(i)
            turtle.dropDown(count)
        end
    end
end

Attack:Init()
