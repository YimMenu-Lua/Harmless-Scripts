--[[
Name: ["Walk on Air"]
Version: [1.0.0]
Description: [Lua script that allows you to walk on air. Visible under the 'Self' tab.
Controls: [Left SHIFT = go up, Left CTRL = go down]
Author: ["Harmless"]
--]]

selfTab = gui.get_tab("GUI_TAB_SELF")

local object = nil
local objectSpawned = false

function spawnObject()
    gui.show_message("Controls", "Left SHIFT = go up\nLeft CTRL = go down")
    local player = PLAYER.PLAYER_PED_ID()
    local coords = ENTITY.GET_ENTITY_COORDS(player, true)
    STREAMING.REQUEST_MODEL(-698352776)
    object = OBJECT.CREATE_OBJECT(-698352776, coords.x, coords.y, coords.z - 1.2, true, false, false)
    ENTITY.SET_ENTITY_ROTATION(object, 270, 0, 0, 1, true)
    ENTITY.SET_ENTITY_VISIBLE(object, false, 0)
    ENTITY.SET_ENTITY_ALPHA(object, 0, false)
    ENTITY.SET_ENTITY_COLLISION(object, true, false)
    ENTITY.SET_ENTITY_DYNAMIC(object, false)
    ENTITY.FREEZE_ENTITY_POSITION(object, true)
end

script.register_looped("walkOnAirLoop", function (scriptloop)
    if walkAirCB:is_enabled() then
        if not objectSpawned then
            spawnObject()
            objectSpawned = true
        end
        if object ~= nil then
            log.info("looping")
            local player = PLAYER.PLAYER_PED_ID()
            local playerCoords = ENTITY.GET_ENTITY_COORDS(player, true)
            local objectCoords = ENTITY.GET_ENTITY_COORDS(object, true)
            if PAD.IS_CONTROL_PRESSED(0, 36) then -- 36 = left CTRl
                ENTITY.SET_ENTITY_COORDS(object, playerCoords.x, playerCoords.y, playerCoords.z - 1.4, false, false, false, false)
                scriptloop:sleep(100)
            elseif PAD.IS_CONTROL_PRESSED(0, 21) then -- 21 = left SHIFT
                ENTITY.SET_ENTITY_COORDS(object, playerCoords.x, playerCoords.y, playerCoords.z - 0.7, false, false, false, false)
                scriptloop:sleep(50)
            else
                ENTITY.SET_ENTITY_COORDS(object, playerCoords.x, playerCoords.y, playerCoords.z - 1.075, false, false, false, false)
                scriptloop:sleep(50)
            end
        end
    else
        objectSpawned = false
        if object ~= nil then
            OBJECT.DELETE_OBJECT(object)
            object = nil
        end
    end
end)

walkAirCB = selfTab:add_checkbox("Walk on Air")