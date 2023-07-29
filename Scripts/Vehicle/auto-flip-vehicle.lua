--[[
Name: ["Auto Flip Vehicle"]
Version: [1.0.0]
Description: ["Lua script that allows you to flip your vehicle automatically back upwards. Visible under the 'Vehicle' tab."]
Author: ["Harmless"]
Discord: ["harmless0"]
]]

script.register_looped("autoFlipVehicleLoop", function()
    if flipLoop:is_enabled() then
        players = PLAYER.PLAYER_PED_ID()
        vehicle = PED.GET_VEHICLE_PED_IS_IN(players, false)
        if vehicle ~= 0 then
            if ENTITY.IS_ENTITY_UPSIDEDOWN(vehicle) then
                getrot = ENTITY.GET_ENTITY_ROTATION(vehicle, 1)
                forwardVector = ENTITY.GET_ENTITY_FORWARD_VECTOR(vehicle)
                ENTITY.SET_ENTITY_ROTATION(vehicle, forwardVector.x, forwardVector.y, getrot.z, 1, true)
            end
        end
        script_util:sleep(1000)
    end
end)

vehicleTab = gui.get_tab("GUI_TAB_VEHICLE")
flipLoop = vehicleTab:add_checkbox("Auto Flip Vehicle")