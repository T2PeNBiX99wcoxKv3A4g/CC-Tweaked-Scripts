local class = require("modules.class")

---@class fileHelper
local fileHelper = class("fileHelper")
local expect = require("cc.expect").expect

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

---@param folderType fileHelper.type| string
---@return string
function fileHelper:folderTypeHandle(folderType)
    if type(folderType) == "string" then return folderType end
    if type(folderType) ~= "number" then return "saves" end
    if fileHelper.typeArray[folderType + 1] then
        return fileHelper.typeArray[folderType + 1]
    end
    return "saves"
end

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

---@param folder fileHelper.type|string
---@param fileName string
function fileHelper:init(folder, fileName)
    expect(1, folder, "string", "number")
    expect(2, fileName, "string")

    folder = self:folderTypeHandle(folder)

    self.folder = folder or "saves"
    self.fileName = fileName
end

return fileHelper
