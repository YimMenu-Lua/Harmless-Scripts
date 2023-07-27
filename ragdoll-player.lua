--[[
Name: ["Ragdoll Player"]
Version: [1.0.0]
Description: ["Lua script that allows you to ragdoll yourself once or looped, with customizable options. Visible under the 'Self' tab."]
Author: ["Harmless"]
Discord: ["harmless0"]
--]]

function ragdollPlayer()
	forceFlags = tostring(ForceFlags:get_value())
	forcex = tostring(Forcex:get_value())
	forcey = tostring(Forcey:get_value())
	forcez = tostring(Forcez:get_value())
    players = PLAYER.PLAYER_PED_ID()
	PED.SET_PED_TO_RAGDOLL(players, 10000, 3000, 0, true, true, false)
	ENTITY.APPLY_FORCE_TO_ENTITY(players, forceFlags, forcex, forcey, forcez, 0, 0, 0, 0, false, true, true, false, true)
end

script.register_looped("ragdollPlayerLoop", function()
	
	if loop:is_enabled() then
		ragdollPlayer()
		loops = tostring(loopSpeed:get_value())
		forceFlags = tostring(ForceFlags:get_value())
		forcex = tostring(Forcex:get_value())
		forcey = tostring(Forcey:get_value())
		forcez = tostring(Forcez:get_value())
    	PLAYERS = PLAYER.PLAYER_PED_ID()
		PED.SET_PED_TO_RAGDOLL(players, 10000, 3000, 0, true, true, false)
		ENTITY.APPLY_FORCE_TO_ENTITY(players, forceFlags, forcex, forcey, forcez, 0, 0, 0, 0, false, true, true, false, true)
		script_util:sleep(loops)
	end
end)

ragdollTab = gui.get_tab("GUI_TAB_SELF"):add_tab("Ragdoll Player")

ragdollTab:add_button("Ragdoll Player [Once]", ragdollPlayer)
ragdollTab:add_separator()
loop = ragdollTab:add_checkbox("Ragdoll Player [Loop]")
loopSpeed = ragdollTab:add_input_int("Loop Speed")
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