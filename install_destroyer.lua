---@diagnostic disable: duplicate-doc-field
---@class fileInfo
---@field url string
---@field path string
---@diagnostic enable: duplicate-doc-field

---@type fileInfo[]
local downloadUrls = {
    { url = "https://raw.githubusercontent.com/T2PeNBiX99wcoxKv3A4g/CC-Tweaked-Scripts/refs/heads/main/vector3.lua",           path = "vector3.lua" },
    { url = "https://raw.githubusercontent.com/T2PeNBiX99wcoxKv3A4g/CC-Tweaked-Scripts/refs/heads/main/hook.lua",              path = "hook.lua" },
    { url = "https://raw.githubusercontent.com/T2PeNBiX99wcoxKv3A4g/CC-Tweaked-Scripts/refs/heads/main/log_helper.lua",        path = "log_helper.lua" },
    { url = "https://raw.githubusercontent.com/T2PeNBiX99wcoxKv3A4g/CC-Tweaked-Scripts/refs/heads/main/file_helper.lua",       path = "file_helper.lua" },
    { url = "https://raw.githubusercontent.com/T2PeNBiX99wcoxKv3A4g/CC-Tweaked-Scripts/refs/heads/main/refuel_helper.lua",     path = "refuel_helper.lua" },
    { url = "https://raw.githubusercontent.com/T2PeNBiX99wcoxKv3A4g/CC-Tweaked-Scripts/refs/heads/main/move_helper.lua",       path = "move_helper.lua" },
    { url = "https://raw.githubusercontent.com/T2PeNBiX99wcoxKv3A4g/CC-Tweaked-Scripts/refs/heads/main/destroyer.lua",         path = "destroyer.lua" },
    { url = "https://raw.githubusercontent.com/T2PeNBiX99wcoxKv3A4g/CC-Tweaked-Scripts/refs/heads/main/startup_destroyer.lua", path = "startup.lua" }
}

local function downloadFIle(url, path)
    print("Downloading " .. url)
    local request = http.get(url)
    if request then
        if fs.exists(path) then
            fs.delete(path)
        end

        local file = fs.open(path, "w")
        if not file then
            error("File can't be open!")
            return
        end

        file.write(request.readAll())
        file.close()
        request.close()
    else
        error("Failed to download " .. url)
    end
end

print("Start install destroyer script...")

for _, fileInfo in ipairs(downloadUrls) do
    downloadFIle(fileInfo.url, fileInfo.path)
end

print("Destroyer script is installed!")
