component = require("component")
local keyboard = require("keyboard")
-- robot = require("robot")

dofile "config.lua"
dofile "log.lua"
dofile "networking.lua"
dofile "util.lua"

info("Starting up main for computer...")

running = true

while running do
--[[     notif = recv_notif()
    if notif then
        info("Received notification: %s", notif)
    end ]]
    if keyboard.isKeyDown("s") then
        status = send_request(MESSAGE_TYPES.STATUS, {})
        info("Response status: %s", tbl_to_str(status))
    end
    if keyboard.isKeyDown("d") then
        status = send_request(MESSAGE_TYPES.DISLOCATOR, {})
        info("Response status: %s", tbl_to_str(status))
    end
    if keyboard.isKeyDown("p") then
        status = send_request(MESSAGE_TYPES.QUIT, {})
        info("Response status: %s", tbl_to_str(status))
    end
    os.sleep(0.1)
end

info("Shutting down...")