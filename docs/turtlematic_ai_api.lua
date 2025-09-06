---@class turtleMatic.ai
local ai = {}

---@param direction turtleMatic.direction?
---@return boolean success
---@return string|nil errorMessage
function ai.toggleAI(direction) return true end

---@param direction turtleMatic.direction?
---@return boolean
function ai.isAIEnabled(direction) return true end

return ai
