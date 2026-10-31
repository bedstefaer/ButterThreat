std = "lua51"
max_line_length = false

-- Unused locals/arguments exist as planned extension points (e.g. IsPriorityTarget);
-- 61x are whitespace-style warnings
ignore = { "211", "212", "611", "612", "613", "614" }

-- WoW API globals used by the addon
read_globals = {
    "CreateFrame", "UIParent", "GetTime", "UnitExists", "UnitName", "UnitClass",
    "UnitClassification", "UnitThreatSituation", "PlaySoundFile", "SendChatMessage",
    "C_Timer",
}
globals = { "SlashCmdList", "SLASH_RPGTHREAT1", "SLASH_RPGTHREAT2" }

-- Tests redefine the WoW globals as mocks
files["tests/"] = {
    globals = {
        "CreateFrame", "UIParent", "GetTime", "UnitExists", "UnitName", "UnitClass",
        "UnitClassification", "UnitThreatSituation", "PlaySoundFile", "SendChatMessage",
        "C_Timer", "SlashCmdList",
    },
}