-- by lovrewe

assert(getscriptbytecode, "Exploit not supported.")

local API = "http://api.plusgiant5.com"

local last_call = 0

local request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
if not request then
    request = function() error("konstant.lua: No HTTP request function available on this executor") end
end

local cache = setmetatable({}, { __mode = "v" })

local function call(konstantType, scriptPath)
	local success, bytecode = pcall(getscriptbytecode, scriptPath)

	if (not success) then
		return `-- Failed to get script bytecode, error:\n\n--[[\n{bytecode}\n--]]`
	end

	local time_elapsed = os.clock() - last_call
	if time_elapsed <= .5 then
		task.wait(.5 - time_elapsed)
	end

	local cached = cache[scriptPath .. konstantType]
	if cached and os.clock() - cached.time < 60 then
		return cached.result
	end

	local httpResult
	for retry = 1, 3 do
		httpResult = request({
			Url = API .. konstantType,
			Body = bytecode,
			Method = "POST",
			Headers = {
				["Content-Type"] = "text/plain"
			}
		})
		if httpResult and httpResult.StatusCode == 200 then break end
		task.wait(1)
	end

	last_call = os.clock()

	if (not httpResult) then
		return "-- Error occurred while requesting Konstant API, error:\n\n--[[\nRequest returned nil after 3 retries\n--]]"
	elseif (httpResult.StatusCode ~= 200) then
		return `-- Error occurred while requesting Konstant API, error:\n\n--[[\n{httpResult.Body}\n--]]`
	else
		cache[scriptPath .. konstantType] = { result = httpResult.Body, time = os.clock() }
		return httpResult.Body
	end
end

local function decompile(scriptPath)
	return call("/konstant/decompile", scriptPath)
end

local function disassemble(scriptPath)
	return call("/konstant/disassemble", scriptPath)
end

getgenv().decompile = decompile
getgenv().disassemble = disassemble
getgenv().konstant_api = { decompile = decompile, disassemble = disassemble, clear_cache = function() cache = {} end }
