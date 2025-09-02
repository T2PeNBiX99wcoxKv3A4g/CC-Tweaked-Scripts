local vec3 = require("modules.vector3")
local expect = require("cc.expect").expect

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

---@param length number
---@param width number
---@param y number
---@return vec3[]
function utils.mine2DXZAreaPath(length, width, y)
    local points = {}
    local lengthEnd = length - 1
    local widthEnd = width - 1

    for x = 0, -widthEnd, -1 do
        for z = 0, lengthEnd do
            table.insert(points, vec3(x, y, z))
        end
    end

    table.sort(points, function(a, b)
        if a.x == b.x then
            return a.z < b.z
        end
        return a.x > b.x
    end)

    return points
end

---@param length number
---@param width number
---@param height number
---@return vec3[]
function utils.mine3DDownAreaPath(length, width, height)
    local points = {}

    for y = -1, -height, -1 do
        local layerPoints = utils.mine2DXZAreaPath(length, width, y)
        for _, v in ipairs(layerPoints) do
            table.insert(points, v)
        end
    end

    return points
end

---@param length number
---@param height number
---@param x number
---@return vec3[]
function utils.mine2DYZAreaPath(length, height, x)
    local points = {}
    local lengthEnd = length - 1
    local heightEnd = height - 1

    for y = 0, heightEnd do
        for z = 0, lengthEnd do
            table.insert(points, vec3(x, y, z))
        end
    end

    table.sort(points, function(a, b)
        if a.y == b.y then
            return a.z < b.z
        end
        return a.y < b.y
    end)

    return points
end

---@param length number
---@param width number
---@param height number
---@return vec3[]
function utils.mine3DForwardAreaPath(length, width, height)
    local points = {}
    local widthEnd = width - 1

    for x = 0, -widthEnd, -1 do
        local layerPoints = utils.mine2DYZAreaPath(length, height, x)
        for _, v in ipairs(layerPoints) do
            table.insert(points, v)
        end
    end

    return points
end

---@param length number
---@param width number
---@param height number
---@return vec3[]
function utils.mine3DUpAreaPath(length, width, height)
    local points = {}

    for y = 1, height do
        local layerPoints = utils.mine2DXZAreaPath(length, width, y)
        for _, v in ipairs(layerPoints) do
            table.insert(points, v)
        end
    end

    return points
end

---@param tbl table
---@param checkTbl table
---@return boolean
function utils.tableKeyCheck(tbl, checkTbl)
    for _, value in pairs(checkTbl) do
        if not tbl[value] then
            return false
        end
    end
    return true
end

utils.__oldPrint = utils.__oldPrint or print

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

---@param tbl table
function table.isEmpty(tbl)
    return next(tbl) == nil
end

---@param tbl table
---@param lookupTable table|nil
---@return table
function table.copy(tbl, lookupTable)
    ---@diagnostic disable-next-line: param-type-mismatch
    expect(1, tbl, "table")

    local copy = {}
    setmetatable(copy, debug.getmetatable(tbl))
    for k, v in pairs(tbl) do
        if type(v) ~= "table" then
            copy[k] = v
        else
            lookupTable = lookupTable or {}
            lookupTable[tbl] = copy

            if lookupTable[v] then
                copy[k] = lookupTable[v]
            else
                copy[k] = table.copy(v, lookupTable)
            end
        end
    end
    return copy
end

return utils
