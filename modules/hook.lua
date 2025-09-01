---@class hook
local hook = {}

---@type table<string, table<string|table, function>>
local hooks = {}

---@param event string
---@param id string|table
---@param func function
function hook.add(event, id, func)
    if not hooks[event] then
        hooks[event] = {}
    end
    hooks[event][id] = func
end

---@param event string
---@param id string|table
function hook.remove(event, id)
    if hooks[event] then
        hooks[event][id] = nil
    end
end

function hook.clear()
    hooks = {}
end

---@param event string
---@param ... any
function hook.call(event, ...)
    if not hooks[event] then return end
    for id, func in pairs(hooks[event]) do
        if type(id) == "table" then
            func(id, ...)
        else
            func(...)
        end
    end
end

return hook
