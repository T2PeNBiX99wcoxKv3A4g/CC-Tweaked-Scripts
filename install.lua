---@class fileInfo
---@field url string
---@field path string

---@type string[]
local lastDownloadJsonFile = {}

---@param url string
---@param path string
---@return boolean
local function downloadFIle(url, path)
    print("Downloading " .. url)
    local request = http.get(url)
    if request then
        if fs.exists(path) then
            fs.delete(path)
        end

        local file = fs.open(path, "w")
        if not file then
            error("File can't be open! " .. path)
            return false
        end

        file.write(request.readAll())
        file.close()
        request.close()

        if path:find(".json") then
            table.insert(lastDownloadJsonFile, path)
        end
        return true
    end
    return false
end

print("Start install script...")

local success = downloadFIle(
    "https://raw.githubusercontent.com/T2PeNBiX99wcoxKv3A4g/CC-Tweaked-Scripts/refs/heads/main/install_options.json",
    "install_options.json")

if not success then
    error("Failed to download options file!")
    return
end

local file = fs.open("install_options.json", "r")

if not file then
    error("Options file is not found or can't be open!")
    return
end

local optionsJson = file.readAll()

if not optionsJson then
    file.close()
    error("Options json is nil!")
    return
end

file.close()

---@type table<string, fileInfo>| nil
local options, errorMessage = textutils.unserialiseJSON(optionsJson)

if not options then
    error("Options json can't be unserialise: " .. errorMessage)
    return
end

---@type string[]
local allOptions = {}

for option, _ in pairs(options) do
    table.insert(allOptions, option)
end

local args = { ... }

if #args < 1 or not options[args[1]] then
    print(string.format("Please enter install script name! (%s)", table.concat(allOptions, ", ")))
    return
end

local downloadInfo = options[args[1]]

print("Start download install json file " .. downloadInfo.url)

local success = downloadFIle(downloadInfo.url, downloadInfo.path)

if not success then
    error("Failed to download " .. downloadInfo.url)
end

local file = fs.open(downloadInfo.path, "r")

if not file then
    error(downloadInfo.path .. " file is not found or can't be open!")
    return
end

local downloadInfoJson = file.readAll()

if not downloadInfoJson then
    file.close()
    error(downloadInfo.path .. " json is nil!")
    return
end

file.close()

---@type fileInfo[]| nil
local fileInfos, errorMessage = textutils.unserialiseJSON(downloadInfoJson)

if not fileInfos then
    error(downloadInfo.path .. " json can't be unserialise: " .. errorMessage)
    return
end

for _, fileInfo in ipairs(fileInfos) do
    local success = downloadFIle(fileInfo.url, fileInfo.path)

    if not success then
        error("Failed to download " .. fileInfo.url)
    end
end

for _, path in pairs(lastDownloadJsonFile) do
    if fs.exists(path) then
        fs.delete(path)
    end
end

print(args[1] .. " script is installed!")
