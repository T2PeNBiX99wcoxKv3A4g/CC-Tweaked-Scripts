---@class utils
local utils = {}

---@enum utils.computerTypes
utils.computerTypes = {
    normal = 0,
    turtle = 1,
    pocket = 2
}

---@return utils.computerTypes
function utils.computerType()
    if turtle then return utils.computerTypes.turtle end
    if pocket then return utils.computerTypes.pocket end
    return utils.computerTypes.normal
end

utils.__oldPrint = print

---@param ... any
function print(...)
    local rets = {}
    for i = 1, select("#", ...), 1 do
        local value = select(i, ...)
        if type(value) == "table" then
            table.insert(rets, string.format("%s - %s", tostring(value), textutils.serialise(value)))
        else
            table.insert(rets, value)
        end
    end
    utils.__oldPrint(table.unpack(rets))
end

return utils
