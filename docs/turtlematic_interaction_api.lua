---@class turtleMatic.interaction
local interaction = {}

---@param mode turtleMatic.interactionMode
---@param direction turtleMatic.direction?
---@return boolean success
---@return string|nil errorMessage
function interaction.use(mode, direction) return true end

---@param mode turtleMatic.interactionMode
---@param direction turtleMatic.direction?
---@return boolean success
---@return string|nil errorMessage
function interaction.swing(mode, direction) return true end

return interaction
