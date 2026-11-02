-- Minimal World of Warcraft API mock so RPGThreat.lua can run under plain Lua.
local M = {}

local function new_frame()
    local frame = { scripts = {}, shown = false }
    function frame:SetScript(name, fn) self.scripts[name] = fn end
    function frame:Show() self.shown = true end
    function frame:Hide() self.shown = false end
    function frame:IsShown() return self.shown end
    function frame:CreateTexture() return new_frame() end
    return setmetatable(frame, { __index = function() return function() end end })
end

-- opts: classToken, playerName, targetName
function M.load_addon(opts)
    opts = opts or {}
    local env = {
        now = 100,
        threat = 0,
        has_target = true,
        sounds = {},
        emotes = {},
        frames = {},
    }

    function CreateFrame()
        local frame = new_frame()
        env.frames[#env.frames + 1] = frame
        return frame
    end
    UIParent = {}
    SlashCmdList = {}
    C_Timer = { After = function() end }

    GetTime = function() return env.now end
    UnitExists = function() return env.has_target end
    UnitName = function(unit)
        if unit == "player" then return opts.playerName or "Hero" end
        return opts.targetName or "Ogre"
    end
    UnitClass = function() return "Localized", opts.classToken or "WARRIOR" end
    UnitClassification = function() return "normal" end
    UnitThreatSituation = function() return env.threat end
    PlaySoundFile = function(path) env.sounds[#env.sounds + 1] = path end
    SendChatMessage = function(msg, channel)
        env.emotes[#env.emotes + 1] = { msg = msg, channel = channel }
    end

    dofile("RPGThreat.lua")

    local addon = env.frames[1]
    function env.fire(event)
        addon.scripts.OnEvent(addon, event)
    end
    function env.vignette_shown()
        -- The vignette frame is created on PLAYER_LOGIN (second frame)
        return env.frames[2] ~= nil and env.frames[2]:IsShown()
    end
    return env
end

return M
