-- domain is gone so external fetch doesn't work; self-contained replacement below
-- Original fetched from keybase.pub which no longer exists
-- This is a fully self-contained gravity controller

-- Re-execution guard
if getgenv().__gravityController_loaded then return end
getgenv().__gravityController_loaded = true

local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))

local config = {
    Gravity = workspace.Gravity,
    CustomGravity = 50,
    Enabled = false,
    KeyBind = Enum.KeyCode.G,
    AntiGravity = false,
}

pcall(function()
    local data = readfile("gravityController_config.json")
    if data then
        local decoded = HttpService:JSONDecode(data)
        for k, v in pairs(decoded) do
            config[k] = v
        end
    end
end)

local function saveConfig()
    pcall(function() writefile("gravityController_config.json", HttpService:JSONEncode(config)) end)
end

local function applyGravity()
    if config.Enabled then
        workspace.Gravity = config.AntiGravity and 0 or config.CustomGravity
    else
        workspace.Gravity = config.Gravity
    end
end

local function toggle()
    config.Enabled = not config.Enabled
    applyGravity()
    saveConfig()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == config.KeyBind then
        toggle()
    end
end)

RunService.Heartbeat:Connect(function()
    if config.Enabled then
        workspace.Gravity = config.AntiGravity and 0 or config.CustomGravity
    end
end)

local gravityController = {
    enable = function() config.Enabled = true; applyGravity(); saveConfig() end,
    disable = function() config.Enabled = false; applyGravity(); saveConfig() end,
    toggle = toggle,
    setGravity = function(val) config.CustomGravity = val; applyGravity(); saveConfig() end,
    setKeyBind = function(key) config.KeyBind = key; saveConfig() end,
    setAntiGravity = function(val) config.AntiGravity = val; applyGravity(); saveConfig() end,
    getConfig = function() return config end,
    Loader = nil,
    Version = "2.0-selfcontained",
}
getgenv().gravityController = gravityController

print("gravityController v2.0 loaded (self-contained; keybase.pub domain dead)")
