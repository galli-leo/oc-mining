local fs = require("filesystem")
local computer = require("computer")
local exp = component.experience

local dist_file = nil
local curr_dist = 0

function open_dist()
    debug("opening distance file")
    dist_file = io.open("/home/distance.txt", "r")
    read_dist()
end

function read_dist()
    curr_dist = dist_file:read('*n')
    dist_file:close()
end

function write_dist(new_dist)
    dist_file = io.open("/home/distance.txt", "w")
    dist_file:write(curr_dist)
    dist_file:flush()
    curr_dist = new_dist
    dist_file:close()
end

function get_distance()
    debug("current distance is %d", curr_dist)
    return curr_dist
end

function set_distance(new_dist)
    write_dist(new_dist)
end

function incr_distance()
    set_distance(curr_dist + 1)
end

open_dist()

function get_power()
    return computer.energy() / computer.maxEnergy()
end

function new_status(power, dist)
    power = power or get_power()
    dist = dist or get_distance()
    return {
        distance = dist,
        power = power,
        experience = exp.level()
    }
end

function update_status()
    data = new_status()
    send_notif(MESSAGE_TYPES.STATUS, data)
end

function respond_status()
    data = new_status()
    send_response(MESSAGE_TYPES.STATUS, data)
end