--[[
Name: ["Ragdoll Player"]
Version: [1.0.1]
Description: ["Lua script that allows you to ragdoll yourself once or looped, with customizable options. Visible under the 'Self -> Ragdoll Player' tab."]
Author: ["Harmless"]
Discord: ["harmless0"]
--]]

ragdollTab = gui.get_tab("GUI_TAB_SELF"):add_tab("Ragdoll Player")

function ragdollPlayer()
	local forceFlags = ForceFlags:get_value()
	local ragdollType = RagdollTypes:get_value()
	local forcex = Forcex:get_value()
	local forcey = Forcey:get_value()
	local forcez = Forcez:get_value()
    local players = PLAYER.PLAYER_PED_ID()
	PED.SET_PED_TO_RAGDOLL(players, -1, 0, ragdollType, true, true, false)
	ENTITY.APPLY_FORCE_TO_ENTITY(players, forceFlags, forcex, forcey, forcez, 0, 0, 0, 0, false, true, true, false, true)
end

script.register_looped("ragdollPlayerLoop", function (script)
    if loop:is_enabled() then
        local loops = loopSpeed:get_value()
        local forceFlags = ForceFlags:get_value()
		local ragdollType = RagdollTypes:get_value()
        local forcex = Forcex:get_value()
        local forcey = Forcey:get_value()
        local forcez = Forcez:get_value()
        local players = PLAYER.PLAYER_PED_ID()
        PED.SET_PED_TO_RAGDOLL(players, -1, 0, ragdollType, true, true, false)
        ENTITY.APPLY_FORCE_TO_ENTITY(players, forceFlags, forcex, forcey, forcez, 0, 0, 0, 0, false, true, true, false, true)
        script:sleep(loops)
    end
end)

ragdollTab:add_button("Ragdoll Player [Once]", ragdollPlayer)
ragdollTab:add_separator()
loop = ragdollTab:add_checkbox("Ragdoll Player [Loop]")
loopSpeed = ragdollTab:add_input_int("Loop Speed")
ragdollTab:add_separator()
RagdollTypes = ragdollTab:add_input_int("Ragdoll Types 0-3")
ragdollTab:add_separator()
ForceFlags = ragdollTab:add_input_int("Force Types 1-5")
Forcex = ragdollTab:add_input_int("Force X")
Forcey = ragdollTab:add_input_int("Force Y")
Forcez = ragdollTab:add_input_int("Force Z")

loopSpeed:set_value(500)
ForceFlags:set_value(1)
Forcex:set_value(10)
Forcey:set_value(10)
Forcez:set_value(10)
