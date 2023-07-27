--[[
Name: ["Set Vehicle Max Speed"]
Version: [1.0.0]
Description: ["Lua script that allows you to set the speed limit of your vehicle. Visible under the 'Vehicle -> Fun Features' tab."]
Note: ["Script gets overwritten by Horn Boost and Noclip"]
Author: ["Harmless"]
Discord: ["harmless0"]
--]]

maxSpeedTab = gui.get_tab("GUI_TAB_FUN_VEHICLE")

script.register_looped("SetVehicleMaxSpeed", function()
    if maxSpeedCB:is_enabled() then
        speed = speedLimit:get_value()
        CurrentVeh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)  
        VEHICLE.SET_VEHICLE_MAX_SPEED(CurrentVeh, speed)
    else
        VEHICLE.SET_VEHICLE_MAX_SPEED(CurrentVeh, 0.0)
    end
end)

maxSpeedCB = maxSpeedTab:add_checkbox("Set Max Speed")
speedLimit = maxSpeedTab:add_input_int("Speed Limit")
speedLimit:set_value(1000)