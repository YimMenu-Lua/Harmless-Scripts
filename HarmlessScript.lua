--[[
  Harmless's Scripts
  Description: Harmless's Scripts is a collection of scripts made by Harmless.
  Version: 1.3.0
]]--

--[[

  Credits List:
  - @pierrelasse - NPC ESP help
  - @xesdoog - Ragdoll Loop stuck fix; Expanded radar fix; Close button fix
  - @Deadlineem - Tooltip icon
  - @rxi - The original json library (json.lua)

]]--

HSVersion = "1.3.0"

gui.show_message("Harmless's Scripts", "Harmless's Scripts loaded successfully!")
log.info("Version " .. HSVersion .. " loaded successfully!")

HSTab = gui.get_tab("Harmless's Scripts")
SelfTab = HSTab:add_tab("Self Options")
TeleportTab = SelfTab:add_tab("Teleport Options")
VehicleTab = HSTab:add_tab("Vehicle Options")
MiscTab = HSTab:add_tab("Misc Options")
QuickTab = HSTab:add_tab("Quick Options")
HSSettings = HSTab:add_tab("HS Settings")
HudTab = HSSettings:add_tab("HUD")
ESPTab = HSSettings:add_tab("NPC ESP")
ExperimentalTab = HSSettings:add_tab("Experimentals")

--[[

  RXI JSON Library (Modified)
  Credits: RXI (json.lua - for the original library)

]]--

function json()
  local json = { _version = "0.1.2" }
  --encode
  local encode

  local escape_char_map = {
    [ "\\" ] = "\\",
    [ "\"" ] = "\"",
    [ "\b" ] = "b",
    [ "\f" ] = "f",
    [ "\n" ] = "n",
    [ "\r" ] = "r",
    [ "\t" ] = "t",
  }

  local escape_char_map_inv = { [ "/" ] = "/" }
  for k, v in pairs(escape_char_map) do
    escape_char_map_inv[v] = k
  end

  local function escape_char(c)
    return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
  end

  local function encode_nil(val)
    return "null"
  end

  local function encode_table(val, stack)
    local res = {}
    stack = stack or {}
    if stack[val] then error("circular reference") end

    stack[val] = true

    if rawget(val, 1) ~= nil or next(val) == nil then
      local n = 0
      for k in pairs(val) do
        if type(k) ~= "number" then
          error("invalid table: mixed or invalid key types")
        end
        n = n + 1
      end
      if n ~= #val then
        error("invalid table: sparse array")
      end
      for i, v in ipairs(val) do
        table.insert(res, encode(v, stack))
      end
      stack[val] = nil
      return "[" .. table.concat(res, ",") .. "]"
    else
      for k, v in pairs(val) do
        if type(k) ~= "string" then
          error("invalid table: mixed or invalid key types")
        end
        table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
      end
      stack[val] = nil
      return "{" .. table.concat(res, ",") .. "}"
    end
  end

  local function encode_string(val)
    return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
  end

  local function encode_number(val)
    if val ~= val or val <= -math.huge or val >= math.huge then
      error("unexpected number value '" .. tostring(val) .. "'")
    end
    return string.format("%.14g", val)
  end

  local type_func_map = {
    [ "nil"     ] = encode_nil,
    [ "table"   ] = encode_table,
    [ "string"  ] = encode_string,
    [ "number"  ] = encode_number,
    [ "boolean" ] = tostring,
  }

  encode = function(val, stack)
    local t = type(val)
    local f = type_func_map[t]
    if f then
      return f(val, stack)
    end
    error("unexpected type '" .. t .. "'")
  end

  function json.encode(val)
    return ( encode(val) )
  end


  --decode
  local parse

  local function create_set(...)
    local res = {}
    for i = 1, select("#", ...) do
      res[ select(i, ...) ] = true
    end
    return res
  end

  local space_chars   = create_set(" ", "\t", "\r", "\n")
  local delim_chars   = create_set(" ", "\t", "\r", "\n", "]", "}", ",")
  local escape_chars  = create_set("\\", "/", '"', "b", "f", "n", "r", "t", "u")
  local literals      = create_set("true", "false", "null")

  local literal_map = {
    [ "true"  ] = true,
    [ "false" ] = false,
    [ "null"  ] = nil,
  }

  local function next_char(str, idx, set, negate)
    for i = idx, #str do
      if set[str:sub(i, i)] ~= negate then
        return i
      end
    end
    return #str + 1
  end

  local function decode_error(str, idx, msg)
    local line_count = 1
    local col_count = 1
    for i = 1, idx - 1 do
      col_count = col_count + 1
      if str:sub(i, i) == "\n" then
        line_count = line_count + 1
        col_count = 1
      end
    end
    error( string.format("%s at line %d col %d", msg, line_count, col_count) )
  end

  local function codepoint_to_utf8(n)
    local f = math.floor
    if n <= 0x7f then
      return string.char(n)
    elseif n <= 0x7ff then
      return string.char(f(n / 64) + 192, n % 64 + 128)
    elseif n <= 0xffff then
      return string.char(f(n / 4096) + 224, f(n % 4096 / 64) + 128, n % 64 + 128)
    elseif n <= 0x10ffff then
      return string.char(f(n / 262144) + 240, f(n % 262144 / 4096) + 128,
                        f(n % 4096 / 64) + 128, n % 64 + 128)
    end
    error( string.format("invalid unicode codepoint '%x'", n) )
  end

  local function parse_unicode_escape(s)
    local n1 = tonumber( s:sub(1, 4),  16 )
    local n2 = tonumber( s:sub(7, 10), 16 )
    if n2 then
      return codepoint_to_utf8((n1 - 0xd800) * 0x400 + (n2 - 0xdc00) + 0x10000)
    else
      return codepoint_to_utf8(n1)
    end
  end

  local function parse_string(str, i)
    local res = ""
    local j = i + 1
    local k = j

    while j <= #str do
      local x = str:byte(j)
      if x < 32 then
        decode_error(str, j, "control character in string")
      elseif x == 92 then -- `\`: Escape
        res = res .. str:sub(k, j - 1)
        j = j + 1
        local c = str:sub(j, j)
        if c == "u" then
          local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
                  or str:match("^%x%x%x%x", j + 1)
                  or decode_error(str, j - 1, "invalid unicode escape in string")
          res = res .. parse_unicode_escape(hex)
          j = j + #hex
        else
          if not escape_chars[c] then
            decode_error(str, j - 1, "invalid escape char '" .. c .. "' in string")
          end
          res = res .. escape_char_map_inv[c]
        end
        k = j + 1
      elseif x == 34 then -- `"`: End of string
        res = res .. str:sub(k, j - 1)
        return res, j + 1
      end
      j = j + 1
    end
    decode_error(str, i, "expected closing quote for string")
  end

  local function parse_number(str, i)
    local x = next_char(str, i, delim_chars)
    local s = str:sub(i, x - 1)
    local n = tonumber(s)
    if not n then
      decode_error(str, i, "invalid number '" .. s .. "'")
    end
    return n, x
  end

  local function parse_literal(str, i)
    local x = next_char(str, i, delim_chars)
    local word = str:sub(i, x - 1)
    if not literals[word] then
      decode_error(str, i, "invalid literal '" .. word .. "'")
    end
    return literal_map[word], x
  end

  local function parse_array(str, i)
    local res = {}
    local n = 1
    i = i + 1
    while 1 do
      local x
      i = next_char(str, i, space_chars, true)
      -- Empty / end of array?
      if str:sub(i, i) == "]" then
        i = i + 1
        break
      end
      -- Read token
      x, i = parse(str, i)
      res[n] = x
      n = n + 1
      -- Next token
      i = next_char(str, i, space_chars, true)
      local chr = str:sub(i, i)
      i = i + 1
      if chr == "]" then break end
      if chr ~= "," then decode_error(str, i, "expected ']' or ','") end
    end
    return res, i
  end

  local function parse_object(str, i)
    local res = {}
    i = i + 1
    while 1 do
      local key, val
      i = next_char(str, i, space_chars, true)
      -- Empty / end of object?
      if str:sub(i, i) == "}" then
        i = i + 1
        break
      end
      -- Read key
      if str:sub(i, i) ~= '"' then
        decode_error(str, i, "expected string for key")
      end
      key, i = parse(str, i)
      -- Read ':' delimiter
      i = next_char(str, i, space_chars, true)
      if str:sub(i, i) ~= ":" then
        decode_error(str, i, "expected ':' after key")
      end
      i = next_char(str, i + 1, space_chars, true)
      -- Read value
      val, i = parse(str, i)
      -- Set
      res[key] = val
      -- Next token
      i = next_char(str, i, space_chars, true)
      local chr = str:sub(i, i)
      i = i + 1
      if chr == "}" then break end
      if chr ~= "," then decode_error(str, i, "expected '}' or ','") end
    end
    return res, i
  end

  local char_func_map = {
    [ '"' ] = parse_string,
    [ "0" ] = parse_number,
    [ "1" ] = parse_number,
    [ "2" ] = parse_number,
    [ "3" ] = parse_number,
    [ "4" ] = parse_number,
    [ "5" ] = parse_number,
    [ "6" ] = parse_number,
    [ "7" ] = parse_number,
    [ "8" ] = parse_number,
    [ "9" ] = parse_number,
    [ "-" ] = parse_number,
    [ "t" ] = parse_literal,
    [ "f" ] = parse_literal,
    [ "n" ] = parse_literal,
    [ "[" ] = parse_array,
    [ "{" ] = parse_object,
  }

  parse = function(str, idx)
    local chr = str:sub(idx, idx)
    local f = char_func_map[chr]
    if f then
      return f(str, idx)
    end
    decode_error(str, idx, "unexpected character '" .. chr .. "'")
  end

  function json.decode(str)
    if type(str) ~= "string" then
      error("expected argument of type string, got " .. type(str))
    end
    local res, idx = parse(str, next_char(str, 1, space_chars, true))
    idx = next_char(str, idx, space_chars, true)
    if idx <= #str then
      decode_error(str, idx, "trailing garbage")
    end
    return res
  end

  return json
end

json = json()

local default_config = {
  enableScriptsCB = false,
  state3 = false,
  healthCB = false,
  armourCB = false,
  healthregenspeed = 1,
  armourregenspeed = 1,
  healthhealamount = 10,
  armourhealamount = 5,
  ragdollCB = false,
  ragdollLoopCB = false,
  ragdollLoopSpeed = 1,
  ragdollForceFlags = 1,
  ragdollForceX = 10,
  ragdollForceY = 10,
  ragdollForceZ = 10,
  ragdollType = 0,
  walkCB = false,
  walkSpeed = 1.2,
  swimCB = false,
  swimSpeed = 1.2,
  drawMarkerCB = false,
  QTPLineESPCB = false,
  maxSpeedCB = false,
  speedLimit = 1000,
  forwardSpeedCB = false,
  speedBoost = 100,
  shiftDriftCB = false,
  driftAmount = 1,
  driftTyresCB = false,
  autoFlipVehicleCB = false,
  walkOnAirCB = false,
  lowGraphicsCB = false,
  snowTrailsCB = false,
  tVisStartFade = 1000,
  tVisEndFade = 1000,
  tVisWallThickness = 200,
  tVisNoiseMin = 0.0,
  tVisNoiseMax = 0.0,
  tVisHilightIntensity = 0.5,
  tVisHilightNoise = 0.0,
  nightVisionCB = false,
  defaultNightVisCV = false,
  nVisLightRange = 100,
  weaponScopeCB = false,
  npcEspCB = false,
  npcEspShowEnemCB = false,
  npcEspBoxCB = true,
  npCEspTracerCB = false,
  npcEspLosCB = false,
  npcEspDistance = 50,
  npcEspColor = {1.0, 0.0, 0.0, 1.0},
  notifyCB = true,
  warnNotifyCB = true,
  errorNotifyCB = true,
  toolTipCB = false,
  toolTipV2CB = true,
  toolTipDelay = 0.3,
  toolTipIconCB = true,
  toolTipIconOnlyCB = false,
  HSConsoleLogInfoCB = true,
  HSConsoleLogWarnCB = true,
  HSConsoleLogDebugCB = false,
  clockCB = false,
  showSecondsCB = false,
  clockTextCB = false,
  clockLocX = 0.94,
  clockLocY = 0.01,
  clockScale = 0.4,
  clockColor = {1.0, 1.0, 1.0, 1.0},
  clockDropShadowCB = true,
  expandedRadarCB = false,
  radarZoom = 0,
}

--[[

  HS Config Functions

]]--  
function writeToFile(filename, data)
  local file, err = io.open(filename, "w")
  if file == nil then
    log.warning("Failed to write to " .. filename)
    gui.show_error("Harmless's Scripts", "Failed to write to " .. filename)
    return false
  end
  file:write(json.encode(data))
  file:close()
  return true
end

function readFromFile(filename)
  local file, err = io.open(filename, "r")
  if file == nil then
    return nil
  end
  local content = file:read("*all")
  file:close()
  return json.decode(content)
end

function checkAndCreateConfig(default_config)
  local configExists = io.exists("HSConfig.json")
  local config

  if not configExists then
    log.warning("Config file not found, creating a default config")
    gui.show_warning("Harmless's Scripts", "Config file not found, creating a default config")
    if not writeToFile("HSConfig.json", default_config) then
      return false
    end
    config = default_config
  else
    config = readFromFile("HSConfig.json")
    if config == nil then
      log.error("Failed to read config file")
      return false
    end
  end

  for key, defaultValue in pairs(default_config) do
    if config[key] == nil then
      config[key] = defaultValue
    end
  end

  if not writeToFile("HSConfig.json", config) then
    return false
  end
  return true
end

function readAndDecodeConfig()
  while not checkAndCreateConfig(default_config) do
    -- Wait for the file to be created
    os.execute("sleep " .. tonumber(1))
    log.debug("Waiting for HSConfig.json to be created")
  end
  return readFromFile("HSConfig.json")
end

function saveToConfig(item_tag, value)
  local t = readAndDecodeConfig()
  if t then
    t[item_tag] = value
    if not writeToFile("HSConfig.json", t) then
      log.debug("Failed to encode JSON to HSConfig.json")
    end
  end
end

function readFromConfig(item_tag)
  local t = readAndDecodeConfig()
  if t then
    return t[item_tag]
  else
    log.debug("Failed to decode JSON from HSConfig.json")
  end
end

function resetConfig(default_config)
  writeToFile("HSConfig.json", default_config)
end

--[[

  Harmless's Scripts Tab

]]--
HSTab:add_imgui(function()
  ImGui.Spacing();ImGui.Spacing();ImGui.SeparatorText("About")
  ImGui.BulletText("Version: " .. HSVersion)
  ImGui.BulletText("Github:")
  ImGui.SameLine(); ImGui.TextColored(0.8, 0.9, 1, 1, "YimMenu-Lua/Harmless-Scripts")
  if ImGui.IsItemHovered() and ImGui.IsItemClicked(0) then
    ImGui.SetClipboardText("https://github.com/YimMenu-Lua/Harmless-Scripts")
    HSNotification("Copied to clipboard!")
    HSConsoleLogInfo("Copied https://github.com/YimMenu-Lua/Harmless-Scripts to clipboard!")
  end
  HSshowTooltip("Click to copy to clipboard")
  ImGui.Spacing();ImGui.SeparatorText("Credits")
  ImGui.BulletText("pierrelasse - NPC ESP help")
  ImGui.BulletText("xesdoog - Ragdoll Loop stuck fix; Expanded radar fix; Close button fix")
  ImGui.BulletText("Deadlineem - Tooltip icon idea")
  ImGui.BulletText("rxi - The original json library (json.lua)")
end)

--[[

  Enable "In Menu" Scripts -> Harmless's Scripts

]]--
local enableScriptsCB = readFromConfig("enableScriptsCB")
local state3 = readFromConfig("state3")
function enableScriptsTab()
  enableScriptsCB = HSCheckbox(ReverseBoolToStatus(enableScriptsCB) .. " \"In Menu\" features separately (WIP)", enableScriptsCB, "enableScriptsCB")
  HSshowTooltip(ReverseBoolToStatus(enableScriptsCB) .. " every script in the menu separately in their respective locations", "WIP", {1, 0.7, 0.4, 1})
  if enableScriptsCB then
    state3 = HSCheckbox(ReverseBoolToStatus(state3) .. " Regeneration in \"Self\"", state3, "state3")
    HSshowTooltip(ReverseBoolToStatus(state3) .. " Regeneration in \"Self\"")
  else
    state3 = false
    saveToConfig("state3", false)
  end
end


--[[

  Self Options

--]]
SelfTab:add_imgui(function()
  ImGui.Spacing();ImGui.SeparatorText("Regeneration")
  playerRegenTab()
  ImGui.Spacing();ImGui.SeparatorText("Speed Multipliers")
  playerSpeedTab()
  ImGui.Spacing();ImGui.SeparatorText("Ragdoll Options")
  ragdollPlayerTab()
end)

--[[

  Player Regeneration -> Self Options

--]]
local healthCB = readFromConfig("healthCB")
local armourCB = readFromConfig("armourCB")
local healthregenspeed = readFromConfig("healthregenspeed") -- second(s)
local armourregenspeed = readFromConfig("armourregenspeed") -- second(s)
local healthhealamount = readFromConfig("healthhealamount")
local armourhealamount = readFromConfig("armourhealamount")
function playerRegenTab()
  healthCB = HSCheckbox("Player Regeneration", healthCB, "healthCB")
  healthregenspeed, healthregenspeedUsed = HSSliderFloat("Health Regen Speed", healthregenspeed, 0, 10, "%.1f", ImGuiSliderFlags.Logarithmic, "healthregenspeed")
  healthhealamount, healthhealamountUsed = HSSliderInt("Health Regen Amount", healthhealamount, 1, 50, "healthhealamount")
  armourCB = HSCheckbox("Armor Regeneration", armourCB, "armourCB")
  armourregenspeed, armourregenspeedUsed = HSSliderFloat("Armor Regen Speed", armourregenspeed, 0, 10, "%.1f", ImGuiSliderFlags.Logarithmic, "armourregenspeed")
  armourhealamount, armourhealamountUsed = HSSliderInt("Armor Regen Amount", armourhealamount, 1, 50, "armourhealamount")
end

script.register_looped("HS Health Regeneration", function(healthLoop)
  if healthCB and ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID()) < ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID()) and PLAYER.IS_PLAYER_DEAD(PLAYER.PLAYER_ID()) == false and HUD.BUSYSPINNER_IS_ON() == false then
    HSConsoleLogDebug("Adding " .. healthhealamount .. " amount health")
    local health = ENTITY.GET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID())
    if ENTITY.GET_ENTITY_MAX_HEALTH(PLAYER.PLAYER_PED_ID()) == health then return end
    ENTITY.SET_ENTITY_HEALTH(PLAYER.PLAYER_PED_ID(), health + healthhealamount, 0, 0)
    healthLoop:sleep(math.floor(healthregenspeed * 1000)) -- 1ms * 1000 to get seconds
  end
end)

script.register_looped("HS Armour Regeneration", function(armorLoop)
  if armourCB and PED.GET_PED_ARMOUR(PLAYER.PLAYER_PED_ID()) < PLAYER.GET_PLAYER_MAX_ARMOUR(PLAYER.PLAYER_ID()) and PLAYER.IS_PLAYER_DEAD(PLAYER.PLAYER_ID()) == false and HUD.BUSYSPINNER_IS_ON() == false then
    HSConsoleLogDebug("Adding " .. armourhealamount .. " amount armor")
    PED.ADD_ARMOUR_TO_PED(PLAYER.PLAYER_PED_ID(), armourhealamount)
    armorLoop:sleep(math.floor(armourregenspeed * 1000)) -- 1ms * 1000 to get seconds
  end
end)

--[[

  Ragdoll Player -> Self Options

]]--
local ragdollCB = readFromConfig("ragdollCB")
local ragdollLoopCB = readFromConfig("ragdollLoopCB")
local ragdollLoopSpeed = readFromConfig("ragdollLoopSpeed")
local ragdollForceFlags = readFromConfig("ragdollForceFlags")
local ragdollForceX = readFromConfig("ragdollForceX")
local ragdollForceY = readFromConfig("ragdollForceY")
local ragdollForceZ = readFromConfig("ragdollForceZ")
local ragdollType =readFromConfig("ragdollType")

function ragdollPlayerTab()
  if ImGui.Button("Ragdoll Player [Once]") then
    ragdollPlayerOnce()
    HSConsoleLogDebug("Ragdolling Player Once")
  end
  ImGui.SameLine(); ragdollLoopCB = HSCheckbox("Ragdoll Player [Loop]", ragdollLoopCB, "ragdollLoopCB")
  ImGui.Separator()
  ImGui.LabelText("Parameters", "Ragdoll Settings")
  ragdollLoopSpeed, ragdollLoopSpeedUsed = HSSliderFloat("Loop Speed", ragdollLoopSpeed, 0, 10, "%.1f", ImGuiSliderFlags.Logarithmic, "ragdollLoopSpeed")
  HSshowTooltip("Change the speed at which the loop runs (in seconds)")
  ragdollForceFlags, ragdollForceFlagsUsed = HSSliderInt("Ragdoll Force Flags", ragdollForceFlags, 0, 5, "ragdollForceFlags")
  HSshowTooltip("0 = Weak Force\n1 = Strong Force\n2 = Same as 0\n3 = Same as 1\n4 = Weak Momentum\n5 = Strong Momentum")
  ragdollForceX, ragdollForceXUsed = HSSliderInt("Force X", ragdollForceX, 0, 100, "ragdollForceX")
  ragdollForceY, ragdollForceYUsed = HSSliderInt("Force Y", ragdollForceY, 0, 100, "ragdollForceY")
  ragdollForceZ, ragdollForceZUsed = HSSliderInt("Force Z", ragdollForceZ, 0, 100, "ragdollForceZ")
  ragdollType, ragdollTypeUsed = HSSliderInt("Ragdoll Type", ragdollType, 0, 3, "ragdollType")
  HSshowTooltip("0 = Normal Ragdoll\n1 = Falls with stiff legs/body\n2 = Narrow leg stumble\n3 = Wide leg stumble")
end

function ragdollPlayerOnce()
  local forceFlags = ragdollForceFlags
  local ragdollType = ragdollType
  local forcex = ragdollForceX
  local forcey = ragdollForceY
  local forcez = ragdollForceZ
  local players = PLAYER.PLAYER_PED_ID()
  PED.SET_PED_TO_RAGDOLL(players, 1500, 0, ragdollType, true)
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
    PED.SET_PED_TO_RAGDOLL(players, 3000, 0, ragdollType, true, true, false)
    ENTITY.APPLY_FORCE_TO_ENTITY(players, forceFlags, forcex, forcey, forcez, 0, 0, 0, 0, false, true, true, false, true)
    ragdollLoop:sleep(math.floor(loopspd))
  end
end)

--[[

  Player Speed Multipliers -> Self Options

]]--
local walkCB = readFromConfig("walkCB")
local walkSpeed = readFromConfig("walkSpeed")
local swimCB = readFromConfig("swimCB")
local swimSpeed = readFromConfig("swimSpeed")

function playerSpeedTab()
  walkCB, walkCBUsed = HSCheckbox("Walk Speed Multiplier", walkCB, "walkCB")
  walkSpeed, walkSpeedUsed = HSSliderFloat("Walk speed multiplier", walkSpeed, 1, 1.49, "%.1f", ImGuiSliderFlags.Logarithmic, "walkSpeed")
  swimCB, swimCBUsed = HSCheckbox("Swim Speed Multiplier", swimCB, "swimCB")
  swimSpeed, swimSpeedUsed = HSSliderFloat("Swim speed multiplier", swimSpeed, 1, 1.49, "%.1f", ImGuiSliderFlags.Logarithmic, "swimSpeed")
end

script.run_in_fiber(function(playerSpeedMultiplier)
  while true do
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
    playerSpeedMultiplier:yield()
  end
end)

--[[

  Teleport Options

]]--

--[[

  Quick Teleport -> Teleport Options

]]--

TeleportTab:add_imgui(function()
  ImGui.Spacing();ImGui.SeparatorText("Quick Teleport")
  quickTeleportTab()
  ImGui.Spacing();ImGui.SeparatorText("Popular Locations")
  PopularLocTab()
end)

local teleportLocations = {}
local drawMarkerCB = readFromConfig("drawMarkerCB")
local QTPLineESPCB = readFromConfig("QTPLineESPCB")

function quickTeleportTab()
  local player = PLAYER.PLAYER_PED_ID()
  local currentCoords = ENTITY.GET_ENTITY_COORDS(player, true)

  if ImGui.Button("Save Current Location") then
    local heading = ENTITY.GET_ENTITY_HEADING(player)
    teleportLocations[1] = {currentCoords.x, currentCoords.y, currentCoords.z, heading}
    HSNotification("Saved current location!")
    HSConsoleLogDebug("Saved current location")
    HSConsoleLogDebug("Saved location: x = " .. currentCoords.x .. ", y = " .. currentCoords.y .. ", z = " .. currentCoords.z .. ", heading = " .. heading)
  end

  if teleportLocations[1] ~= nil then
    local savedLocation = teleportLocations[1]
    ImGui.Text(string.format("Saved location: X=%.2f, Y=%.2f, Z=%.2f", savedLocation[1], savedLocation[2], savedLocation[3]))
    
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
    drawMarkerCB, drawMarkerCBToggled = HSCheckbox("Draw Marker", drawMarkerCB, "drawMarkerCB")
    HSshowTooltip("Draws a marker at the saved location")
    QTPLineESPCB, QTPLineESPCBToggled = HSCheckbox("Line ESP", QTPLineESPCB, "QTPLineESPCB")
    HSshowTooltip("Draws a line from the player to the saved location")
  end
end

local function drawMarker()
  if drawMarkerCB then
    local savedLocation = teleportLocations[1]
    if savedLocation ~= nil then
    local player = PLAYER.PLAYER_PED_ID()
      GRAPHICS.DRAW_MARKER(1, savedLocation[1], savedLocation[2], savedLocation[3], 0, 0, 0, 0, 0, 0, 2.0, 2.0, savedLocation[3] + 1500.0, 255, 255, 255, 100, false, false, 2, false, 0, 0, false)
    end
  end
end

local function QTPLineESP()
  if QTPLineESPCB then
    local savedLocation = teleportLocations[1]
    if savedLocation ~= nil then
      local player = PLAYER.PLAYER_PED_ID()
      local playerCoords = ENTITY.GET_ENTITY_COORDS(player, true)
      GRAPHICS.DRAW_LINE(playerCoords.x, playerCoords.y, playerCoords.z, savedLocation[1], savedLocation[2], savedLocation[3], 255, 255, 255, 255)
    end
  end
end

script.register_looped("QuickTP Loops", function(quicktploops)
  drawMarker()
  QTPLineESP()
end)

--[[

  Popular Locations -> Teleport Options

]]--

TeleportToLocCB = true
popularLocations = {
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
  {name = "Airport Tower", x = -985.0, y = -2642.0, z = 63.5, heading = 235.5}
}

function PopularLocTab()
  local player = PLAYER.PLAYER_PED_ID()

  -- Create a list of location names
  locationNames = {}
  for i, location in ipairs(popularLocations) do
    table.insert(locationNames, location.name)
  end

  TeleportToLocCB, teleportToLocToggled = HSCheckbox("Teleport to Location", TeleportToLocCB, "TeleportToLocCB")
  if teleportToLocToggled then
    ViewLocAsCamCB = false
  end
  
  popularLocationsIndex = 0
  current_item = popularLocationsIndex
  wasUsed = false
  current_item, wasUsed = HSCombobox("", current_item, locationNames, #locationNames, 7)
  if wasUsed then
    popularLocationsIndex = current_item
    selectedLocation = popularLocations[current_item + 1]
    if TeleportToLocCB then
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
  ImGui.Spacing();ImGui.SeparatorText("Speed Manipulation")
  setVehicleMaxSpeedTab()
  setVehicleForwardSpeedTab()
  ImGui.Spacing();ImGui.SeparatorText("Drift")
  shiftDriftTab()
  ImGui.Spacing();ImGui.SeparatorText("Vehicle Manipulation")
  autoFlipVehicleTab()
end)

--[[

  Set Vehicle Max Speed -> Vehicle Options

]]--
local maxSpeedCB = readFromConfig("maxSpeedCB")
local speedLimit = readFromConfig("speedLimit")
function setVehicleMaxSpeedTab()
  maxSpeedCB, maxSpeedToggled = HSCheckbox("Set Vehicle Max Speed", maxSpeedCB, "maxSpeedCB")
  HSshowTooltip("This will set your vehicle's max speed to the speed you set")
  speedLimit, speedLimitUsed = HSSliderInt("Speed Limit", speedLimit, 1, 1000, "speedLimit")
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
local forwardSpeedCB = readFromConfig("forwardSpeedCB")
local speedBoost = readFromConfig("speedBoost")
function setVehicleForwardSpeedTab()
  forwardSpeedCB, forwardSpeedToggled = HSCheckbox("Set Vehicle Forward Speed", forwardSpeedCB, "forwardSpeedCB")
  HSshowTooltip("When enabled, press \"W\" to go forward at the speed you set")
  speedBoost, speedBoostUsed = HSSliderInt("Boosted Speed", speedBoost, 1, 1000, "speedBoost")
end

script.register_looped("HS Set Vehicle Forward Speed Loop", function(speedLoop)
  if forwardSpeedCB and PAD.IS_CONTROL_PRESSED(0, 71) and PED.IS_PED_IN_VEHICLE(PLAYER.PLAYER_PED_ID(), PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true), false) then
    local speed = speedBoost
    local CurrentVeh = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), true)
    VEHICLE.SET_VEHICLE_FORWARD_SPEED(CurrentVeh, speed)
  end
end)

--[[

  Shift Drift -> Vehicle Options

]]--
local shiftDriftCB = readFromConfig("shiftDriftCB")
local driftAmount = readFromConfig("driftAmount")
local driftTyresCB = readFromConfig("driftTyresCB")
function shiftDriftTab()
  shiftDriftCB, shiftDriftToggled = HSCheckbox("Shift Drift", shiftDriftCB, "shiftDriftCB")
  if shiftDriftToggled then
    if not shiftDriftCB then
      driftTyresCB = false
      saveToConfig("driftTyresCB", false)
    end
  end
  HSshowTooltip("Press \"Shift\" to drift")
  if shiftDriftCB then
    driftTyresCB, driftTyresToggled = HSCheckbox("Use Low Grip Tyres", driftTyresCB, "driftTyresCB")
    HSshowTooltip("This will use GTAV's Low Grip Tyres for drifting instead")
  end
  if not driftTyresCB then
    driftAmount, driftAmountUsed = HSSliderInt("Drift Amount", driftAmount, 0, 3, "driftAmount")
    HSshowTooltip("0 = Loosest Drift\n1 = Loose Drift (Recommended)\n2 = Stiff Drift\n3 = Stiffest Drift")
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
local autoFlipVehicleCB = readFromConfig("autoFlipVehicleCB")
function autoFlipVehicleTab()
  autoFlipVehicleCB, autoFlipVehicleToggled = HSCheckbox("Auto Flip Vehicle", autoFlipVehicleCB, "autoFlipVehicleCB")
  HSshowTooltip("This will automatically flip your vehicle upright if it is upside down")
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
  ImGui.Spacing();ImGui.SeparatorText("Player Movement")
  walkOnAirTab()
  ImGui.Spacing();ImGui.SeparatorText("Low Graphics")
  lowGraphicsTab()
  ImGui.Spacing();ImGui.SeparatorText("Snow Trails")
  snowTrailsTab()
end)

--[[

  Walk on Air -> Misc Options

]]--
local walkOnAirCB = readFromConfig("walkOnAirCB")
function walkOnAirTab()
  walkOnAirCB, walkOnAirToggled = HSCheckbox("Walk on Air", walkOnAirCB, "walkOnAirCB")
  HSshowTooltip("Air Jesus")
end

local object = nil
local objectSpawned = false

function spawnObject(walkOnAirLoop) -- Spawns the "air" (object)
  local model = -698352776
  STREAMING.REQUEST_MODEL(model)
  while not STREAMING.HAS_MODEL_LOADED(model) do walkOnAirLoop:yield() end -- Wait for the model to load

  gui.show_message("Controls", "Left SHIFT = go up\nLeft CTRL = go down")
  HSConsoleLogDebug("Spawning object")
  local player = PLAYER.PLAYER_PED_ID()
  local coords = ENTITY.GET_ENTITY_COORDS(player, true)
  object = OBJECT.CREATE_OBJECT(model, coords.x, coords.y, coords.z - 1.2, true, false, false)
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
      spawnObject(walkOnAirLoop)
      objectSpawned = true
    end
    if object ~= nil then
      local player = PLAYER.PLAYER_PED_ID()
      local playerCoords = ENTITY.GET_ENTITY_COORDS(player, true)
      if PAD.IS_CONTROL_PRESSED(0, 36) then -- 36 = left CTRl
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(object, playerCoords.x, playerCoords.y, playerCoords.z - 1.4, false, false, false, false)
        walkOnAirLoop:sleep(100)
      elseif PAD.IS_CONTROL_PRESSED(0, 21) then -- 21 = left SHIFT
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(object, playerCoords.x, playerCoords.y, playerCoords.z - 0.7, false, false, false, false)
        walkOnAirLoop:sleep(50)
      else
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(object, playerCoords.x, playerCoords.y, playerCoords.z - 1.075, false, false, false, false)
        walkOnAirLoop:sleep(50)
      end
    end
  else
    objectSpawned = false
    deleteObject()
  end
end)

--[[

  Low Graphics -> Misc Options

]]--

local lowGraphicsCB = readFromConfig("lowGraphicsCB")
function lowGraphicsTab()
  lowGraphicsCB, lowGraphicsToggled = HSCheckbox("Low Graphics", lowGraphicsCB, "lowGraphicsCB")
  HSshowTooltip("Enables low graphics mode")
  if lowGraphicsToggled then
    if lowGraphicsCB then
      STREAMING.SET_FOCUS_POS_AND_VEL(9999, 9999, -9999, 0, 0, 0)
    elseif not lowGraphicsCB then
      STREAMING.CLEAR_FOCUS()
    end
  end
end

--[[

  Snow Trails -> Misc Options

]]--

local snowTrailsCB = readFromConfig("snowTrailsCB")
function snowTrailsTab()
  snowTrailsCB, snowTrailsToggled = HSCheckbox("Snow Trails", snowTrailsCB, "snowTrailsCB")
  HSshowTooltip("Enables snow trails for peds and vehicles")
  if snowTrailsToggled then
    if snowTrailsCB then
      GRAPHICS.USE_SNOW_FOOT_VFX_WHEN_UNSHELTERED(true)
      GRAPHICS.USE_SNOW_WHEEL_VFX_WHEN_UNSHELTERED(true)
    elseif not snowTrailsCB then
      GRAPHICS.USE_SNOW_FOOT_VFX_WHEN_UNSHELTERED(false)
      GRAPHICS.USE_SNOW_WHEEL_VFX_WHEN_UNSHELTERED(false)
    end
  end
end


--[[

  Quick Options

]]--
QuickTab:add_imgui(function()
  ImGui.Text("YimMenu Hotkeys exsist for all of these, but what if you don't want to use hotkeys?")
  SelfPed = PLAYER.PLAYER_PED_ID()

  -- Self Options
  ImGui.Spacing();ImGui.SeparatorText("Player")
  if ImGui.Button("Clear Wanted Level") then
    command.call("clearwantedlvl",{})
    command.call("clearwantedlvl",{})
  end
  if ImGui.Button("Heal Player") then
    command.call("heal",{})
  end
    HSshowTooltip("This will give max health and armor to the player")
    if ImGui.Button("Give All Weapons") then
    command.call("giveweaps",{SelfPed})
  end
  HSshowTooltip("Give all weapons only works Online")
  if ImGui.Button("Give All Ammo") then
    command.call("giveammo",{SelfPed})
  end
  HSshowTooltip("Give all ammo only works Online")
  if ImGui.Button("Fill Ammo") then
    command.call("fillammo",{})
  end
  if ImGui.Button("Give Max Armor") then
    command.call("givearmor",{SelfPed})
  end
  HSshowTooltip("Give max armor only works Online")
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

  -- Teleport Options
  ImGui.Spacing();ImGui.SeparatorText("Teleport")
  if ImGui.Button("TP to Waypoint") then
    command.call("waypointtp",{})
  end
  ImGui.SameLine()
  if ImGui.Button("TP to Objective") then
    command.call("objectivetp",{})
  end

  -- Vehicle Options
  ImGui.Spacing();ImGui.SeparatorText("Vehicle")
  if ImGui.Button("Repair PV") then
    command.call("repairpv", {})
  end
  if ImGui.Button("Upgrade Vehicle") then
    command.call("upgradeveh",{SelfPed})
  end
  HSshowTooltip("Upgrade vehicle only works Online")
  ImGui.SameLine()
  if ImGui.Button("Downgrade Vehicle") then
    command.call("downgradeveh",{SelfPed})
  end
  HSshowTooltip("Downgrade vehicle only works Online")
  if ImGui.Button("Bring PV") then
    command.call("bringpv",{})
  end
  ImGui.SameLine()
  if ImGui.Button("TP into Personal Vehicle") then
    command.call("pvtp",{})
  end

  -- Misc Options
  ImGui.Spacing();ImGui.SeparatorText("Misc")
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

local notifyCB = readFromConfig("notifyCB")
local warnNotifyCB = readFromConfig("warnNotifyCB")
local errorNotifyCB = readFromConfig("errorNotifyCB")
local toolTipCB = readFromConfig("toolTipCB")
local toolTipV2CB = readFromConfig("toolTipV2CB")
toolTipDelay = readFromConfig("toolTipDelay")  -- default 0.3 seconds (300ms)
toolTipIconCB = readFromConfig("toolTipIconCB")
toolTipIconOnlyCB = readFromConfig("toolTipIconOnlyCB")
local HSConsoleLogInfoCB = readFromConfig("HSConsoleLogInfoCB")
local HSConsoleLogWarnCB = readFromConfig("HSConsoleLogWarnCB")
local HSConsoleLogDebugCB = readFromConfig("HSConsoleLogDebugCB")
HSSettings:add_imgui(function()

  --- HS Notifications
  ImGui.Spacing();ImGui.SeparatorText("Notifications")
  -- (The notifs seemed self-explanatory, so I disabled the tooltips)
  notifyCB, notifyToggled = HSCheckbox("HS Notifications", notifyCB, "notifyCB")
  if not notifyCB then
    warnNotifyCB = false
    saveToConfig("warnNotifyCB", false)
    errorNotifyCB = false
    saveToConfig("errorNotifyCB", false)
  end
  --HSshowTooltip(ReverseBoolToStatus(notifyCB) .. " notifications for Harmless's Scripts")
    warnNotifyCB, warnNotifyToggled = HSCheckbox("HS Warning Notifications", warnNotifyCB, "warnNotifyCB")
  --HSshowTooltip(ReverseBoolToStatus(warnNotifyCB) .. " warning notifications for Harmless's Scripts")
    errorNotifyCB, errorNotifyToggled = HSCheckbox("HS Error Notifications", errorNotifyCB, "errorNotifyCB")
  --HSshowTooltip(ReverseBoolToStatus(errorNotifyCB) .. " error notifications for Harmless's Scripts")

  ImGui.Spacing();ImGui.SeparatorText("Tooltips")
  --- ImGui ToolTip
  toolTipCB, toolTipToggled = HSCheckbox("HS Tooltips", toolTipCB, "toolTipCB")
  if toolTipCB then
    toolTipV2CB = false
    saveToConfig("toolTipV2CB", false)
  end
  --HSshowTooltip(ReverseBoolToStatus(toolTipCB) .. " the default ImGui tooltip for Harmless's Scripts")
  
  --- HS ToolTip V2 (Custom ToolTip)
  toolTipV2CB, toolTipV2Toggled = HSCheckbox("HS ToolTip V2", toolTipV2CB, "toolTipV2CB")
  if toolTipV2CB then
    toolTipCB = false
    saveToConfig("toolTipCB", false)
  end
  HSshowTooltip(ReverseBoolToStatus(toolTipV2CB) .. " exerimental version of custom tooltips", "This is a custom-made tooltip for Harmless's Scripts. It's currently in an experimental phase, so you may encounter some bugs and glitches.", {1, 0.4, 0.4, 1})
  
  -- ToolTip Delay Slider
  toolTipDelay, toolTipDelayUsed = HSSliderFloat("HS ToolTip Delay", toolTipDelay, 0, 1, "%.2f", ImGuiSliderFlags.Logarithmic, "toolTipDelay")
  HSshowTooltip("The amount of time in seconds before the tooltip appears")

  --- ToolTip Icon Toggle
  toolTipIconCB, toolTipIconToggled = HSCheckbox("HS ToolTip Icon", toolTipIconCB, "toolTipIconCB")
  HSshowTooltip("Shows a question mark icon next to buttons, sliders, etc")
  if not toolTipIconCB then
    toolTipIconOnlyCB = false
    saveToConfig("toolTipIconOnlyCB", false)
  end
  
  --- View ToolTip Only on Icon Hover
  toolTipIconOnlyCB, toolTipIconOnlyToggled = HSCheckbox("HS ToolTip Icon Hover Only", toolTipIconOnlyCB, "toolTipIconOnlyCB")
  HSshowTooltip("Tooltip is shown only when hovering over the question mark icon")

  --- HS Console Logs
  ImGui.Spacing();ImGui.SeparatorText("Console Logs")
  -- (The toggles seemed self-explanatory, so I disabled the tooltips)
  HSConsoleLogInfoCB, HSConsoleLogInfoToggled = HSCheckbox("HS Console Logs (Info)", HSConsoleLogInfoCB, "HSConsoleLogInfoCB")
  --HSshowTooltip(ReverseBoolToStatus(HSConsoleLogInfoCB) .. " info console logs for Harmless's Scripts")
  HSConsoleLogWarnCB, HSConsoleLogWarnToggled = HSCheckbox("HS Console Logs (Warning)", HSConsoleLogWarnCB, "HSConsoleLogWarnCB")
  --HSshowTooltip(ReverseBoolToStatus(HSConsoleLogWarnCB) .. " warning console logs for Harmless's Scripts")
  HSConsoleLogDebugCB, HSConsoleLogDebugToggled = HSCheckbox("HS Console Logs (Debug)", HSConsoleLogDebugCB, "HSConsoleLogDebugCB")
  --HSshowTooltip(ReverseBoolToStatus(HSConsoleLogDebugCB) .. " debug console logs for Harmless's Scripts")
  
  --- Reset Config Button
  ImGui.PushStyleColor(ImGuiCol.Text, 1, 0, 0, 1)
  if ImGui.Button("Reset Config") then
    ImGui.OpenPopup("Reset Config?")
  end
  ImGui.PopStyleColor()
  if ImGui.BeginPopupModal("Reset Config?", ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoScrollbar | ImGuiWindowFlags.NoScrollWithMouse) then
    local centerX, centerY = GetScreenCenter()
    ImGui.SetWindowPos(centerX - 100, centerY - 75)
    ImGui.SetWindowSize(250, 190)
    ImGui.TextColored(1, 1, 1, 1, "Are you sure you want \nto reset the config?")
    ImGui.TextColored(1, 0, 0, 1, "NB! You have to reload the \nLua script to see changes!")
    ImGui.Spacing()
    if HSButton("YES", {1, 0, 0, 1}) then
      resetConfig()
      ImGui.CloseCurrentPopup()
      HSConsoleLogWarn("Please reload the Lua script to apply changes!")
      HSWarnNotif("Please reload the Lua script to apply changes!")
    end
    ImGui.SameLine();ImGui.Dummy(130, 1);ImGui.SameLine()
    if HSButton("NO", {0.9, 1, 0.9, 1}) then
      ImGui.CloseCurrentPopup()
    end
    ImGui.EndPopup()
  end
  HSshowTooltip("Reset the Harmless's Scripts options to default config", "You have to reload the Lua script to see changes!", {1, 0.7, 0.4, 1})
end)

--[[

  HUD Tab

]]--

HudTab:add_imgui(function()
  ImGui.Spacing();ImGui.SeparatorText("On-Screen Clock")
  showTimeTab()
  ImGui.Spacing();ImGui.SeparatorText("Radar Manipulation")
  radarManipulation()
end)

--[[

  Show Local Time -> HUD Tab

]]--

local clockCB = readFromConfig("clockCB")
local showSecondsCB = readFromConfig("showSecondsCB")
local clockTextCB = readFromConfig("clockTextCB")
local clockLocX = readFromConfig("clockLocX")
local clockLocY = readFromConfig("clockLocY")
local clockScale = readFromConfig("clockScale")
local clockColor = readFromConfig("clockColor")
local clockDropShadowCB = readFromConfig("clockDropShadowCB")

function showTimeTab()
  clockCB, clockToggled = HSCheckbox("Show Local Time", clockCB, "clockCB")
  HSshowTooltip("Draws your local time on your screen")
  if clockCB then
    showSecondsCB, showSecondsToggled = HSCheckbox("Show Seconds", showSecondsCB, "showSecondsCB")
    clockTextCB, clockTextToggled = HSCheckbox("Show Text", clockTextCB, "clockTextCB")
    HSshowTooltip("Show the \"Current time:\" text")
    clockLocX, clockLocXUsed = HSSliderFloat("Clock Location X", clockLocX, 0.01, 1, "%.2f", ImGuiSliderFlags.Logarithmic, "clockLocX")
    HSshowTooltip("X (left/right) location of the text")
    clockLocY, clockLocYUsed = HSSliderFloat("Clock Location Y", clockLocY, 0.01, 1, "%.2f", ImGuiSliderFlags.Logarithmic, "clockLocY")
    HSshowTooltip("Y (up/down) location of the text")
    clockScale, clockScaleUsed = HSSliderFloat("Clock Scale", clockScale, 0.1, 1, "%.1f", ImGuiSliderFlags.Logarithmic, "clockScale")
    HSshowTooltip("Scale of the text")
    clockColor, clockColorUsed = HSColorEdit4("Clock Color", clockColor, "clockColor")
    clockDropShadowCB, clockDropShadowToggled = HSCheckbox("Text Drop Shadow", clockDropShadowCB, "clockDropShadowCB")
  end
end

script.register_looped("HS Show Time Loop", function(showTimeLoop)
  if clockCB then
    local timestamp = os.time()
    local date = os.date("*t", timestamp)

    local function formatTimeUnit(timeUnit)
      return timeUnit < 10 and "0" .. timeUnit or timeUnit
    end

    local defaultTime = date.hour .. ":" .. formatTimeUnit(date.min)
    local seconds = formatTimeUnit(date.sec)

    local clockText = defaultTime
    if showSecondsCB then
      clockText = clockText .. ":" .. seconds
    end
    if clockTextCB then
      clockText = "Current time: " .. clockText
    end

    if clockDropShadowCB then
      dropShadow = 1
    elseif not clockDropShadowCB then
      dropShadow = 0
    end
    local clockColorR = math.floor(clockColor[1] * 255)
    local clockColorG = math.floor(clockColor[2] * 255)
    local clockColorB = math.floor(clockColor[3] * 255)
    local clockColorA = math.floor(clockColor[4] * 255)

    HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING")
    HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(clockText)
    HUD.SET_TEXT_JUSTIFICATION(0)
    HUD.SET_TEXT_SCALE(clockScale, clockScale)
    HUD.SET_TEXT_DROPSHADOW(dropShadow, 1, 1, 1, 1)
    HUD.SET_TEXT_COLOUR(clockColorR, clockColorG, clockColorB, clockColorA)
    HUD.END_TEXT_COMMAND_DISPLAY_TEXT(clockLocX, clockLocY, 0)
  end
end)

--[[

  Radar Manipulations -> HUD Tab

]]--

local expandedRadarCB = readFromConfig("expandedRadarCB")
local radarZoom = readFromConfig("radarZoom")

function radarManipulation()
  expandedRadarCB, expandedRadarToggled = HSCheckbox("Show Expanded Radar", expandedRadarCB, "expandedRadarCB")
  HSshowTooltip(ReverseBoolToStatus(expandedRadarCB) .. " expanded radar on your screen", "Currently not working in Online", {1,0.7,0.4,1})
  if expandedRadarCB then -- moved the execution here and removed the wile loop because it was causing the script to immediately hide the minimap in GTA online whenever it runs. we don't need to loop it because it's basically an on/off switch depending on the state of the checkbox.
    -- if not CFX.IS_BIGMAP_ACTIVE() then -- afaik, this is required to set the expanded radar in online but we can't run CFX natives. Not entirely sure though!
      HUD.SET_BIGMAP_ACTIVE(true, false) -- still not working in online though but it works fine in SP.
    -- end
  else
    HUD.SET_BIGMAP_ACTIVE(false, false)
  end
  radarZoom, radarZoomUsed = HSSliderInt("Radar Zoom", radarZoom, 0, 1400, "radarZoom")
  HSshowTooltip("This will change the zoom of the radar\n0 = Default\n1400 = Max Zoomed Out")
  if radarZoom then
    HUD.SET_RADAR_ZOOM(radarZoom)
  end
end
--[[

  NPC ESP -> HS Settings

  Credits to @pierrelasse in GitHub for helping me with this :D

]]--

ESPTab:add_imgui(function()
  npcEspTab()
end)

local npcEspCB = readFromConfig("npcEspCB")
local npcEspShowEnemCB = readFromConfig("npcEspShowEnemCB")
local npcEspBoxCB = readFromConfig("npcEspBoxCB")
local npcEspTracerCB = readFromConfig("npCEspTracerCB")
local npcEspLosCB = readFromConfig("npcEspLosCB")
local npcEspDistance = readFromConfig("npcEspDistance")
local npcEspColor = readFromConfig("npcEspColor")

function npcEspTab()
  npcEspCB, npcEspToggled = HSCheckbox("NPC ESP", npcEspCB, "npcEspCB")
  npcEspShowEnemCB, npcEspShowEnemCBToggled = HSCheckbox("Show Only Enemies", npcEspShowEnemCB, "npcEspShowEnemCB")
  npcEspBoxCB, npcEspBoxCBToggled = HSCheckbox("NPC ESP Box", npcEspBoxCB, "npcEspBoxCB")
  HSshowTooltip("Draws a box around NPCs")
  npcEspTracerCB, npcEspTracerCBToggled = HSCheckbox("NPC ESP Tracer", npcEspTracerCB, "npCEspTracerCB")
  HSshowTooltip("Draws a line from the NPC to the player")
  npcEspDistance, npcEspDistanceUsed = HSSliderFloat("ESP Max Distance", npcEspDistance, 0, 150, "%.0f", ImGuiSliderFlags.Logarithmic, "npcEspDistance")
  HSshowTooltip("Sets max distance for how far the NPC ESP will work")
  npcEspColor, npcEspColorUsed = HSColorEdit4("ESP Color", npcEspColor, "npcEspColor")
end

function calculate_distance(x1, y1, z1, x2, y2, z2)
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

function draw_rect(x, y, width, height)
  GRAPHICS.DRAW_RECT(x, y, width, height, math.floor(npcEspColor[1] * 255), math.floor(npcEspColor[2] * 255), math.floor(npcEspColor[3] * 255), math.floor(npcEspColor[4] * 255), false)
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
          local pedEnemy = PED.IS_PED_IN_COMBAT(ped, player)
          if pedEnemy then
            HSConsoleLogDebug("Ped is an enemy: " .. tostring(pedEnemy))
          end
          local success, screenX, screenY = GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(pedCoords.x, pedCoords.y, pedCoords.z, 0.0, 0.0)
          HSConsoleLogDebug("Screen coords: " .. tostring(screenX) .. ", " .. tostring(screenY))
          if success and npcEspBoxCB and (not npcEspShowEnemCB or pedEnemy) then
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
            draw_rect(screenX, screenY - boxSize / 2  + 0.001, boxSize / 4, thickness) -- Top
            draw_rect(screenX, screenY + boxSize / 2  - 0.001, boxSize / 4, thickness) -- Bottom
            draw_rect(screenX - boxSize / 8, screenY, thickness, boxSize - 2 * thickness) -- Left
            draw_rect(screenX + boxSize / 8, screenY, thickness, boxSize - 2 * thickness) -- Right
          end
          -- Draw a line from the player to the NPC if the tracer is enabled
          if success and npcEspTracerCB and (not npcEspShowEnemCB or pedEnemy) then
            GRAPHICS.DRAW_LINE(playerCoords.x, playerCoords.y, playerCoords.z, pedCoords.x, pedCoords.y, pedCoords.z, math.floor(npcEspColor[1] * 255), math.floor(npcEspColor[2] * 255), math.floor(npcEspColor[3] * 255), math.floor(npcEspColor[4] * 255))
          end
        end
      end
    end
  end
end)

--[[

  Experimentals (WIP) -> HS Settings

]]--
ExperimentalTab:add_imgui(function()
  ImGui.Text("Experimental features that I'm working on and may add to this tab.")
  ImGui.Text("Feel free to test them out and give any feedback.")
end)
--[[

  Harmless's Scripts Functions

]]--

-- HS Notification Functions
function HSNotification(message)
  if notifyCB then
    gui.show_message("Harmless's Scripts", message)
  end
end

function HSWarnNotif(message)
  if notifyCB and warnNotifyCB then
    gui.show_warning("Harmless's Scripts", message)
  end
end

function HSErrorNotif(message)
  if notifyCB and errorNotifyCB then
    gui.show_error("Harmless's Scripts", message)
  end
end

-- HS Console Log Functions
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


--[[

  HS Tooltip Functions

--]]

hoverStartTimes = {}
showTooltips = {}

local commonFlags = ImGuiWindowFlags.NoTitleBar | ImGuiWindowFlags.NoMove | ImGuiWindowFlags.NoScrollbar | ImGuiWindowFlags.NoScrollWithMouse | ImGuiWindowFlags.NoInputs
local fullScreenFlags = ImGuiWindowFlags.NoResize | ImGuiWindowFlags.NoBackground | commonFlags
local toolTipBaseFlags = ImGuiWindowFlags.AlwaysAutoResize | commonFlags
local commonChildFlags = ImGuiWindowFlags.AlwaysAutoResize | ImGuiWindowFlags.NoBackground | commonFlags

local function GetFullScreenResolution(screenWidth, screenHeight, offsetY)
  ImGui.Begin("", fullScreenFlags)
  ImGui.SetNextWindowPos(screenWidth / 2, screenHeight - offsetY, ImGuiCond.Always, 0.5, 1.0)
end

local function displayToolTipWindow(winWidth, winHeight)
  ImGui.BeginChild("Tooltip Window", winWidth, winHeight, false, commonChildFlags)
end

local function displayHotkeyInfo()
  ImGui.SameLine(); ImGui.Dummy(10, 1)
  ImGui.SameLine(); ImGui.BeginGroup()
  ImGui.Text("Set Hotkey: F12 (WIP)")
  ImGui.Text("Current Hotkey: None (WIP)")
  ImGui.EndGroup()
  ImGui.End()
end

-- Chekcs if the item is hovered and if it's hovered for 200ms, it will show the tooltip
local function hoverCheck(message)
  if ImGui.IsItemHovered() then
    hoverStartTimes[message] = hoverStartTimes[message] or os.clock()
    if os.clock() - hoverStartTimes[message] >= toolTipDelay then
      showTooltips[message] = true
      hoverStartTimes[message] = nil
    end
  else
    hoverStartTimes[message] = nil
    showTooltips[message] = false
  end
end

-- Show (?) icon
-- Credits: @Deadlineem and Extras Addon for the tooltip icon idea "(?)"
local function displayToolTipIcon(smColor)
  if toolTipIconCB then
    ImGui.SameLine()
    if smColor then
      ImGui.PushStyleColor(ImGuiCol.Text, smColor[1], smColor[2], smColor[3], smColor[4] - 0.4)
      ImGui.Text("(?)") 
      ImGui.PopStyleColor()
    elseif not smColor then
      ImGui.PushStyleColor(ImGuiCol.Text, 0.4, 0.4, 0.4, 1)
      ImGui.Text("(?)")
      ImGui.PopStyleColor()
    end
  end
end

function HSshowTooltip(message, specialMessage, smColor)
  -- Display Tooltip Icon depending on the settings
  if toolTipIconOnlyCB then
    displayToolTipIcon(smColor)
    hoverCheck(message)
  elseif not toolTipIconOnlyCB then
    hoverCheck(message)
    displayToolTipIcon(smColor)
  end

  -- Show Tooltip
  if showTooltips[message] then
    if toolTipCB and not toolTipV2CB then
      if specialMessage then
        message = message .. "\n\n Note: " .. specialMessage
        ImGui.SetTooltip(message)
      else
        ImGui.SetTooltip(message)
      end
    -- Show Tooltip V2
    elseif toolTipV2CB and not toolTipCB then
      local screenWidth, screenHeight = GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(0,0)
      GetFullScreenResolution(screenWidth, screenHeight, 100)
      if ImGui.Begin("ToolTip Base", toolTipBaseFlags) then
        local textWidth = 300
        local _, textHeight = ImGui.CalcTextSize(message, false, textWidth)
        if specialMessage and smColor then
          local _, specialtextHeight = ImGui.CalcTextSize(specialMessage, false, textWidth)
          local totalHeight = textHeight + (specialtextHeight + 10)
          displayToolTipWindow(textWidth, totalHeight)
          ImGui.TextWrapped(message)
          ImGui.PushStyleColor(ImGuiCol.Text, smColor[1], smColor[2], smColor[3], smColor[4])
          ImGui.TextWrapped(specialMessage)
          ImGui.PopStyleColor()
        elseif specialMessage and not smColor then
          local _, specialtextHeight = ImGui.CalcTextSize(specialMessage, false, textWidth)
          local totalHeight = textHeight + (specialtextHeight + 10)
          displayToolTipWindow(textWidth, totalHeight)
          ImGui.TextWrapped(message)
          ImGui.TextWrapped(specialMessage)
        elseif not specialMessage and not smColor then
          displayToolTipWindow(textWidth, textHeight)
          ImGui.TextWrapped(message)
        end
        ImGui.EndChild()
        displayHotkeyInfo()
      end
      ImGui.End()
    end
  end
end

--[[

  HS Utility Functions

]]--
function BoolToStatus(boolValue) -- Convert bool true/false to Enable/Disable
  return boolValue and "Enable" or "Disable"
end

function ReverseBoolToStatus(boolValue) -- Reverse bool convert true/false to Disable/Enable
  return boolValue and "Disable" or "Enable"
end

function GetScreenResolution()
  local screenWidth, screenHeight = GRAPHICS.GET_ACTUAL_SCREEN_RESOLUTION(0,0)
  return screenWidth, screenHeight
end

function GetScreenCenter()
  local screenWidth, screenHeight = GetScreenResolution()
  local centerX = screenWidth / 2
  local centerY = screenHeight / 2
  return centerX, centerY
end

--[[

  Custom ImGui Item Functions

]]--
function HSCheckbox(label, bool_variable, item_tag)
  local newBool, toggled = ImGui.Checkbox(label, bool_variable)
  if toggled then
    bool_variable = newBool
    saveToConfig(item_tag, bool_variable)
  end
  return bool_variable, toggled
end

function HSSliderFloat(label, float_variable, min, max, format, flags, item_tag)
  local newFloat, used = ImGui.SliderFloat(label, float_variable, min, max, format, flags)
  if used then
    float_variable = newFloat
    saveToConfig(item_tag, float_variable)
  end
  return float_variable, used
end

function HSSliderInt(label, int_variable, min, max, item_tag)
  local newInt, used = ImGui.SliderInt(label, int_variable, min, max)
  if used then
    int_variable = newInt
    saveToConfig(item_tag, int_variable)
  end
  return int_variable, used
end

function HSColorEdit4(label, color_variable, item_tag)
  local newColor, used = ImGui.ColorEdit4(label, color_variable)
  if used then
    color_variable = newColor
    saveToConfig(item_tag, color_variable)
  end
  return color_variable, used
end

function HSCombobox(label, current_item, items, items_count, popup_max_height_in_items)--, item_tag)
  if items ~= nil and #items == items_count then
    newInt, used = ImGui.Combo(label, current_item, items, items_count, popup_max_height_in_items)
  end
  if used then
    current_item = newInt
    --saveToConfig(item_tag, current_item) -- Not needed for comboboxes really, or for the purpose I'm currently using it for.
  end
  return current_item, used
end

function HSButton(label, txtColor)
  ImGui.PushStyleColor(ImGuiCol.Text, txtColor[1], txtColor[2], txtColor[3], txtColor[4])
  local used = ImGui.Button(label)
  ImGui.PopStyleColor()
  return used
end