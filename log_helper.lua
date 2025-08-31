---@class logHelper
local logHelper = {}

---@param title string
function logHelper.title(title)
    term.setCursorPos(1, 1)
    term.clearLine()
    term.write(title)
    term.setCursorPos(1, 8)
    term.clearLine()
end

---@param progress string
function logHelper.progress(progress)
    term.setCursorPos(1, 2)
    term.clearLine()
    term.write(progress)
    term.setCursorPos(1, 8)
    term.clearLine()
end

---@param msg string
function logHelper.massage(msg)
    term.setCursorPos(1, 3)
    term.clearLine()
    term.write(msg)
    term.setCursorPos(1, 8)
    term.clearLine()
end

---@param msg string
function logHelper.warning(msg)
    term.setCursorPos(1, 3)
    term.clearLine()
    term.setTextColor(colors.yellow)
    term.write(msg)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 8)
    term.clearLine()
end

---@param msg string
function logHelper.error(msg)
    term.setCursorPos(1, 3)
    term.clearLine()
    term.setTextColor(colors.red)
    term.write(msg)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 8)
    term.clearLine()
end

---@param level number|string
function logHelper.fuelLevel(level)
    term.setCursorPos(1, 4)
    term.clearLine()
    term.write(string.format("Current fuel level: %s", level))
    term.setCursorPos(1, 8)
    term.clearLine()
end

---@param msg string
function logHelper.fuelMassage(msg)
    term.setCursorPos(1, 5)
    term.clearLine()
    term.write(msg)
    term.setCursorPos(1, 8)
    term.clearLine()
end

---@param msg string
function logHelper.fuelError(msg)
    term.setCursorPos(1, 5)
    term.clearLine()
    term.setTextColor(colors.red)
    term.write(msg)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 8)
    term.clearLine()
end

---@param msg string
function logHelper.debugMassage(msg)
    term.setCursorPos(1, 7)
    term.clearLine()
    term.setTextColor(colors.green)
    term.write(msg)
    term.setTextColor(colors.white)
    term.setCursorPos(1, 8)
    term.clearLine()
end

return logHelper
