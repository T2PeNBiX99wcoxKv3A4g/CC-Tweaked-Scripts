---@class turtleMatic.fuel
local fuel = {}

---@return number|"unlimited"
function fuel.getFuelLevel() return 0 end

---@return number|"unlimited"
function fuel.getFuelMaxLevel() return 0 end

---@return number
function fuel.getFuelConsumptionRate() return 0 end

---@param rate number
function fuel.setFuelConsumptionRate(rate) end

return fuel
