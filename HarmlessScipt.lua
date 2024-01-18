--[[
  Harmless's Scripts
  Description: Harmless's Scripts is a collection of scripts made by Harmless.
  Version: 1.1.0
]]--

gui.show_message("Harmless's Scripts", "Harmless's Scripts loaded successfully!")

HSTab = gui.get_tab("Harmless's Scripts")
SelfTab = HSTab:add_tab("Self Options")
TeleportTab = SelfTab:add_tab("Teleport Options")
PopularLocationsTab = TeleportTab:add_tab("Popular Locations")
VehicleTab = HSTab:add_tab("Vehicle Options")
MiscTab = HSTab:add_tab("Misc Options")
QuickTab = HSTab:add_tab("Quick Options")
HSSettings = HSTab:add_tab("HS Settings")
HudTab = HSSettings:add_tab("HUD")
ExperimentalTab = HSSettings:add_tab("Experimentals")

--[[

  Harmless's Scripts Tab

]]--
HSTab:add_imgui(function()
  ImGui.Text("Version: 1.1.0")
  ImGui.Text("Github:")
  ImGui.SameLine(); ImGui.TextColored(0.8, 0.9, 1, 1, "Harmless05/harmless-lua")
  if ImGui.IsItemHovered() and ImGui.IsItemClicked(0) then
    ImGui.SetClipboardText("https://github.com/Harmless05/harmless-lua")
    HSNotification("Copied to clipboard!")
  end
  ImGui.Separator()
  enableScriptsTab()
end)

--[[

  Enable "In Menu" Scripts -> Harmless's Scripts

]]--

local enableScriptsCB = false
local state3 = false
function enableScriptsTab()
  local enableScripts, enableScriptsToggled = ImGui.Checkbox("Enable \"In Menu\" features separately (WIP)", enableScriptsCB)
  if enableScriptsToggled then
    enableScriptsCB = enableScripts
    if not enableScripts then
      state3 = false
    end
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("This will allow you to enable/disable every script in the menu separately in their respective locations")
  end
  if enableScriptsCB then
    local newstate3, toggled3 = ImGui.Checkbox("(WIP)", state3)
    if toggled3 then
      state3 = newstate3
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("Enable/Disable Regeneration in \"Self\"")
    end
  end
end


--[[

  Self Options

--]]
SelfTab:add_imgui(function()
  --ImGui.Spacing()
  playerRegenTab()
  ImGui.Spacing()
  ImGui.Separator()
  ImGui.Spacing()
  ragdollPlayerTab()
  ImGui.Spacing()
  ImGui.Separator()
  ImGui.Spacing()
  playerSpeedTab()
end)

--[[

  Player Regeneration -> Self Options

--]]
local healthCB = false
local armourCB = false
local healthregenspeed = 1 -- second(s)
local armourregenspeed = 1 -- second(s)
local healthhealamount = 10
local armourhealamount = 5
function playerRegenTab()
  local newhealthCB, healthToggled = ImGui.Checkbox("Health Regeneration", healthCB)
  if healthToggled then
    healthCB = newhealthCB
HSConsoleLogDebug("Health Regeneration " .. tostring(healthCB))
  end
  healthregenspeed, hSpeedUsed = ImGui.SliderFloat("Health Regen Speed", healthregenspeed, 0, 10, "%.1f", ImGuiSliderFlags.Logarithmic)
  healthhealamount, hAmountUsed = ImGui.SliderInt("Health Regen Amount", healthhealamount, 1, 50)
  local newarmourCB, armourToggled = ImGui.Checkbox("Armor Regeneration", armourCB)
  if armourToggled then
    armourCB = newarmourCB
HSConsoleLogDebug("Armor Regeneration " .. tostring(armourCB))
  end
  armourregenspeed, aSpeedUsed = ImGui.SliderFloat("Armor Regen Speed", armourregenspeed, 0, 10, "%.1f", ImGuiSliderFlags.Logarithmic)
  armourhealamount, aAmountUsed = ImGui.SliderInt("Armor Regen Amount", armourhealamount, 1, 50)
end

script.register_looped("HS Health Regeneration Loop", function(healthLoop)
  if healthCB and ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID()) < ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID()) then
HSConsoleLogDebug("Adding " .. healthhealamount .. " amount health")
      local health = ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID())
      if ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID()) == health then return end
      ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), health + healthhealamount, 0, 0)
      healthLoop:sleep(math.floor(healthregenspeed * 1000)) -- 1ms * 1000 to get seconds
  end
end)

script.register_looped("HS Armour Regeneration Loop", function(armorLoop)
  if armourCB and PED.GET_PED_ARMOUR(PLAYER.PLAYER_PED_ID()) < PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_PED_ID()) then
HSConsoleLogDebug("Adding " .. armourhealamount .. " amount armor")
    PED.ADD_ARMOUR_TO_PED(PLAYER.PLAYER_PED_ID(), armourhealamount)
    armorLoop:sleep(math.floor(armourregenspeed * 1000)) -- 1ms * 1000 to get seconds
  end
end)

--[[

  Ragdoll Player -> Self Options

]]--
local ragdollCB = false
local ragdollLoopCB = false
local ragdollLoopSpeed = 1
local ragdollForceFlags = 1
local ragdollForceX = 10
local ragdollForceY = 10
local ragdollForceZ = 10
local ragdollType = 0
function ragdollPlayerTab()
  if ImGui.Button("Ragdoll Player [Once]") then
    ragdollPlayerOnce()
HSConsoleLogDebug("Ragdolling Player Once")
  end
  ImGui.SameLine(); local newRagdollLoopCB, ragdollLoopToggled = ImGui.Checkbox("Ragdoll Player [Loop]", ragdollLoopCB)
  if ragdollLoopToggled then
    ragdollLoopCB = newRagdollLoopCB
HSConsoleLogDebug("Ragdoll Loop " .. tostring(ragdollLoopCB))
  end
  ImGui.Separator()
  ImGui.LabelText("Parameters", "Ragdoll Settings")
  ragdollLoopSpeed, ragdollLoopSpeedUsed = ImGui.SliderFloat("Loop Speed", ragdollLoopSpeed, 0, 10, "%.1f", ImGuiSliderFlags.Logarithmic)
  if ImGui.IsItemHovered() then
    HSshowTooltip("Loop in seconds")
  end
  
  ragdollForceFlags, ragdollForceFlagsUsed = ImGui.SliderInt("Ragdoll Force Flags", ragdollForceFlags, 0, 5)
  if ImGui.IsItemHovered() then
    HSshowTooltip("0 = Weak Force\n1 = Strong Force\n2 = Same as 0\n3 = Same as 1\n4 = Weak Momentum\n5 = Strong Momentum")
  end
  ragdollForceX, ragdollForceXUsed = ImGui.SliderInt("Force X", ragdollForceX, 0, 100)
  ragdollForceY, ragdollForceYUsed = ImGui.SliderInt("Force Y", ragdollForceY, 0, 100)
  ragdollForceZ, ragdollForceZUsed = ImGui.SliderInt("Force Z", ragdollForceZ, 0, 100)
  ragdollType, ragdollTypeUsed = ImGui.SliderInt("Ragdoll Type", ragdollType, 0, 3)
  if ImGui.IsItemHovered() then
    HSshowTooltip("0 = Normal Ragdoll\n1 = Falls with stiff legs/body\n2 = Narrow leg stumble\n3 = Wide leg stumble")
  end
end

function ragdollPlayerOnce()
  local forceFlags = ragdollForceFlags
  local ragdollType = ragdollType
  local forcex = ragdollForceX
  local forcey = ragdollForceY
  local forcez = ragdollForceZ
  local players = PLAYER.PLAYER_PED_ID()
  PED.SET_PED_TO_RAGDOLL(players, -1, 0, ragdollType, true, true, false)
  ENTITY.APPLY_FORCE_TO_ENTITY(players, forceFlags, forcex, forcey, forcez, 0, 0, 0, 0, false, true, true, false, true)
end

script.register_looped("HS Ragdoll Player Loop", function(ragdollLoop)
  if ragdollLoopCB then
    local loopspd = ragdollLoopSpeed * 1000
    local forceFlags = ragdollForceFlags
    local ragdollType = ragdollType
    local forcex = ragdollForceX
    local forcey = ragdollForceY
    local forcez = ragdollForceZ
    local players = PLAYER.PLAYER_PED_ID()
    PED.SET_PED_TO_RAGDOLL(players, -1, 0, ragdollType, true, true, false)
    ENTITY.APPLY_FORCE_TO_ENTITY(players, forceFlags, forcex, forcey, forcez, 0, 0, 0, 0, false, true, true, false, true)
    ragdollLoop:sleep(math.floor(loopspd))
  end
end)

--[[

  Player Speed Multipliers -> Self Options

]]--
local walkCB = false
local walkSpeed = 1.2
local swimCB = false
local swimSpeed = 1.2

function playerSpeedTab()
  local newwalkCB, walkToggled = ImGui.Checkbox("Walk Speed Multiplier", walkCB)
  if walkToggled then
    walkCB = newwalkCB
  end
  walkSpeed, walkUsed = ImGui.SliderFloat("Walk speed multiplier", walkSpeed, 1, 1.49)
  local newswimCB, swimToggled = ImGui.Checkbox("Swim Speed Multiplier", swimCB)
  if swimToggled then
    swimCB = newswimCB
  end
  swimSpeed, swimUsed = ImGui.SliderFloat("Swim speed multiplier", swimSpeed, 1, 1.49)
end

script.register_looped("HS Player Speed Multiplier Loop", function(speedLoop) -- These don't need to be looped, but it's easier to do it this way.
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

--[[

  Teleport Options

]]--

--[[

  Quick Teleport -> Teleport Options

]]--

TeleportTab:add_imgui(function()
  quickTeleportTab()
end)

local teleportLocations = {}
local drawMarker = false

function quickTeleportTab()
  local player = PLAYER.PLAYER_PED_ID()
  local currentCoords = ENTITY.GET_ENTITY_COORDS(player, true)
  
  ImGui.BulletText("Quick Teleport")

  if ImGui.Button("Save Current Location") then
    local heading = ENTITY.GET_ENTITY_HEADING(player)
    teleportLocations[1] = {currentCoords.x, currentCoords.y, currentCoords.z, heading}
    HSNotification("Saved current location!")
    HSConsoleLogDebug("Saved current location")
    HSConsoleLogDebug("Saved location: x = " .. currentCoords.x .. ", y = " .. currentCoords.y .. ", z = " .. currentCoords.z .. ", heading = " .. heading)
  end

  if teleportLocations[1] ~= nil then
    local savedLocation = teleportLocations[1]
    ImGui.Text(string.format("Current location: X=%.2f, Y=%.2f, Z=%.2f", savedLocation[1], savedLocation[2], savedLocation[3]))
    
    local dx = savedLocation[1] - currentCoords.x
    local dy = savedLocation[2] - currentCoords.y
    local dz = savedLocation[3] - currentCoords.z
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    ImGui.Text(string.format("Distance to saved location: %.0f meters", distance))
    
    if ImGui.Button("Teleport to Saved Location") then
      PED.SET_PED_COORDS_KEEP_VEHICLE(player, savedLocation[1], savedLocation[2], savedLocation[3])
      ENTITY.SET_ENTITY_HEADING(player, savedLocation[4])
      HSNotification("Teleported to saved location!")
      HSConsoleLogDebug("Teleported to saved location")
    end

    ImGui.Separator()

    local newdrawMarker, drawMarkerToggled = ImGui.Checkbox("Draw Marker", drawMarker)
    if drawMarkerToggled then
      drawMarker = newdrawMarker
    end
  end
end

script.register_looped("HS Draw Marker Loop", function(drawMarkerLoop)
  if drawMarker then
    local player = PLAYER.PLAYER_PED_ID()
    local savedLocation = teleportLocations[1]
    if savedLocation ~= nil then
      GRAPHICS.DRAW_MARKER_EX(1, savedLocation[1], savedLocation[2], savedLocation[3], 0, 0, 0, 0, 0, 0, 2.0, 2.0, savedLocation[3] + 1500.0, 255, 255, 255, 100, false, false, 2, false, "", "", false, true, true)
    end
  end
end)

--[[

  Popular Locations -> Teleport Options -> Self Options

]]--

PopularLocationsTab:add_imgui(function()
  PopularLocTab()
  ImGui.Separator()
  ImGui.Spacing()
  --PopularLocCamView()
end)

local TeleportToLocCB = true
local popularLocations = {
  {name = "Select a location", x = 0.0, y = 0.0, z = 0.0, heading = 0.0},
  {name = "Los Santos Customs", x = -376, y = -123, z = 39, heading = 233.0},
  {name = "LS Airport Customs", x = -1134.2, y = -1984.4, z = 13.2, heading = 235.5},
  {name = "La Mesa Customs", x = 709.8, y = -1082.7, z = 22.4, heading = 235.5},
  {name = "Senora Desert Customs", x = 1178.7, y = 2666.2, z = 37.881, heading = 235.5},
  {name = "Beeker's Customs", x = 126.2, y = 6608.2, z = 31.9, heading = 235.5},
  {name = "Benny's vehicles", x = -210.7, y =  -1301.4, z = 31.3, heading = 235.5},
  {name = "Airport center", x = -1336.0, y = -3044.0, z = 14, heading = 0.0},
  {name = "Airport Hanger", x = -1000.0, y = -3025.0, z = 13.0, heading = 0.0},
  {name = "Airport Gate", x = -994.4, y = -2851.7, z = 14.0, heading = 148.2},
  {name = "Airport Back", x = -1704.8, y = -2831.4, z = 14.0, heading = 239.0},
  {name = "Maze Bank Top", x = -75.0, y = -818.0, z = 326.0, heading = 0.0},
  {name = "Maze Bank Bottom", x = -53.0, y = -791.5, z = 44.0, heading = 315.8},
  {name = "Eclipse Towers", x = -807.3, y = 301.9, z = 86.1, heading = 235.5},
  {name = "Casino Enterance", x = 918.6, y = 50.3, z = 80.8, heading = 235.5},
  {name = "Casino Parking Lot", x = 899.6, y = -20.4, z = 78.8, heading = 87.0},
  {name = "Ammunation", x = 247.4, y = -45.9, z = 70.0, heading = 235.5},
  {name = "Impound Lot", x = 401.0, y = -1631.8, z = 29.3, heading = 235.5},
  {name = "Mors Mutual Insurance", x = -224.0, y = -1180.8, z = 23.0, heading = 2.6},
  {name = "Mask Shop", x = -1338.2, y = -1278.1, z = 4.9, heading = 235.5},
  {name = "Tattoo Shop", x = -1155.7, y = -1422.5, z = 4.8, heading = 235.5},
  {name = "Clothes Store", x = -719.0, y = -158.2, z = 37.0, heading = 235.5},
  {name = "Airport Tower", x = -985.0, y = -2642.0, z = 63.5, heading = 235.5},
}

function PopularLocTab()
  local player = PLAYER.PLAYER_PED_ID()

  -- Create a list of location names
  local locationNames = {}
  for i, location in ipairs(popularLocations) do
    table.insert(locationNames, location.name)
  end

  newTeleportToLocCB, teleportToLocToggled = ImGui.Checkbox("Teleport to Location", TeleportToLocCB)
  if teleportToLocToggled then
    TeleportToLocCB = newTeleportToLocCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("Teleport to the location you selected")
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("View the location you selected as CAM\nPress \"F\" to exit")
  end
  if ViewLocAsCamCB then
    HSNotification("Press \"F\" to exit CAM")
  end
  
  local popularLocationsIndex = 0
  local current_item = popularLocationsIndex
  local clicked = false
  current_item, clicked = ImGui.Combo("", current_item, locationNames, #locationNames)

  if clicked then
    popularLocationsIndex = current_item
    local selectedLocation = popularLocations[current_item + 1]
    if TeleportToLocCB and not ViewLocAsCamCB then
      PED.SET_PED_COORDS_KEEP_VEHICLE(player, selectedLocation.x, selectedLocation.y, selectedLocation.z)
      ENTITY.SET_ENTITY_HEADING(player, selectedLocation.heading)
      HSConsoleLogDebug("Teleported to " .. selectedLocation.name)
    end
  end
end

--[[

  Vehicle Options

]]--
VehicleTab:add_imgui(function()
  setVehicleMaxSpeedTab()
  ImGui.Separator()
  ImGui.Spacing()
  setVehicleForwardSpeedTab()
  ImGui.Separator()
  ImGui.Spacing()
  shiftDriftTab()
  ImGui.Separator()
  ImGui.Spacing()
  autoFlipVehicleTab()
end)

--[[

  Set Vehicle Max Speed -> Vehicle Options

]]--
local maxSpeedCB = false
local speedLimit = 1000
function setVehicleMaxSpeedTab()
  local newmaxSpeedCB, maxSpeedToggled = ImGui.Checkbox("Set Vehicle Max Speed", maxSpeedCB)
  if maxSpeedToggled then
    maxSpeedCB = newmaxSpeedCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("This will set your vehicle's max speed to the speed you set")
  end
  speedLimit, speedLimitUsed = ImGui.SliderInt("Speed Limit", speedLimit, 1, 1000)
end

script.register_looped("HS Set Vehicle Max Speed Loop", function(speedLoop)
  if maxSpeedCB then
    local speed = speedLimit
    local CurrentVeh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
    VEHICLE.SET_VEHICLE_MAX_SPEED(CurrentVeh, speed)
  else
    local CurrentVeh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
    VEHICLE.SET_VEHICLE_MAX_SPEED(CurrentVeh, 0.0)
  end
end)

--[[

  Set Vehicle Forward Speed -> Vehicle Options

]]--
local forwardSpeedCB = false
local speedBoost = 100
function setVehicleForwardSpeedTab()
  local newforwardSpeedCB, forwardSpeedToggled = ImGui.Checkbox("Set Vehicle Forward Speed", forwardSpeedCB)
  if forwardSpeedToggled then
    forwardSpeedCB = newforwardSpeedCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("When enabled, press \"W\" to go forward at the speed you set")
  end
  speedBoost, speedBoostUsed = ImGui.SliderInt("Boosted Speed", speedBoost, 1, 1000)
end

script.register_looped("HS Set Vehicle Forward Speed Loop", function(speedLoop)
  if forwardSpeedCB and PAD.IS_CONTROL_PRESSED(0, 71) then
    local speed = speedBoost
    local CurrentVeh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
    VEHICLE.SET_VEHICLE_FORWARD_SPEED(CurrentVeh, speed)
  end
end)

--[[

  Shift Drift -> Vehicle Options

]]--
local shiftDriftCB = false
local driftAmount = 0
local driftTyresCB = false
function shiftDriftTab()
  local newshiftDriftCB, shiftDriftToggled = ImGui.Checkbox("Shift Drift", shiftDriftCB)
  if shiftDriftToggled then
    shiftDriftCB = newshiftDriftCB
    if not shiftDriftCB then
      driftTyresCB = false
    end
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("Press \"Shift\" to drift")
  end
  if shiftDriftCB then
    local newdriftTyresCB, driftTyresToggled = ImGui.Checkbox("Use Low Grip Tyres", driftTyresCB)
    if driftTyresToggled then
      driftTyresCB = newdriftTyresCB
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("This will use GTAV's Low Grip Tyres for drifting instead")
    end
  end
  if not driftTyresCB then
    driftAmount, driftAmountUsed = ImGui.SliderInt("Drift Amount", driftAmount, 0, 3)
    if ImGui.IsItemHovered() then
      HSshowTooltip("0 = Loosest Drift\n1 = Loose Drift\n2 = Stiff Drift\n3 = Stiffest Drift")
    end
  end
end

script.register_looped("HS Shift Drift Loop", function(driftLoop)
  local CurrentVeh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
  if driftTyresCB and PAD.IS_CONTROL_PRESSED(0, 21) then
    VEHICLE.SET_DRIFT_TYRES(CurrentVeh, true)
  else 
    VEHICLE.SET_DRIFT_TYRES(CurrentVeh, false)
  end
  if shiftDriftCB and PAD.IS_CONTROL_PRESSED(0, 21) and not driftTyresCB then
    VEHICLE.SET_VEHICLE_REDUCE_GRIP(CurrentVeh, true)
    VEHICLE.SET_VEHICLE_REDUCE_GRIP_LEVEL(CurrentVeh, driftAmount)
  else
    VEHICLE.SET_VEHICLE_REDUCE_GRIP(CurrentVeh, false)
  end
end)

--[[

  Auto Flip Vehicle -> Vehicle Options

]]--
local autoFlipVehicleCB = false
function autoFlipVehicleTab()
  local newautoFlipVehicleCB, autoFlipVehicleToggled = ImGui.Checkbox("Auto Flip Vehicle", autoFlipVehicleCB)
  if autoFlipVehicleToggled then
    autoFlipVehicleCB = newautoFlipVehicleCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("This will automatically flip your vehicle upright if it is upside down")
  end
end

script.register_looped("HS Auto Flip Vehicle Loop", function(flipLoop)
  if autoFlipVehicleCB then
    local players = PLAYER.PLAYER_PED_ID()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players, false)
    if vehicle ~= 0 then
      if ENTITY.IS_ENTITY_UPSIDEDOWN(vehicle) then
        local getrot = ENTITY.GET_ENTITY_ROTATION(vehicle, 1)
        local forwardVector = ENTITY.GET_ENTITY_FORWARD_VECTOR(vehicle)
        ENTITY.SET_ENTITY_ROTATION(vehicle, forwardVector.x, forwardVector.y, getrot.z, 1, true)
      end
    end
    flipLoop:sleep(1000)
  end
end)

--[[

  Misc Options

]]--
MiscTab:add_imgui(function()
  walkOnAirTab()
  ImGui.Separator()
  ImGui.Spacing()
  playerVisionTab()
end)

--[[

  Walk on Air -> Misc Options

]]--
local walkOnAirCB = false
function walkOnAirTab()
  local newwalkOnAirCB, walkOnAirToggled = ImGui.Checkbox("Walk on Air", walkOnAirCB)
  if walkOnAirToggled then
    walkOnAirCB = newwalkOnAirCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("Air Jesus")
  end
end

local object = nil
local objectSpawned = false

function spawnObject() -- Spawns the "air"
  gui.show_message("Controls", "Left SHIFT = go up\nLeft CTRL = go down")
  HSConsoleLogDebug("Spawning object")
    local player = PLAYER.PLAYER_PED_ID()
  local coords = ENTITY.GET_ENTITY_COORDS(player, true)
  STREAMING.REQUEST_MODEL(-698352776)
  object = OBJECT.CREATE_OBJECT(-698352776, coords.x, coords.y, coords.z - 1.2, true, false, false)
  ENTITY.SET_ENTITY_ROTATION(object, 270, 0, 0, 1, true)
  ENTITY.SET_ENTITY_VISIBLE(object, false, false)
  ENTITY.SET_ENTITY_ALPHA(object, 0, false)
  ENTITY.SET_ENTITY_COLLISION(object, true, false)
  ENTITY.SET_ENTITY_DYNAMIC(object, false)
  ENTITY.FREEZE_ENTITY_POSITION(object, true)
end

function deleteObject()
  if object ~= nil then
      HSConsoleLogDebug("Deleting object")
            OBJECT.DELETE_OBJECT(object)
      object = nil
  end
end

script.register_looped("HS Walk on Air Loop", function(walkOnAirLoop)
  if walkOnAirCB then
    if not objectSpawned then
        spawnObject()
        objectSpawned = true
    end
    if object ~= nil then
        local player = PLAYER.PLAYER_PED_ID()
        local playerCoords = ENTITY.GET_ENTITY_COORDS(player, true)
        local objectCoords = ENTITY.GET_ENTITY_COORDS(object, true)
        if PAD.IS_CONTROL_PRESSED(0, 36) then -- 36 = left CTRl
            ENTITY.SET_ENTITY_COORDS(object, playerCoords.x, playerCoords.y, playerCoords.z - 1.4, false, false, false, false)
            walkOnAirLoop:sleep(100)
        elseif PAD.IS_CONTROL_PRESSED(0, 21) then -- 21 = left SHIFT
            ENTITY.SET_ENTITY_COORDS(object, playerCoords.x, playerCoords.y, playerCoords.z - 0.7, false, false, false, false)
            walkOnAirLoop:sleep(50)
        else
            ENTITY.SET_ENTITY_COORDS(object, playerCoords.x, playerCoords.y, playerCoords.z - 1.075, false, false, false, false)
            walkOnAirLoop:sleep(50)
        end
    end
  else
    objectSpawned = false
    deleteObject()
  end
end)

--[[

  Player Vision -> Misc Options

]]--

local thermalVisionCB = false
local defaultThermalVisCV = false
local tVisStartFade = 1000
local tVisEndFade = 1000
local tVisWallThickness = 200
local tVisNoiseMin = 0.0
local tVisNoiseMax = 0.0
local tVisHilightIntensity = 0.5
local tVisHilightNoise = 0.0
local nightVisionCB = false
local defaultNightVisCV = false
local nVisLightRange = 100
local weaponScopeCB = false

function playerVisionTab()
  local newthermalVisionCB, thermalVisionToggled = ImGui.Checkbox("Thermal Vision", thermalVisionCB)
  if thermalVisionToggled then
    thermalVisionCB = newthermalVisionCB
    nightVisionCB = false
  end
  local newdefaultThermalVisCV, defaultThermalVisCVUsed = ImGui.Checkbox("Default Thermal Vision", defaultThermalVisCV)
  if defaultThermalVisCVUsed then
    defaultThermalVisCV = newdefaultThermalVisCV
  end
  if not defaultThermalVisCV then -- Thermal Vision Settings
    ImGui.LabelText("Parameters", "Thermal Vision Settings")
    ImGui.Spacing()
    local newtVisStartFade, tVisStartFadeUsed = ImGui.SliderFloat("Start Fade", tVisStartFade, 0, 4000)
    if tVisStartFadeUsed then
      tVisStartFade = newtVisStartFade
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("Bigger the value, the more you can see through walls (Where the fading of the thermal vision starts)")
    end
    local newtVisEndFade, tVisEndFadeUsed = ImGui.SliderFloat("End Fade", tVisEndFade, 0, 4000)
    if tVisEndFadeUsed then
      tVisEndFade = newtVisEndFade
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("Bigger the value, the more you can see through walls (END value needs to be higher than START value)")
    end
    local newtVisWallThickness, tVisWallThicknessUsed = ImGui.SliderFloat("Wall Thickness", tVisWallThickness, 1, 200)
    if tVisWallThicknessUsed then
      tVisWallThickness = newtVisWallThickness
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("0 = You will not be able to see people behind walls\n 50+ = You can see everyone through the walls")
    end
    local newtVisNoiseMin, tVisNoiseMinUsed = ImGui.SliderFloat("Noise Min", tVisNoiseMin, 0, 100)
    if tVisNoiseMinUsed then
      tVisNoiseMin = newtVisNoiseMin
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("Adds noise (Annoying)")
    end
    local newtVisNoiseMax, tVisNoiseMaxUsed = ImGui.SliderFloat("Noise Max", tVisNoiseMax, 0, 100)
    if tVisNoiseMaxUsed then
      tVisNoiseMax = newtVisNoiseMax
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("Adds noise (Annoying)")
    end
    local newtVisHilightIntensity, tVisHilightIntensityUsed = ImGui.SliderFloat("Highlight Intensity", tVisHilightIntensity, 0, 10)
    if tVisHilightIntensityUsed then
      tVisHilightIntensity = newtVisHilightIntensity
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("Shadow highlight basically (Makes dark areas more visible)")
    end
    local newtVisHilightNoise, tVisHilightNoiseUsed = ImGui.SliderFloat("Highlight Noise", tVisHilightNoise, 0, 100)
    if tVisHilightNoiseUsed then
      tVisHilightNoise = newtVisHilightNoise
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("Adds noise to highlights (Annoying)")
    end
  end -- End of Thermal Vision Settings
  ImGui.Separator()
  ImGui.Spacing()
  local newnightVisionCB, nightVisionToggled = ImGui.Checkbox("Night Vision", nightVisionCB)
  if nightVisionToggled then
    nightVisionCB = newnightVisionCB
    thermalVisionCB = false
  end
  ImGui.LabelText("Parameters", "Night Vision Settings") -- Night Vision Settings
  ImGui.Spacing()
  local newnVisLightRange, nVisLightRangeUsed = ImGui.SliderFloat("Light Range", nVisLightRange, 0, 2000)
  if nVisLightRangeUsed then
    nVisLightRange = newnVisLightRange
  end -- End of Night Vision Settings
  ImGui.Separator()
  local newweaponScopeCB, weaponScopeToggled = ImGui.Checkbox("Enable On Weapon Scope", weaponScopeCB)
  if weaponScopeToggled then
    weaponScopeCB = newweaponScopeCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("Enables Thermal/Night Vision when aiming down sights")
  end
end

script.register_looped("HS Thermal Vision Loop", function(thermalLoop)
  local function setThermalVision()
    GRAPHICS.SEETHROUGH_SET_FADE_STARTDISTANCE(tVisStartFade)
    GRAPHICS.SEETHROUGH_SET_FADE_ENDDISTANCE(tVisEndFade)
    GRAPHICS.SEETHROUGH_SET_MAX_THICKNESS(tVisWallThickness)
    GRAPHICS.SEETHROUGH_SET_NOISE_MIN(tVisNoiseMin)
    GRAPHICS.SEETHROUGH_SET_NOISE_MAX(tVisNoiseMax)
    GRAPHICS.SEETHROUGH_SET_HILIGHT_INTENSITY(tVisHilightIntensity)
    GRAPHICS.SEETHROUGH_SET_HIGHLIGHT_NOISE(tVisHilightNoise)
    GRAPHICS.SET_SEETHROUGH(true)
  end

  local function resetThermalVision()
    GRAPHICS.SEETHROUGH_RESET(true)
    GRAPHICS.SET_SEETHROUGH(true)
  end

  if thermalVisionCB then
      if weaponScopeCB and PED.GET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), 78, true) and PAD.IS_CONTROL_PRESSED(0, 25) and not defaultThermalVisCV then -- Weapon Scope Thermal Vision
          setThermalVision()
      elseif not weaponScopeCB and not defaultThermalVisCV then -- Always On Thermal Vision
          setThermalVision()
      elseif defaultThermalVisCV and not weaponScopeCB then -- Default Thermal Vision
          resetThermalVision()
      elseif weaponScopeCB and defaultThermalVisCV and PED.GET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), 78, true) and PAD.IS_CONTROL_PRESSED(0, 25) then -- Default Thermal Vision (Weapon Scope)
    resetThermalVision()
      else
          GRAPHICS.SET_SEETHROUGH(false)
      end
  else
    GRAPHICS.SET_SEETHROUGH(false)
  end
end)

script.register_looped("HS Night Vision Loop", function(nightLoop)
  if nightVisionCB and weaponScopeCB and PED.GET_PED_CONFIG_FLAG(PLAYER.PLAYER_PED_ID(), 78, true) and PAD.IS_CONTROL_PRESSED(0, 25) then -- Weapon Scope Night Vision
    GRAPHICS.OVERRIDE_NIGHTVISION_LIGHT_RANGE(nVisLightRange)
    GRAPHICS.SET_NIGHTVISION(true)
  elseif nightVisionCB and not weaponScopeCB then -- Always On Night Vision
    GRAPHICS.OVERRIDE_NIGHTVISION_LIGHT_RANGE(nVisLightRange)
    GRAPHICS.SET_NIGHTVISION(true)
  else
    GRAPHICS.SET_NIGHTVISION(false)
  end
end)
--[[

  NPC ESP -> Misc Options

  Credits to @pierrelasse in GitHub for helping me with this :D

]]--

local npcEspCB = false
local npcEspDistance = 50

function npcEspTab()
  local newnpcEspCB, npcEspToggled = ImGui.Checkbox("NPC ESP", npcEspCB)
  if npcEspToggled then
    npcEspCB = newnpcEspCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("This will draw a box around NPCs")
  end
  npcEspDistance, npcEspDistanceUsed = ImGui.SliderFloat("ESP Max Distance", npcEspDistance, 0, 150)
end

function calculate_distance(x1, y1, z1, x2, y2, z2)
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

function draw_rect(x, y, width, height)
  GRAPHICS.DRAW_RECT(x, y, width, height, 255, 0, 0, 255, false)
end

script.register_looped("HS NPC ESP Loop", function(npcEspLoop)
  if npcEspCB then
    local player = PLAYER.PLAYER_PED_ID()
    local playerCoords = ENTITY.GET_ENTITY_COORDS(player, true)

    local allPeds = entities.get_all_peds_as_handles()
    for i, ped in ipairs(allPeds) do
      if ENTITY.DOES_ENTITY_EXIST(ped) and not PED.IS_PED_A_PLAYER(ped) and PED.IS_PED_HUMAN(ped) and not PED.IS_PED_DEAD_OR_DYING(ped, true) then
        local pedCoords = ENTITY.GET_ENTITY_COORDS(ped, true)
        HSConsoleLogDebug("Found ped " .. ped .. " at coordinates " .. tostring(pedCoords))
        local distance = SYSTEM.VDIST(playerCoords.x, playerCoords.y, playerCoords.z, pedCoords.x, pedCoords.y, pedCoords.z)
        if distance <= npcEspDistance then
          local success, screenX, screenY = GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(pedCoords.x, pedCoords.y, pedCoords.z, 0.0, 0.0)
          HSConsoleLogDebug("Screen coords: " .. tostring(screenX) .. ", " .. tostring(screenY))
          if success then
            -- Calculate the distance from the ped to the camera
            local camCoords = CAM.GET_GAMEPLAY_CAM_COORD()
            HSConsoleLogDebug("Camera coords: " .. tostring(camCoords))
            local distanceToCam = calculate_distance(pedCoords.x, pedCoords.y, pedCoords.z, camCoords.x, camCoords.y, camCoords.z)
            HSConsoleLogDebug("Distance to ped " .. ped .. " is " .. distanceToCam)

            -- Size of the box based on the distance to the camera
            local boxSize = 2 * (1 / distanceToCam)

            -- Minimum box thickness
            local minThickness = 0.001

            -- Thickness of the outline based on the distance to the camera, with a lower limit
            local thickness = math.max(minThickness, 0.0015 * (1 / distanceToCam))
            HSConsoleLogDebug("Box thickness: " .. thickness)

            -- Call the functions to draw the box
            draw_rect(screenX, screenY - boxSize / 2, boxSize / 4, thickness) -- Top
            draw_rect(screenX, screenY + boxSize / 2, boxSize / 4, thickness) -- Bottom
            draw_rect(screenX - boxSize / 8, screenY, thickness, boxSize - 2 * thickness) -- Left
            draw_rect(screenX + boxSize / 8, screenY, thickness, boxSize - 2 * thickness) -- Right
          end
        end
      end
    end
  end
end)
  
--[[

  Quick Options

]]--
QuickTab:add_imgui(function()
  ImGui.Text("YimMenu Hotkeys exsist for all of these, but what if you don't want to use hotkeys?")
  ImGui.Spacing()
  ImGui.Separator()
  ImGui.Spacing()
  SelfPed = PLAYER.PLAYER_PED_ID()
  -- Self Options
  ImGui.BulletText("Self Options")
  if ImGui.Button("Clear Wanted Level") then
    command.call("clearwantedlvl",{})
    command.call("clearwantedlvl",{})
  end
  if ImGui.Button("Heal Player") then
    command.call("heal",{})
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("This will give max health and armor to the player")
  end
  if ImGui.Button("Give All Weapons") then
    command.call("giveweaps",{SelfPed})
  end
  if ImGui.Button("Give All Ammo") then
    command.call("giveammo",{SelfPed})
  end
  if ImGui.Button("Fill Ammo") then
    command.call("fillammo",{})
  end
  if ImGui.Button("Give Max Armor") then
    command.call("givearmor",{SelfPed})
  end
    if ImGui.Button("Clean Player") then
    command.call("clean",{})
  end
  if ImGui.Button("Fill Snacks") then
    command.call("fillsnacks",{})
  end
  ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.7, 0.4, 1)
  if ImGui.Button("Suicide :)") then
    command.call("suicide",{})
  end
  ImGui.PopStyleColor()
  ImGui.Separator()
  -- Teleport Options
  ImGui.BulletText("Teleport Options")
  if ImGui.Button("TP to Waypoint") then
    command.call("waypointtp",{})
  end
  if ImGui.Button("TP to Objective") then
    command.call("objectivetp",{})
  end
  ImGui.Separator()
  -- Vehicle Options
  ImGui.BulletText("Vehicle Options")
  if ImGui.Button("Repair PV") then
    command.call("repairpv", {})
  end
  if ImGui.Button("Upgrade Vehicle") then
    command.call("upgradeveh",{SelfPed})
  end
  if ImGui.Button("Downgrade Vehicle") then
    command.call("downgradeveh",{SelfPed})
  end
  if ImGui.Button("Bring PV") then
    command.call("bringpv",{})
  end
  if ImGui.Button("TP into Personal Vehicle") then
    command.call("pvtp",{})
  end
  ImGui.Separator()
  -- Misc Options
  ImGui.BulletText("Misc")
if ImGui.Button("Leave Online") then
    NETWORK.NETWORK_SESSION_LEAVE_SINGLE_PLAYER()
  end
  ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.8, 0.45, 1)
  if ImGui.Button("Damage Player") then
    ENTITY.SET_ENTITY_HEALTH(SelfPed, 100, 0, 0)
  end
  ImGui.PopStyleColor()
  ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
  if ImGui.Button("Rage Quit") then
      command.call("fastquit",{})
  end
  ImGui.PopStyleColor()
end)

--[[

  HS Settings

]]
local notifyCB = true
local toolTipCB = true
local HSConsoleLogInfoCB = true
local HSConsoleLogWarnCB = true
local HSConsoleLogDebugCB = false
HSSettings:add_imgui(function()
  local newNotifyCB, notifyToggled = ImGui.Checkbox("HS Notifications", notifyCB)
  if notifyToggled then
    notifyCB = newNotifyCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("This will enable/disable notifications for Harmless's Scripts")
  end
  local newToolTipCB, toolTipToggled = ImGui.Checkbox("HS Tooltips", toolTipCB)
  if toolTipToggled then
    toolTipCB = newToolTipCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("This will enable/disable tooltips for Harmless's Scripts")
  end
  local newHSConsoleLogInfoCB, HSConsoleLogInfoToggled = ImGui.Checkbox("HS Console Logs (Info)", HSConsoleLogInfoCB)
  if HSConsoleLogInfoToggled then
    HSConsoleLogInfoCB = newHSConsoleLogInfoCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("Enable/disable YimMenu info console logs for Harmless's Scripts")
  end
  local newHSConsoleLogWarnCB, HSConsoleLogWarnToggled = ImGui.Checkbox("HS Console Logs (Warning)", HSConsoleLogWarnCB)
  if HSConsoleLogWarnToggled then
    HSConsoleLogWarnCB = newHSConsoleLogWarnCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("Enable/disable YimMenu warning console logs for Harmless's Scripts")
  end
  local newHSConsoleLogDebugCB, HSConsoleLogDebugToggled = ImGui.Checkbox("HS Console Logs (Debug)", HSConsoleLogDebugCB)
  if HSConsoleLogDebugToggled then
    HSConsoleLogDebugCB = newHSConsoleLogDebugCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("Enable/disable YimMenu debug console logs for Harmless's Scripts")
  end
end)

--[[

  HUD Tab

]]--

HudTab:add_imgui(function()
  ImGui.Text("HUD Options")
  ImGui.Separator()
  ImGui.Spacing()
  showTimeTab()
end)


--[[

  Show IRL Time -> HUD Tab

]]--

local currentTimeCB = false
local showSecondsCB = false
local disableTextCB = false
local timeTxtLocX = 0.94
local timeTxtLocY = 0.01
local timeTxtScale = 0.4
local timeTxtColor = {1.0, 1.0, 1.0, 1.0}
local timeTxtDropShadowCB = true

function showTimeTab()
  local newcurrentTimeCB, currentTimeToggled = ImGui.Checkbox("Show Current Time", currentTimeCB)
  if currentTimeToggled then
    currentTimeCB = newcurrentTimeCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("This will draw the current time on your screen")
  end
  if currentTimeCB then
    local newshowSecondsCB, showSecondsToggled = ImGui.Checkbox("Show Seconds", showSecondsCB)
    if showSecondsToggled then
      showSecondsCB = newshowSecondsCB
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("This will show seconds in the time")
    end
    local newdisableTextCB, disableTextToggled = ImGui.Checkbox("Disable Text", disableTextCB)
    if disableTextToggled then
      disableTextCB = newdisableTextCB
    end
    if ImGui.IsItemHovered() then
      HSshowTooltip("This will disable the \"Current time:\" text")
    end
    timeTxtLocX, timeTxtLocXUsed = ImGui.SliderFloat("Text Location X", timeTxtLocX, 0.01, 1, "%.2f", ImGuiSliderFlags.Logarithmic)
    if ImGui.IsItemHovered() then
      HSshowTooltip("This will change the X location of the text")
    end
    timeTxtLocY, timeTxtLocYUsed = ImGui.SliderFloat("Text Location Y", timeTxtLocY, 0.01, 1, "%.2f", ImGuiSliderFlags.Logarithmic)
    if ImGui.IsItemHovered() then
      HSshowTooltip("This will change the Y location of the text")
    end
    timeTxtScale, timeTxtScaleUsed = ImGui.SliderFloat("Text Scale", timeTxtScale, 0.1, 1, "%.1f", ImGuiSliderFlags.Logarithmic)
    if ImGui.IsItemHovered() then
      HSshowTooltip("This will change the scale of the text")
    end
    timeTxtColor, timeTxtColorUsed = ImGui.ColorEdit4("Text Color", timeTxtColor)
    local newtimeTxtDropShadowCB, timeTxtDropShadowToggled = ImGui.Checkbox("Text Drop Shadow", timeTxtDropShadowCB)
    if timeTxtDropShadowToggled then
      timeTxtDropShadowCB = newtimeTxtDropShadowCB
    end
  end
end

script.register_looped("HS Show Time Loop", function(showTimeLoop)
  if currentTimeCB then
    local timestamp = os.time()
    local date = os.date("*t", timestamp)

    local function formatTimeUnit(timeUnit)
      return timeUnit < 10 and "0" .. timeUnit or timeUnit
    end

    local defaultTime = date.hour .. ":" .. formatTimeUnit(date.min)
    local seconds = formatTimeUnit(date.sec)

    local timeText = defaultTime
    if showSecondsCB then
      timeText = timeText .. ":" .. seconds
    end
    if not disableTextCB then
      timeText = "Current time: " .. timeText
    end

    if timeTxtDropShadowCB then
      dropShadow = 1
    elseif not timeTxtDropShadowCB then
      dropShadow = 0
    end
    local timeTxtColorR = math.floor(timeTxtColor[1] * 255)
    local timeTxtColorG = math.floor(timeTxtColor[2] * 255)
    local timeTxtColorB = math.floor(timeTxtColor[3] * 255)
    local timeTxtColorA = math.floor(timeTxtColor[4] * 255)

    HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(timeText)
    HUD.SET_TEXT_JUSTIFICATION(0)
    HUD.SET_TEXT_SCALE(timeTxtScale, timeTxtScale)
    HUD.SET_TEXT_DROPSHADOW(dropShadow, 1, 1, 1, 1)
    HUD.SET_TEXT_COLOUR(timeTxtColorR, timeTxtColorG, timeTxtColorB, timeTxtColorA)
    HUD.END_TEXT_COMMAND_DISPLAY_TEXT(timeTxtLocX, timeTxtLocY, 0)
  end
end)


--[[

  Experimentals (WIP) -> HS Settings

]]--
ExperimentalTab:add_imgui(function()
  ImGui.Text("Experimental features that I'm working on and may add to this tab.")
  ImGui.Text("Feel free to test them out and give any feedback.")
  ImGui.TextColored(1,0,0,1,"You  will encounter bugs and crashes.")
  ImGui.Separator()
  ImGui.Spacing()
  ImGui.TextColored(1,0,0,1,"Broken, Crashes game")
  vehicleRampTab()
  ImGui.Separator()
  ImGui.TextColored(1,0,0,1,"Broken/Not working (Possibly breaks Yim's weather sys)")
  snowWeatherTab()
end)

--[[

  Vehicle Ramps -> Vehicle Options

]]--
local vehicleRampCB = false
local vehicleRampType = 0

function vehicleRampTab()
  local newvehicleRampCB, vehicleRampToggled = ImGui.Checkbox("Vehicle Ramp", vehicleRampCB)
  if vehicleRampToggled then
    vehicleRampCB = newvehicleRampCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("This will spawn a ramp in front of your vehicle")
  end
  if vehicleRampCB then
    vehicleRampType, vehicleRampTypeUsed = ImGui.SliderInt("Ramp Type", vehicleRampType, 0, 3)
    if ImGui.IsItemHovered() then
      HSshowTooltip("0 = Basic Ramp\n1 = Ramp 1\n2 = Ramp 2\n3 = Ramp 3")
    end
  end
end

script.register_looped("HS Vehicle Ramp Loop", function(vehicleRampLoop)
  if vehicleRampCB then
    local players = PLAYER.PLAYER_PED_ID()
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(players, false)
    if vehicle ~= 0 then
      local coords = ENTITY.GET_ENTITY_COORDS(vehicle, true)
      local iBoneIndex = PED.GET_PED_BONE_INDEX(vehicle, 0)
      local basicRampHash = MISC.GET_HASH_KEY("lts_prop_lts_ramp_02")
      STREAMING.REQUEST_MODEL(basicRampHash)
      local object = OBJECT.CREATE_OBJECT(basicRampHash, coords.x, coords.y, coords.z, true, false, false)
      ENTITY.ATTACH_ENTITY_TO_ENTITY(object, vehicle, iBoneIndex, coords.x, coords.y, coords.z, 0, 0, 0, false, true, true, false, 1, true, 0)
    end
  end
end)

--[[

  Snow Weather -> World Options

]]--
local snowWeatherCB = false
function snowWeatherTab()
  local newsnowWeatherCB, snowWeatherToggled = ImGui.Checkbox("Snow Weather", snowWeatherCB)
  if snowWeatherToggled then
    snowWeatherCB = newsnowWeatherCB
  end
  if ImGui.IsItemHovered() then
    HSshowTooltip("This will enable/disable snow weather")
  end
end

script.register_looped("HS Snow Weather Loop", function(snowLoop)
  if snowWeatherCB then
    MISC.SET_WEATHER_TYPE_PERSIST("XMAS")
    MISC.SET_WEATHER_TYPE_NOW_PERSIST("XMAS")
    MISC.SET_WEATHER_TYPE_NOW("XMAS")
    MISC.SET_OVERRIDE_WEATHER("XMAS")
    STREAMING.REQUEST_NAMED_PTFX_ASSET("core_snow")
		GRAPHICS.USE_PARTICLE_FX_ASSET("core_snow")
		AUDIO.REQUEST_SCRIPT_AUDIO_BANK("ICE_FOOTSTEPS", true, -1)
		AUDIO.REQUEST_SCRIPT_AUDIO_BANK("SNOW_FOOTSTEPS", true, -1)
    AUDIO.REQUEST_SCRIPT_AUDIO_BANK("core_snow", true, -1)
    GRAPHICS.USE_SNOW_FOOT_VFX_WHEN_UNSHELTERED(true)
    GRAPHICS.USE_SNOW_WHEEL_VFX_WHEN_UNSHELTERED(true)
  else
    MISC.CLEAR_OVERRIDE_WEATHER()
    MISC.SET_WEATHER_TYPE_NOW_PERSIST("CLEAR")
    MISC.SET_WEATHER_TYPE_NOW("CLEAR")
    MISC.SET_WEATHER_TYPE_PERSIST("CLEAR")
    STREAMING.REMOVE_NAMED_PTFX_ASSET("core_snow")
    GRAPHICS.RESET_PARTICLE_FX_OVERRIDE("core_snow")
    AUDIO.RELEASE_NAMED_SCRIPT_AUDIO_BANK("ICE_FOOTSTEPS")
    AUDIO.RELEASE_NAMED_SCRIPT_AUDIO_BANK("SNOW_FOOTSTEPS")
    AUDIO.RELEASE_NAMED_SCRIPT_AUDIO_BANK("core_snow")
    GRAPHICS.USE_SNOW_FOOT_VFX_WHEN_UNSHELTERED(false)
    GRAPHICS.USE_SNOW_WHEEL_VFX_WHEN_UNSHELTERED(false)
  end
end)


--[[

  Harmless's Scripts Functions

]]--

-- Show notifications for Harmless's Scripts
function HSNotification(message)
  if notifyCB then
    gui.show_message("Harmless's Scripts", message)
  end
end
-- Show tooltip when hovered over Harmless's Scripts UI items
function HSshowTooltip(message)
  if toolTipCB then
    ImGui.SetTooltip(message)
  end
end
-- Console logs for Harmless's Scripts
function HSConsoleLogInfo(message) -- Info
  if HSConsoleLogInfoCB then
    log.info(message)
  end
end
function HSConsoleLogWarn(message) -- Warning
  if HSConsoleLogWarnCB then
    log.warning(message)
  end
end
function HSConsoleLogDebug(message) -- Debug
  if HSConsoleLogDebugCB then
    log.debug(message)
  end
end
