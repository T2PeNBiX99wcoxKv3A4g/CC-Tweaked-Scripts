local utils = {}

utils.__oldPrint = print

---@param ... any
function print(...)
    local rets = {}
    for i = 1, select("#", ...), 1 do
        local value = select(i, ...)
        if type(value) == "table" then
            table.insert(rets, string.format("%s - %s", tostring(value), textutils.serialise(value)))
        else
            table.insert(rets, tostring(value))
        end
    end

    utils.__oldPrint(table.concat(rets, "\t"))
end

return utils
