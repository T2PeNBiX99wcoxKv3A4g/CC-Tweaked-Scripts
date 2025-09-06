---@class turtleMatic.capture
local capture = {}

---@param mode turtleMatic.interactionMode
---@param direction turtleMatic.direction?
---@return boolean success
---@return string|nil errorMessage
function capture.capture(mode, direction) return true end

---@return boolean success
---@return string|nil errorMessage
function capture.release() return true end

---@return table
function capture.getCaptured() return {} end

return capture
