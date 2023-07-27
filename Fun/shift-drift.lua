--[[
Name: ["Shift Drift"]
Version: [1.0.0]
Description: ["Lua script that allows you to press [shift] to drift. Visible under the 'Vehicle -> Fun Features' tab."]
Author: ["Harmless"]
Discord: ["harmless0"]
--]]

driftTab = gui.get_tab("GUI_TAB_FUN_VEHICLE")


script.register_looped("ShiftDrift", function()
    if shiftDriftCB:is_enabled() and PAD.IS_CONTROL_PRESSED(0, 21) then
        CurrentVeh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
        VEHICLE.SET_VEHICLE_REDUCE_GRIP(CurrentVeh, true)
        VEHICLE.SET_VEHICLE_REDUCE_GRIP_LEVEL(CurrentVeh, driftAmount:get_value())
    else
        VEHICLE.SET_VEHICLE_REDUCE_GRIP(CurrentVeh, false)
    end
end)

shiftDriftCB = driftTab:add_checkbox("Shift Drift")
driftAmount = driftTab:add_input_int("Drift Amount 0-3")
driftTab:add_text("3 = No Drift")
driftAmount:set_value(0)