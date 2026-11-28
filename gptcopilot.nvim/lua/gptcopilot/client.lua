local M = {}
function M.request(prompt, context, callback)
  local opts = require("gptcopilot.config").get()
  local logger = require("gptcopilot.logger")
  local provider_name = opts.provider
  local provider = assert(opts.providers[provider_name], "Unknown provider: " .. provider_name)
  local model = opts.model or provider.model
  local cache = require("gptcopilot.cache")
  local key = cache.key({ provider = provider_name, model = model, prompt = prompt, context = context })
  local cached = opts.cache.enabled and cache.get(key) or nil
  if cached then callback(nil, cached, true); return end
  local adapter = require("gptcopilot.providers").resolve(provider)
  local ok, url, headers, body = pcall(adapter.build, provider, model, prompt, context, opts.completion.max_output_tokens)
  if not ok then
    logger.error(
      "could not build provider request; provider=" .. provider_name
    )
    callback(url)
    return
  end

  logger.info(
    "API request started; provider=" .. provider_name ..
    "; model=" .. model
  )

  local started_at = vim.uv.hrtime()
  -- Keep API keys out of process arguments: curl reads headers from a mode-600 file.
  local header_path = vim.fn.tempname()
  local header_file = io.open(header_path, "w")
  if not header_file then
    logger.error("could not create temporary header file")
    callback("Could not create temporary header file")
    return
  end
  pcall(vim.fn.setfperm, header_path, "rw-------")
  for k, v in pairs(headers) do
    if tostring(v):find("[\r\n]") then header_file:close(); os.remove(header_path); callback("Invalid header value"); return end
    header_file:write(k .. ": " .. v .. "\n")
  end
  header_file:close()
  local args = { "curl", "--silent", "--show-error", "--fail-with-body", "--max-time", tostring(opts.request_timeout), "-X", "POST", "-H", "@" .. header_path, url, "--data-binary", "@-" }
  local output, errors = {}, {}
  local job = vim.fn.jobstart(args, {
    stdin = "pipe", stdout_buffered = true, stderr_buffered = true,
    on_stdout = function(_, data) output = data or {} end,
    on_stderr = function(_, data) errors = data or {} end,
    on_exit = function(_, code)
      os.remove(header_path)
      vim.schedule(function()
        local raw = table.concat(output, "\n")
        local elapsed_ms = math.floor(
          (vim.uv.hrtime() - started_at) / 1000000
        )

        if code ~= 0 then
          local http_error = vim.trim(raw)
          logger.error(
            "API request failed; provider=" .. provider_name ..
            "; curl_exit=" .. code ..
            "; elapsed_ms=" .. elapsed_ms ..
            "; response details omitted"
            --"; response=" .. http_error:sub(1, 1000)
          )

          callback(
            table.concat(errors, "\n") ~= "" and
            table.concat(errors, "\n") or raw
          )

          return
        end

        logger.debug(
          "API transport completed; provider=" .. provider_name ..
          "; elapsed_ms=" .. elapsed_ms
        )
        local decoded_ok, decoded = pcall(vim.json.decode, raw)
        if not decoded_ok then
          logger.error(
            "provider returned invalid JSON; provider=" .. provider_name
          )
          callback("Invalid JSON response: " .. raw:sub(1, 300))
          return
        end
        local result = adapter.extract(decoded)
        if type(result) ~= "string" or vim.trim(result) == "" then
          logger.warn(
            "provider returned an empty response; provider=" .. provider_name
          )
          callback("Provider returned an empty response")
          return
        end

        cache.set(key, result)

        logger.info(
          "API request succeeded; provider=" .. provider_name ..
          "; model=" .. model ..
          "; result_chars=" .. #result ..
          "; elapsed_ms=" .. elapsed_ms
        )

        callback(nil, result, false)
      end)
    end,
  })
  if job <= 0 then
    os.remove(header_path)
    logger.error("could not start curl process")
    callback("Could not start curl. Install curl in Termux.")
    return
  end
  vim.fn.chansend(job, vim.json.encode(body)); vim.fn.chanclose(job, "stdin")
end
return M
