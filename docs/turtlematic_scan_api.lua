---@class turtleMatic.scan
local scan = {}

---@class turtleMatic.scan.output.item
---@field tags string[]
---@field maxCount number
---@field displayName string
---@field x number
---@field y number
---@field z number
---@field count number
---@field name number
---@field rawName string
---@field itemGroups string[]

---@class turtleMatic.scan.output.block
---@field tags string[]
---@field x number
---@field y number
---@field z number
---@field name string
---@field displayName string

---@class turtleMatic.scan.output.entity
---@field type string
---@field tags string[]
---@field displayName string
---@field x number
---@field y number
---@field z number
---@field health number
---@field category string
---@field uuid string
---@field name number

---@class turtleMatic.scan.output.player
---@field type string
---@field tags string[]
---@field displayName string
---@field x number
---@field y number
---@field z number
---@field health number
---@field category string
---@field uuid string
---@field name number
---@field foodLevel number
---@field saturationLevel number
---@field experienceLevel number
---@field isCreative boolean
---@field xRot number
---@field yRot number
---@field zRot number

---@alias turtleMatic.scan.output
---|turtleMatic.scan.output.item[]
---|turtleMatic.scan.output.block[]
---|turtleMatic.scan.output.entity[]
---|turtleMatic.scan.output.player[]

---@alias turtleMatic.scan.method
---| "item"
---| "block"
---| "entity"
---| "player"
---| "xp"

---@param scanMethod turtleMatic.scan.method
---@param radius number?
---@return turtleMatic.scan.output
function scan.scan(scanMethod, radius) return {} end

return scan
