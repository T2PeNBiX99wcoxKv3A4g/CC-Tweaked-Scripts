---@class turtleMatic.shooting
local shooting = {}

---@return number
function shooting.getAngle() return 0 end

---@param angle number
function shooting.setAngle(angle) end

---@param power number
---@param limit number?
---@param suppressExtraLogic boolean?
---@return boolean success
---@return string|nil errorMessage
function shooting.shoot(power, limit, suppressExtraLogic) return true end

return shooting
