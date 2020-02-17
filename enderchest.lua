local inventory = component.inventory_controller
local sides = require("sides")

function ec_slot()
    return robot.inventorySize()
end

function ec_side()
    return sides.front
end

function ec_place()
    robot.select(ec_slot())
    try_place("ender chest")
end

function ec_pickup()
    robot.select(ec_slot())
    local stack = inventory.getStackInInternalSlot(ec_slot())
    if stack then
        warn("Picked up something, gonna drop that: %s", stack.name)
        robot.drop()
    end
    local success, err = robot.swing()
    print(success)
    if not success then
        error("Could not pickup ender chest: %s", err)
    end
    robot.select(1)
end

function ec_size()
    return inventory.getInventorySize(ec_side())
end

function ec_stack(slot)
    return inventory.getStackInSlot(ec_side(), slot)
end

function ec_next_free()
    for i = 1, ec_size(), 1 do
        if not ec_stack(i) then
            return i
        end
    end
    return nil
end

function ec_find_slot(name)
    for i = 1, ec_size(), 1 do
        stack = ec_stack(i)
        if stack and string.match(stack.name, name) then
            return i
        end
    end
    return nil
end

function ec_deposit(slot)
    robot.select(slot)
    local success, err = inventory.dropIntoSlot(ec_side(), ec_next_free())
    if not success then
        error("Could not deposit item in slot %d: %s", slot, err)
    end
    return success
end

function ec_retrieve(slot)
    local success = inventory.suckFromSlot(ec_side(), slot)
    if not success then
        error("Could not retrieve item in slot %d", slot)
    end
    return success
end