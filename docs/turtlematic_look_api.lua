---@class turtleMatic.look
local look = {}

---@class turtleMatic.look.output.entity
---@field type string
---@field tags string[]
---@field displayName string
---@field health number
---@field category string
---@field uuid string
---@field name number

---@class turtleMatic.look.output.block
---@field tags string[]
---@field name string
---@field displayName string

---@alias turtleMatic.look.output
---|turtleMatic.look.output.entity
---|turtleMatic.look.output.block

---@param mode turtleMatic.interactionMode
---@param direction turtleMatic.direction?
---@return turtleMatic.look.output
function look.look(mode, direction) return {} end

return look
