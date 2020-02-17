local inventory = component.inventory_controller
local sides = require("sides")
local redstone = component.redstone

function charger_slot()
    return robot.inventorySize() - 2
end

function capacitor_slot()
    return robot.inventorySize() - 1
end

function start_charging()
    local ec_cap_slot = ec_find_slot("block_cap_bank")
    robot.select(capacitor_slot())
    ec_retrieve(ec_cap_slot)

    robot.turnRight()
    -- place charger
    robot.select(charger_slot())
    try_place("charger")
    -- place capacitor
    robot.select(capacitor_slot())
    robot.swingUp()
    robot.up()
    try_place("capacitor")

    -- charge
    robot.down()
    redstone.setOutput(sides.front, 16)

    -- put pickaxe into charger
    inventory.equip()
    inventory.dropIntoSlot(sides.front, 1)
end

function ensure_slot(name, slot)
    robot.select(slot)
    for i = 1, robot.inventorySize(), 1 do
        stack = inventory.getStackInInternalSlot(i)
        if stack then
            print(stack.name)
            if string.match(stack.name, name) then
                -- swap
                robot.transferTo(i)
                return
            end
        end
    end
end

function end_charging()
    redstone.setOutput(sides.front, 0)
    -- get pickaxe
    inventory.suckFromSlot(sides.front, 1)
    inventory.equip()

    -- get charger and capacitor back (magic of draconic tools)
    robot.select(charger_slot())
    robot.swing()

    -- make sure they are in correct slot
    ensure_slot("charger", charger_slot())
    ensure_slot("block_cap_bank", capacitor_slot())

    -- get capacitor back
--[[     robot.swingUp()
    robot.up()
    robot.select(capacitor_slot())
    robot.swing() ]]

    -- finally
    -- robot.down()
    robot.turnLeft()
    ec_deposit(capacitor_slot())
end

function do_charging()
    start_charging()
    update_status()
    os.sleep(20.0)
    end_charging()
end