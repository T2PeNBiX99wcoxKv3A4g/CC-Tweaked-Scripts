---@class saveHelper
local saveHelper = {}

---@type string
saveHelper.folder = "/saves"

---@param filename string
---@param data table
---@return boolean
function saveHelper.save(filename, data)
    if not fs.exists(saveHelper.folder) then
        fs.makeDir(saveHelper.folder)
    end

    local file = fs.open(string.format("%s/%s", saveHelper.folder, filename), "w")
    if not file then return false end
    file.write(textutils.serialize(data))
    file.close()
    return true
end

---@param filename string
---@return table|nil
function saveHelper.load(filename)
    if not fs.exists(string.format("%s/%s", saveHelper.folder, filename)) then return end

    local file = fs.open(string.format("%s/%s", saveHelper.folder, filename), "r")
    if not file then return nil end
    local fileString = file.readAll()
    if not fileString or fileString == "" then
        file.close()
        return
    end
    local data = textutils.unserialize(fileString)
    file.close()
    return data
end

---@param filename string
---@return boolean
function saveHelper.delete(filename)
    if not fs.exists(string.format("%s/%s", saveHelper.folder, filename)) then return false end
    fs.delete(string.format("%s/%s", saveHelper.folder, filename))
    return true
end

return saveHelper
