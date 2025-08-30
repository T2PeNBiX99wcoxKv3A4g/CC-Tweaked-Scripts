---@class hook
local hook = {}

---@type table<string, table<string|table, function>>
hook.hooks = {}

---@param event string
---@param id string|table
---@param func function
function hook:add(event, id, func)
    if not self.hooks[event] then
        self.hooks[event] = {}
    end
    self.hooks[event][id] = func
end

---@param event string
---@param id string|table
function hook:remove(event, id)
    if self.hooks[event] then
        self.hooks[event][id] = nil
    end
end

function hook:clear()
    self.hooks = {}
end

---@param event string
---@param ... any
function hook:call(event, ...)
    if not self.hooks[event] then return end
    for id, func in pairs(self.hooks[event]) do
        if type(id) == "table" then
            func(id, ...)
        else
            func(...)
        end
    end
end

return hook
