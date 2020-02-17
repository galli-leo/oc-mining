component = require("component")
robot = require("robot")

local event = require("event")

local inventory = component.inventory_controller

dofile "config.lua"
dofile "log.lua"
dofile "networking.lua"
dofile "util.lua"
dofile "status.lua"
dofile "enderchest.lua"
dofile "charging.lua"

info("Starting up main for robot...")

running = true

--[[ while running do
    -- update_status()
end ]]

function is_ore(stack)
    return string.match(stack.name, "_ore")
end

function deposit_ores()
    for i = 1, robot.inventorySize(), 1 do
        stack = inventory.getStackInInternalSlot(i)
        if stack and is_ore(stack) then
            ec_deposit(i)
        end
    end
end

inv = {}

function cache_inv()
    for i = 1, robot.inventorySize(), 1 do
        stack = inventory.getStackInInternalSlot(i)
        inv[i] = stack
    end
end

event.listen("inventory_changed", function(name, slot)
    info("inventory slot: %s", slot)
    inv[slot] = inventory.getStackInInternalSlot(slot)
end)

function free_slots()
--[[     if num_iter % 40 == 0 then
        cache_inv()
    end ]]
    ret = 0
    nextFree = robot.inventorySize()
    for i = 1, robot.inventorySize(), 1 do
        stack = inv[i]
        if not stack then
            ret = ret + 1
        end
    end
    return ret
end

function should_deposit()
    return (free_slots() < 8) or (num_iter % 100 == 0)
end

function should_charge()
    return get_power() < 0.1 -- 10 percent battery left!
end

function should_do_something()
    return should_deposit() or should_charge()
end

function dislocator_slot()
    return robot.inventorySize() - 3
end

function create_dislocator()
    ec_place()
    robot.select(dislocator_slot())
    inventory.equip()
    robot.use(1, true)
    inventory.equip()
    ec_deposit(dislocator_slot())
    exit_now()
end

add_listener(MESSAGE_DIRECTION.REQUEST, MESSAGE_TYPES.STATUS, function(data)
    respond_status()
end)

-- ensure consistent state!
ec_place()
deposit_ores()
do_charging()
ec_pickup()

cache_inv()

num_iter = 1
running = true

add_listener(MESSAGE_DIRECTION.REQUEST, MESSAGE_TYPES.QUIT, function(data)
    respond_status()
    exit_now()
end)

add_listener(MESSAGE_DIRECTION.REQUEST, MESSAGE_TYPES.DISLOCATOR, function(data)
    respond_status()
    create_dislocator()
end)

while running do
    -- first swing
    robot.swing()
    -- then try to move
    local success, err = robot.forward()
    if success then
        incr_distance()
    else
        warn("Had error trying to move: %s", err)
    end
    if should_do_something() then
        ec_place()
        if should_deposit() then
            deposit_ores()
        end
        if should_charge() then
            do_charging()
        end
        ec_pickup()
    end
    num_iter = num_iter + 1
    os.sleep(0.1) -- to be able to receive messages?
end
