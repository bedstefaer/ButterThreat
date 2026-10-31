-- Dependency-free test runner. Usage (from repo root): lua tests/run.lua
package.path = "./tests/?.lua;" .. package.path

local mock = require("wow_mock")

local tests, failed = {}, 0
local function test(name, fn) tests[#tests + 1] = { name = name, fn = fn } end

local function eq(actual, expected, label)
    if actual ~= expected then
        error(string.format("%s: expected %s, got %s", label or "value", tostring(expected), tostring(actual)), 2)
    end
end

local SOUND = "Interface\\AddOns\\RPGThreat\\Sounds\\"

local function setup(opts)
    local env = mock.load_addon(opts)
    env.fire("PLAYER_LOGIN")
    return env
end

test("safe state produces no emote and keeps vignette hidden", function()
    local env = setup()
    env.threat = 0
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(#env.emotes, 0, "emotes")
    eq(env.vignette_shown(), false, "vignette")
end)

test("elevated threat plays matching sound, emotes, and shows vignette", function()
    local env = setup()
    env.threat = 1
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(env.sounds[#env.sounds], SOUND .. "heartbeat.ogg", "sound")
    eq(env.emotes[1].msg, "Hero tenses up, gripping their weapon tightly. (Ogre)", "emote")
    eq(env.emotes[1].channel, "EMOTE", "channel")
    eq(env.vignette_shown(), true, "vignette")
end)

test("each threat tier maps to its own sound", function()
    local expected = { [1] = "heartbeat.ogg", [2] = "warning.ogg", [3] = "aggro.ogg" }
    for state, file in pairs(expected) do
        local env = setup()
        env.threat = state
        env.fire("UNIT_THREAT_LIST_UPDATE")
        eq(env.sounds[#env.sounds], SOUND .. file, "sound for state " .. state)
    end
end)

test("repeated identical state does not retrigger", function()
    local env = setup()
    env.threat = 2
    env.fire("UNIT_THREAT_LIST_UPDATE")
    env.now = env.now + 10
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(#env.emotes, 1, "emotes")
    eq(#env.sounds, 1, "sounds")
end)

test("out-of-range threat values are clamped", function()
    local env = setup()
    env.threat = 7
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(env.sounds[#env.sounds], SOUND .. "aggro.ogg", "sound")
end)

test("emote is throttled for 2s, audio for 0.5s", function()
    local env = setup()
    env.threat = 1
    env.fire("UNIT_THREAT_LIST_UPDATE")
    env.now = env.now + 0.3
    env.threat = 2
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(#env.emotes, 1, "emotes within throttle")
    eq(#env.sounds, 1, "sounds within throttle")

    env.now = env.now + 0.3
    env.threat = 3
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(#env.emotes, 1, "emotes still throttled")
    eq(#env.sounds, 2, "sound allowed after 0.5s")

    env.now = env.now + 2
    env.threat = 1
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(#env.emotes, 2, "emote allowed after 2s")
end)

test("unknown class falls back to default emotes", function()
    local env = setup({ classToken = "PALADIN" })
    env.threat = 3
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(env.emotes[1].msg, "Hero draws the attention of the enemy! (Ogre)", "emote")
end)

test("class-specific emotes are used by class token", function()
    local env = setup({ classToken = "MAGE" })
    env.threat = 2
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(env.emotes[1].msg, "Hero gasps as magical focus wavers. (Ogre)", "emote")
end)

test("losing the target hides vignette and resets state", function()
    local env = setup()
    env.threat = 3
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(env.vignette_shown(), true, "vignette before")
    env.has_target = false
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(env.vignette_shown(), false, "vignette after")
    env.has_target = true
    env.now = env.now + 10
    env.fire("UNIT_THREAT_LIST_UPDATE")
    eq(#env.emotes, 2, "same state re-fires after reset")
end)

test("target change resets state so current threat re-announces", function()
    local env = setup()
    env.threat = 2
    env.fire("UNIT_THREAT_LIST_UPDATE")
    env.now = env.now + 10
    env.fire("PLAYER_TARGET_CHANGED")
    eq(#env.emotes, 2, "emotes")
end)

for _, t in ipairs(tests) do
    local ok, err = pcall(t.fn)
    if ok then
        print("PASS  " .. t.name)
    else
        failed = failed + 1
        print("FAIL  " .. t.name .. "\n      " .. tostring(err))
    end
end

print(string.format("\n%d tests, %d failed", #tests, failed))
os.exit(failed == 0 and 0 or 1)
