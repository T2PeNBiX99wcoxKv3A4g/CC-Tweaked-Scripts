-- Reference https://github.com/SquidDev-CC/artist/blob/vnext/src/artist/lib/class.lua

local expect = require("cc.expect").expect

local classMetaTable = {
    __name = "class",
    __tostring = function(self)
        return "Class<" .. self.__name .. ">"
    end,
    __call = function(self, ...)
        local tbl = setmetatable({}, self.__index)
        tbl:init(...)
        return tbl
    end
}

---@param name string
---@return table
return function(name)
    expect(1, name, "string")

    local class = setmetatable({
        __name = name,
        __tostring = function(self)
            return self.__name .. "<>"
        end
    }, classMetaTable)

    class.__index = class
    return class
end
