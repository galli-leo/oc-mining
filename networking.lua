local tunnel = component.tunnel
local event = require("event")

MESSAGE_DIRECTION = {
    REQUEST = "request",
    RESPONSE = "response",
    NOTIFICATION = "notification"
}

MESSAGE_TYPES = {
    STATUS = "status",
    QUIT = "quit",
    DISLOCATOR = "dislocator"
}

function new_message(m_type, direction, data)
    return {
        direction = direction,
        type = m_type,
        data = data or {}
    }
end

function data_from_values(m_type, values)
    if m_type == MESSAGE_TYPES.STATUS then
        return {
            power = values[3],
            distance = values[1],
            experience = values[2]
        }
    end
    return {}
end

function modem_message(d)
    local loc_addr = d[2]
    local rem_addr = d[3]
    local prt = d[4]
    local dist = d[5]
    local direction = d[6]
    local m_type = d[7]
    local values = {}
    for i = 8, #d, 1 do
        table.insert(values, d[i])
    end
    local data = data_from_values(m_type, values)
    debug("Received packet from %s, with payload %s", rem_addr, tbl_to_str(data))
    return {
        local_addr = loc_addr,
        remote_addr = rem_addr,
        port = prt,
        distance = dist,
        message = new_message(m_type, direction, data)
    }
end

function low_level_poll(timeout)
    local d = table.pack(event.pull(timeout, "modem_message"))
    if #d < 6 then
        return nil
    end
    
    return modem_message(d)
end

function low_level_send(message)
    debug("Sending message %s", tbl_to_str(message))
    vals = {}
    for k, v in pairs(message.data) do
        table.insert(vals, v)
    end
    tunnel.send(message.direction, message.type, table.unpack(vals))
end

function new_request(m_type, data)
    return new_message(m_type, MESSAGE_DIRECTION.REQUEST, data)
end

function new_response(m_type, data)
    return new_message(m_type, MESSAGE_DIRECTION.RESPONSE, data)
end

function new_notif(m_type, data)
    return new_message(m_type, MESSAGE_DIRECTION.NOTIFICATION, data)
end

function send_request(m_type, data)
    message = new_request(m_type, data)
    low_level_send(message)
    resp = low_level_poll()
    response = resp.message
    if response.direction ~= MESSAGE_DIRECTION.RESPONSE then
        error("Received non Response packet as response!: %s", tbl_to_str(payload))
    end
    if response.type ~= message.type then
        error("Received non matching response type!: %s", tbl_to_str(payload))
    end
    return response
end

function send_notif(m_type, data)
    message = new_notif(m_type, data)
    low_level_send(message)
end

function send_response(m_type, data)
    message = new_response(m_type, data)
    low_level_send(message)
end

function recv_notif()
    wrapper = low_level_poll(0.1)
    if not wrapper then
        return nil
    end
    return wrapper.message
end

function recv_request()
    wrapper = low_level_poll(0.1)
    if not wrapper then
        return nil
    end
    return wrapper.message
end

listeners = {
    notification = {

    },
    request = {

    }
}

function add_listener(direction, m_type, fn)
    listeners[direction][m_type] = fn
end

function modem_message_handler(...)
    mm = modem_message(table.pack(...))
    debug("Parsed modem message: %s", tbl_to_str(mm))
    message = mm.message
    list = listeners[message.direction][message.type]
    if list then
        list(message.data)
    end
end

event.listen("modem_message", modem_message_handler)