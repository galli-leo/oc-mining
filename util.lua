
local keyboard = require("keyboard")
local event = require("event")

function should_quit()
    return keyboard.isKeyDown("q")
end

function try_place(msg)
    local success = false
    local err = nil
    while not success do
        success, err = robot.place()
        if not success then
            warn("Could not place %s: %s", msg, err)
            robot.swing()
        end
    end
end

function key_down_handler(name, addr, char, code, player)
    debug("key_down: %d", code)
    if code == keyboard.keys.q then
        exit_now()
    end
end

key_event = event.listen("key_down", key_down_handler)

function exit_now()
    event.ignore("key_down", key_down_handler)
    running = false
    os.sleep(1.0)
    os.exit()
end

