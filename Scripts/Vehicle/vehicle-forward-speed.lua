--[[
Name: ["Set Vehicle Forward Speed"]
Version: [1.0.0]
Description: ["Lua script that allows you to set the forward speed of your vehicle. Visible under the 'Vehicle -> Fun Features' tab."]
Author: ["Harmless"]
Discord: ["harmless0"]
--]]

forwardSpeedTab = gui.get_tab("GUI_TAB_FUN_VEHICLE")

script.register_looped("SetVehicleForwardSpeed", function()
    if forwardSpeed:is_enabled() and PAD.IS_CONTROL_PRESSED(0, 32) then
        speed = speedBoost:get_value()
        CurrentVeh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)  
        VEHICLE.SET_VEHICLE_FORWARD_SPEED(CurrentVeh, speed)
    end
end)

forwardSpeed = forwardSpeedTab:add_checkbox("Enable Forward Speed Boost")
speedBoost = forwardSpeedTab:add_input_int("Boosted Speed")
speedBoost:set_value(100)