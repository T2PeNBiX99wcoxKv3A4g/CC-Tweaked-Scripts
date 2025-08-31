local basalt = require("basalt")

local main = basalt.getMainFrame()

main:addButton():setText("Click me!"):setPosition(4, 4):onClick(function()

end)

basalt.run()
