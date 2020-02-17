

LOG_LEVELS = {
    DEBUG = "debug",
    INFO = "info",
    WARN = "warn",
    ERROR = "error"
}

function printf(...)
    print(string.format(...))
end

function log(level, message, ...)
    printf("[%s] %s", level, string.format(message, ...))
end

function debug(message, ...)
    log(LOG_LEVELS.DEBUG, message, ...)
end

function info(message, ...)
    log(LOG_LEVELS.INFO, message, ...)
end

function warn(message, ...)
    log(LOG_LEVELS.WARN, message, ...)
end

function error(message, ...)
    log(LOG_LEVELS.ERROR, message, ...)
end

function tbl_to_str(tbl, indent)
    if not indent then indent = 0 end
    ret = "{ "
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
          -- print(formatting)
          ret = ret .. formatting .. tbl_to_str(v, indent+1)
        elseif type(v) == 'boolean' then
          ret = ret .. formatting .. tostring(v) 
        else
          ret = ret .. formatting .. v
        end
        ret = ret .. ", "
    end
    ret = ret .. "}"
    return ret
end