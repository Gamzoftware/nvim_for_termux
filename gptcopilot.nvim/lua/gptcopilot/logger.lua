
local M = {}

local levels = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
}

local labels = {
    [1] = "DEBUG",
    [2] = "INFO",
    [3] = "WARN",
    [4] = "ERROR",
}

-- Obtener configuración del logger
local function options()
    local ok, config = pcall(require, "gptcopilot.config")

    if not ok then
        return {
            enabled = true,
            level = "INFO",
            max_size_kb = 1024,
        }
    end

    return config.get().logging or {}
end

-- Obtener ruta del archivo
function M.path()
    local opts = options()
    local path = opts.file

    if type(path) ~= "string" or path == "" then
        path = vim.fn.stdpath("state") .. "/gptcopilot.log"
    end

    return vim.fn.expand(path)
end

-- Protección de información sensible
local function redact(message)
    message = tostring(message or "")
    message = message:gsub("[\r\n\t]", " ")

    message = message:gsub(
        "[Bb]earer%s+[^%s,;]+",
        "Bearer [REDACTED]"
    )

    message = message:gsub(
        "sk%-[%w_%-]+",
        "[REDACTED]"
    )

    message = message:gsub(
        "AIza[%w_%-]+",
        "[REDACTED]"
    )

    -- Ocultar las API Keys configuradas en el entorno
    local ok, config = pcall(require, "gptcopilot.config")

    if ok then
        for _, provider in pairs(config.get().providers or {}) do
            local key = provider.api_key_env
                and os.getenv(provider.api_key_env)

            if key and #key >= 6 then
                message = message:gsub(
                    vim.pesc(key),
                    "[REDACTED]"
                )
            end
        end
    end

    return message
end

-- Rotación de archivos
local function rotate(path, max_size_kb)
    local f = io.open(path, "r")

    if not f then
        return
    end

    local size = f:seek("end") or 0
    f:close()

    if size < (tonumber(max_size_kb) or 1024) * 1024 then
        return
    end

    os.remove(path .. ".1")
    os.rename(path, path .. ".1")
end

-- Registrar mensaje
function M.log(level, message)
    local opts = options()

    if opts.enabled == false then
        return
    end

    level = tostring(level or "INFO"):upper()

    local numeric = levels[level] or levels.INFO

    local threshold = levels[
        tostring(opts.level or "INFO"):upper()
    ] or levels.INFO

    if numeric < threshold then
        return
    end

    local path = M.path()

    local ok, err = pcall(function()
        vim.fn.mkdir(
            vim.fn.fnamemodify(path, ":h"),
            "p"
        )

        rotate(path, opts.max_size_kb)

        local file = assert(io.open(path, "a"))

        file:write(string.format(
            "[%s] [%s] %s\n",
            os.date("%Y-%m-%d %H:%M:%S"),
            labels[numeric],
            redact(message)
        ))

        file:close()

        pcall(vim.fn.setfperm, path, "rw-------")
    end)

    if not ok then
        -- Evitar recursión si falla el propio logger
        vim.schedule(function()
            vim.api.nvim_err_writeln(
                "gptcopilot logger: " .. tostring(err)
            )
        end)
    end
end

-- Métodos por nivel
function M.debug(message)
    M.log("DEBUG", message)
end

function M.info(message)
    M.log("INFO", message)
end

function M.warn(message)
    M.log("WARN", message)
end

function M.error(message)
    M.log("ERROR", message)
end

-- Abrir logs en una división horizontal
function M.open()
    local path = M.path()

    vim.fn.mkdir(
        vim.fn.fnamemodify(path, ":h"),
        "p"
    )

    local file = io.open(path, "a")

    if file then
        file:close()
    end

    vim.cmd(
        "botright split " .. vim.fn.fnameescape(path)
    )
end

-- Limpiar logs
function M.clear()
    local path = M.path()

    os.remove(path)
    os.remove(path .. ".1")

    vim.fn.mkdir(
        vim.fn.fnamemodify(path, ":h"),
        "p"
    )

    local file = io.open(path, "w")

    if not file then
        return false
    end

    file:close()

    pcall(vim.fn.setfperm, path, "rw-------")

    return true
end

return M

