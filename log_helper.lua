local LogHelper = {}

---@param title string
function LogHelper.title(title)
    term.setCursorPos(1, 1)
    term.clearLine()
    term.write(title)
end

---@param progress string
function LogHelper.progress(progress)
    term.setCursorPos(1, 2)
    term.clearLine()
    term.write(progress)
end

---@param msg string
function LogHelper.massage(msg)
    term.setCursorPos(1, 3)
    term.clearLine()
    term.write(msg)
end

---@param msg string
function LogHelper.warning(msg)
    term.setCursorPos(1, 3)
    term.clearLine()
    term.setTextColor(colors.yellow)
    term.write(msg)
    term.setTextColor(colors.white)
end

---@param msg string
function LogHelper.error(msg)
    term.setCursorPos(1, 3)
    term.clearLine()
    term.setTextColor(colors.red)
    term.write(msg)
    term.setTextColor(colors.white)
end

---@param level number|string
function LogHelper.fuelLevel(level)
    term.setCursorPos(1, 4)
    term.clearLine()
    term.write(string.format("Current fuel level: %s", level))
end

---@param msg string
function LogHelper.fuelError(msg)
    term.setCursorPos(1, 5)
    term.clearLine()
    term.setTextColor(colors.red)
    term.write(msg)
    term.setTextColor(colors.white)
end

return LogHelper
