---@class fileHelper
local fileHelper = {}

---@enum fileHelper.type
fileHelper.type = {
    save = 0,
    data = 1
}

---@type string[]
---@private
fileHelper.typeArray = { "saves", "data" }

---Will never be use and replace with instance table
---@type string
fileHelper.folder = nil
---@type string
fileHelper.fileName = nil

---@param data table
---@return boolean
function fileHelper:save(data)
    if not fs.exists(self.folder) then
        fs.makeDir(self.folder)
    end

    local file = fs.open(string.format("%s/%s", self.folder, self.fileName), "w")
    if not file then return false end
    file.write(textutils.serializeJSON(data))
    file.close()
    return true
end

---@return table|nil
function fileHelper:load()
    if not fs.exists(string.format("/%s/%s", self.folder, self.fileName)) then return end

    local file = fs.open(string.format("/%s/%s", self.folder, self.fileName), "r")
    if not file then return nil end
    local fileString = file.readAll()
    if not fileString or fileString == "" then
        file.close()
        return
    end
    local data = textutils.unserializeJSON(fileString)
    file.close()
    return data
end

---@return boolean
function fileHelper:delete()
    if not fs.exists(string.format("/%s/%s", self.folder, self.fileName)) then return false end
    fs.delete(string.format("/%s/%s", self.folder, self.fileName))
    return true
end

local metaTable = {}

---@param folder fileHelper.type|string|nil
---@param fileName string
---@return fileHelper
function metaTable:__call(folder, fileName)
    if type(folder) == "number" then
        if fileHelper.typeArray[folder + 1] then
            folder = fileHelper.typeArray[folder + 1]
        else
            folder = "saves"
        end
    end

    local obj = { folder = folder or "saves", fileName = fileName }
    local objMetaTable = { __index = fileHelper }

    function objMetaTable:__newindex(key, value)
        error("Attempt to modify read-only table", 2)
    end

    setmetatable(obj, objMetaTable)

    return obj
end

function metaTable:__newindex(key, value)
    error("Attempt to modify read-only table", 2)
end

setmetatable(fileHelper, metaTable)

return fileHelper
