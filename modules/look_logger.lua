local class = require("modules.class")
local fileHelper = require("modules.file_helper")

---@class lookLogger
local lookLogger = class("lookLogger")

---@type turtleMatic.automata
lookLogger.automata = nil
---@type fileHelper
lookLogger.logHelper = fileHelper(fileHelper.type.save, "look_logger_found.json")
---@type turtleMatic.look.output.entity[]
lookLogger.foundData = {}

function lookLogger:tick()
    local lookForward = self.automata.look("entity")
    local lookUp = self.automata.look("entity", "up")

    if lookForward then
        print("Found entity data!")
        table.insert(self.foundData, lookForward)
        self:save()
    end

    if lookUp then
        print("Found entity data!")
        table.insert(self.foundData, lookUp)
        self:save()
    end
end

function lookLogger:save()
    self.logHelper:save(self.foundData)
end

function lookLogger:init()
    ---@diagnostic disable-next-line: param-type-mismatch
    self.automata = assert(peripheral.find("automata"),
        "Automata is not found! Please install 'Turtlematic' then put automata inside") --[[@as turtleMatic.automata]]

    while true do
        self:tick()
        sleep(0)
    end
end

return lookLogger
