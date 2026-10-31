-- RPGThreat - Immersive RPG-style Threat Tracking Addon
-- Translates threat changes into atmospheric in-game feedback

local RPGThreat = CreateFrame("Frame")
RPGThreat:RegisterEvent("PLAYER_TARGET_CHANGED")
RPGThreat:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
RPGThreat:RegisterEvent("PLAYER_LOGIN")

-- Configuration
local CONFIG = {
    -- Throttle settings (anti-spam)
    EMOTE_THROTTLE_SECONDS = 2.0,
    AUDIO_THROTTLE_SECONDS = 0.5,
    
    -- Audio paths (using escaped backslashes from root)
    SOUNDS = {
        HEARTBEAT = "Interface\\AddOns\\RPGThreat\\Sounds\\heartbeat.ogg",
        WARNING = "Interface\\AddOns\\RPGThreat\\Sounds\\warning.ogg",
        AGGRO = "Interface\\AddOns\\RPGThreat\\Sounds\\aggro.ogg"
    },
    
    -- Class-specific emotes (can be extended)
    CLASS_EMOTES = {
        WARRIOR = {
            [1] = "tenses up, gripping their weapon tightly.",
            [2] = "roars in defiance!",
            [3] = "charges forward, drawing aggro with a battle cry!"
        },
        ROGUE = {
            [1] = "shifts nervously, watching for an opening.",
            [2] = "hisses in frustration as attention shifts.",
            [3] = "vanishes into the shadows, only to reappear with a flurry of blades!"
        },
        MAGE = {
            [1] = "mumbles an incantation, arcane energy crackling.",
            [2] = "gasps as magical focus wavers.",
            [3] = "unleashes a torrent of spells, drawing all eyes!"
        },
        HUNTER = {
            [1] = "cautiously nudges their pet forward.",
            [2] = "whistles sharply, signaling their companion.",
            [3] = "fires a warning shot into the air!"
        },
        -- Default for classes not specifically defined
        DEFAULT = {
            [1] = "feels the tension building.",
            [2] = "senses danger as threat rises!",
            [3] = "draws the attention of the enemy!"
        }
    }
}

-- State tracking
local lastState = nil
local lastEmoteTime = 0
local lastAudioTime = 0

-- Vignette frames
local vignetteFrame = nil
local vignetteTexture = nil

-- Threat tier names for clarity
local THREAT_NAMES = {
    [0] = "SAFE",
    [1] = "TENSION",
    [2] = "LOOSING_CONTROL",
    [3] = "AGGRO"
}

-- Throttle check helper
local function CanTriggerEmote()
    local currentTime = GetTime()
    if currentTime - lastEmoteTime >= CONFIG.EMOTE_THROTTLE_SECONDS then
        lastEmoteTime = currentTime
        return true
    end
    return false
end

local function CanTriggerAudio()
    local currentTime = GetTime()
    if currentTime - lastAudioTime >= CONFIG.AUDIO_THROTTLE_SECONDS then
        lastAudioTime = currentTime
        return true
    end
    return false
end

-- Get class-specific emote or fallback to default
local function GetEmoteForState(state)
    local playerClass = UnitClass("player")
    local classEmotes = CONFIG.CLASS_EMOTES[playerClass]
    
    if classEmotes and classEmotes[state] then
        return classEmotes[state]
    else
        return CONFIG.CLASS_EMOTES.DEFAULT[state] or ""
    end
end

-- Target filter: Check if target is Boss or Elite
local function IsPriorityTarget(targetUnit)
    if not targetUnit then return false end
    
    local classification = UnitClassification(targetUnit)
    if classification == "worldboss" or classification == "boss" or classification == "elite" then
        return true
    end
    
    return false
end

-- Create vignette frame
local function CreateVignette()
    if vignetteFrame then return end
    
    vignetteFrame = CreateFrame("Frame", "RPGThreatVignette", UIParent)
    vignetteFrame:SetFrameStrata("BACKGROUND")
    vignetteFrame:SetAllPoints(UIParent)
    vignetteFrame:Hide()
    
    vignetteTexture = vignetteFrame:CreateTexture(nil, "BACKGROUND")
    vignetteTexture:SetAllPoints(vignetteFrame)
    vignetteTexture:SetBlendMode("BLEND")
end

-- Update vignette based on threat state
local function UpdateVignette(state)
    if not vignetteFrame then CreateVignette() end
    
    if state == 0 then
        -- Safe: Hide vignette
        if vignetteFrame:IsShown() then
            vignetteFrame:Hide()
        end
    elseif state == 1 then
        -- Tension: Orange border vignette
        vignetteFrame:Show()
        vignetteTexture:SetTexture(1, 0.5, 0, 0.3) -- Orange with alpha
    elseif state == 2 or state == 3 then
        -- Losing Control / Aggro: Heavy red vignette
        vignetteFrame:Show()
        vignetteTexture:SetTexture(1, 0, 0, 0.5) -- Red with alpha
    end
end

-- Play sound based on state
local function PlayThreatSound(state)
    if not CanTriggerAudio() then return end
    
    local soundPath = nil
    if state == 1 then
        soundPath = CONFIG.SOUNDS.HEARTBEAT
    elseif state == 2 then
        soundPath = CONFIG.SOUNDS.WARNING
    elseif state == 3 then
        soundPath = CONFIG.SOUNDS.AGGRO
    end
    
    if soundPath then
        PlaySoundFile(soundPath, "Master")
    end
end

-- Broadcast emote to local chat
local function BroadcastEmote(state)
    if not CanTriggerEmote() then return end
    
    local targetName = UnitName("target") or "the enemy"
    local emoteText = GetEmoteForState(state)
    
    if emoteText and emoteText ~= "" then
        -- Format: "CharacterName emoteText (targetName)"
        local message = string.format("%s %s (%s)", UnitName("player"), emoteText, targetName)
        SendChatMessage(message, "EMOTE")
    end
end

-- Check if we should process threat for current target
local function ShouldProcessThreat()
    -- Must have a target
    if not UnitExists("target") then return false end
    
    -- Optional: Only process for priority targets (bosses/elites)
    -- Uncomment the next line to enable this filter
    -- if not IsPriorityTarget("target") then return false end
    
    return true
end

-- Main threat update handler
local function UpdateThreat()
    if not ShouldProcessThreat() then
        -- No valid target, ensure vignette is hidden
        if vignetteFrame and vignetteFrame:IsShown() then
            vignetteFrame:Hide()
        end
        lastState = nil
        return
    end
    
    local currentState = UnitThreatSituation("player", "target") or 0
    
    -- Clamp to valid range
    if currentState < 0 then currentState = 0 end
    if currentState > 3 then currentState = 3 end
    
    -- Only trigger on state changes
    if currentState == lastState then return end
    
    -- State changed - handle transition
    UpdateVignette(currentState)
    PlayThreatSound(currentState)
    
    -- Only emote for elevated threat states (not safe)
    if currentState > 0 then
        BroadcastEmote(currentState)
    end
    
    lastState = currentState
end

-- Event handlers
RPGThreat:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Initialize on login
        CreateVignette()
        lastState = nil
        
    elseif event == "PLAYER_TARGET_CHANGED" then
        -- Target changed, reset state and update
        lastState = nil
        UpdateThreat()
        
    elseif event == "UNIT_THREAT_LIST_UPDATE" then
        -- Threat list updated
        UpdateThreat()
    end
end)

-- Slash command for manual testing
SLASH_RPGTHREAT1 = "/rpgthreat"
SLASH_RPGTHREAT2 = "/rt"

SlashCmdList["RPGTHREAT"] = function(cmd)
    if cmd == "test" then
        -- Test all states
        for state = 0, 3 do
            UpdateVignette(state)
            PlayThreatSound(state)
            -- Small delay between tests
            C_Timer.After(1, function()
                UpdateVignette(0)
            end)
        end
        print("RPGThreat: Test cycle initiated")
    elseif cmd == "reset" then
        -- Reset state
        lastState = nil
        if vignetteFrame then
            vignetteFrame:Hide()
        end
        print("RPGThreat: State reset")
    else
        print("RPGThreat v1.0.0")
        print("Commands:")
        print("  /rpgthreat test - Cycle through all threat states")
        print("  /rpgthreat reset - Reset threat state")
    end
end
