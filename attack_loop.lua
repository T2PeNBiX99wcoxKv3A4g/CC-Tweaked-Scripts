local Attack = {}

Attack.weaponSide = "right"

function Attack:init()
    print("Ender man Killer is start")
    while true do
        self:toAttack()
        sleep(0.05)
    end
end

function Attack:toAttack()
    turtle.attack(self.weaponSide)
end

function Attack:checkAnyItem()
    for i = 1, 16 do
        local count = turtle.getItemCount(i)
        if count > 0 then
            turtle.select(i)
            turtle.dropDown(count)
        end
    end
end

Attack:init()
