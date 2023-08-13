--[[
Name: ["Player Speed Multiplier"]
Version: [1.0.0]
Description: ["Lua script that allows you to set the speed multiplier of walk and swim speed. Visible under the 'Self' tab."]
Author: ["Harmless"]
--]]

selfTab = gui.get_tab("GUI_TAB_SELF")

selfTab:add_imgui(function()
    ImGui.Text("Walk Speed Multiplier")
    walkCB, walkToggled = ImGui.Checkbox("Set Walk Speed", walkCB)
    walkSpeed, walkUsed = ImGui.SliderFloat("Walk speed multiplier", walkSpeed, 1, 1.49)

    ImGui.Text("Swim Speed Multiplier")
    swimCB, swimToggled = ImGui.Checkbox("Set Swim Speed", swimCB)
    swimSpeed, swimUsed = ImGui.SliderFloat("Swim speed multiplier", swimSpeed, 1, 1.49)
end)

local walkSpeed = 1.2
local swimSpeed = 1.2

script.register_looped("loops", function (script)
    if walkCB then
        PLAYER.SET_RUN_SPRINT_MULTIPLIER_FOR_PLAYER(PLAYER.PLAYER_ID(), walkSpeed)
    else
        PLAYER.SET_RUN_SPRINT_MULTIPLIER_FOR_PLAYER(PLAYER.PLAYER_ID(), 1.0)
    end
    if swimCB then
        PLAYER.SET_SWIM_MULTIPLIER_FOR_PLAYER(PLAYER.PLAYER_ID(), swimSpeed)
    else
        PLAYER.SET_SWIM_MULTIPLIER_FOR_PLAYER(PLAYER.PLAYER_ID(), 1.0)
    end
end)





--I want to kill myself. This script took way too long to make :)