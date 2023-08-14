--[[
Name: ["Player Regeneration"]
Version: [1.0.0]
Description: ["Lua script that allows you to regenerate your health and armor. Visible under the 'Self' tab."]
Author: ["Harmless"]
--]]

selfTab = gui.get_tab("GUI_TAB_SELF")

local healthregenspeed = 1 -- second(s)
local armourregenspeed = 1 -- second(s)
local healthhealamount = 10
local armourhealamount = 5

selfTab:add_imgui(function()
    ImGui.Spacing()
    healthCB, healthToggled = ImGui.Checkbox("Enable Health Regeneration", healthCB)
    healthregenspeed, hSpeedUsed = ImGui.SliderFloat("Health Regen Speed", healthregenspeed, 0, 10, "%.1f", ImGuiSliderFlags.Logarithmic)
    healthhealamount, hAmountUsed = ImGui.SliderInt("Health Regen Amount", healthhealamount, 1, 50)
    ImGui.Spacing()
    ImGui.Spacing()
    armourCB, armourToggled = ImGui.Checkbox("Enable Armor Regeneration", armourCB)
    armourregenspeed, aSpeedUsed = ImGui.SliderFloat("Armor Regen Speed", armourregenspeed, 0, 10, "%.1f", ImGuiSliderFlags.Logarithmic)
    armourhealamount, aAmountUsed = ImGui.SliderInt("Armor Regen Amount", armourhealamount, 1, 50)
end)

script.register_looped("RegenerationLoops", function(loopScript)
    if healthCB and ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID()) < ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID()) then
        local health = ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID())
        if ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID()) == health then return end
        ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), health + healthhealamount, 0)
        loopScript:sleep(healthregenspeed * 1000) -- 1ms * 1000 to get seconds
	end
    if armourCB and PED.GET_PED_ARMOUR(PLAYER.PLAYER_PED_ID()) < PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_PED_ID) then
        PED.ADD_ARMOUR_TO_PED(PLAYER.PLAYER_PED_ID(), armourhealamount)
        loopScript:sleep(armourregenspeed * 1000) -- 1ms * 1000 to get seconds
	end
end)

-- Nothing better than the empty void of space