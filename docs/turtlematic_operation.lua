---@class turtleMatic.operation
local operation = {}

---@param operationName string
---@return number
function operation.getCooldown(operationName) return 0 end

---@return string[]
function operation.getOperations() return {} end

return operation
