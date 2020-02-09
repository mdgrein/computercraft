local settingsTable = {
  xMax=4, zMax=4, slotChest=16, slotCobble=1, slotFuel=15
}

local action = {preMove=0, moveX=1, moveZ=2, turnStage1=0, turnStage2=0, turnStage3=0, moveY=3, dig=10, empty=11}

local stateTable = {
  xPos=1, xTarget=settingsTable["xMax"], xDirection=1,
  zPos=settingsTable["zMax"], zTarget=1, zDirection=-1,
  turnedLeft=0, turnedRight=0,
  action = action["moveX"]
}


function saveTable(table, name)
  print("Saving " .. name)
  local file = fs.open(name,"w")
  file.write(textutils.serialize(table))
  file.close()
end

function loadTable(name)
  print("Loading " .. name)
  local file = fs.open(name,"r")
  local data = file.readAll()
  file.close()
  return textutils.unserialize(data)
end

function saveSettings()
  saveTable(settingsTable, "settings")
end

function loadSettings()
  settingsTable = loadTable("settings")
end

function saveState()
  saveTable(stateTable, "state")
end

function loadState()
  stateTable = loadTable("state")
end


function safeMove(direction)
  print("Move attempt started")
  print("Direction:" .. direction)
  local moves = {
    up        = function (x) return turtle.up() end,
    down      = function (x) return turtle.down() end,
    forward   = function (x) return turtle.forward() end,
    back      = function (x) return turtle.back() end,
    turnLeft  = function (x) return turtle.turnLeft() end,
    turnRight = function (x) return turtle.turnRight() end
  }
  --[[
  local stateChange = {
    up        = function (x) stateTable["zPos"] = 1 end,
    down      = function (x) stateTable["zPos"] = 1 end,
    forward   = function (x) stateTable["xPos"] = 1 end,
    back      = function (x) stateTable["xPos"] = 1 end,
    turnLeft  = function (x) stateTable["turnedLeft"] = 1 end,
    turnRight = function (x) stateTable["turnedRight"] = 1 end
  }
  --]]
  
  local previousState = stateTable
  if direction == "forward" then
    stateTable["xPos"] = stateTable["xPos"] + stateTable["xDirection"]
  elseif direction =="back" then
    stateTable["xPos"] = stateTable["xPos"] + (stateTable["xDirection"] * -1)
  end
  if direction == "up" then
    stateTable["zPos"] = stateTable["zPos"] + 1
  elseif direction == "down" then
    stateTable["zPos"] = stateTable["zPos"] - 1
  end
  
  if moves["direction"]() then
    print("Move attempt success")
    saveState()
  else
    print("Move attempt failed")
    stateTable = previousState
    saveState()
  end
  
end


function handleInventory()
--[[
  if cobble>60
    drop cobble-1
  Check space
    if full
      place chest, move stuff
    Pick up chest
--]]
end


function handleFuel()
  if not turtleNeedFuel then
    print('Fuel level:' .. turtle.getFuelLevel())
    if turtle.getFuelLevel() < turtle.getFuelLimit() / 3 then
      for slot=1,15,1 do
        turtle.select(slot)
        while turtle.refuel(0) and turtle.getFuelLevel() < turtle.getFuelLimit() do
          if not (slot == 15 and turtle.getItemCount() == 1) then
            turtle.refuel(1)
          else
            break
          end
        end
      end
    end
    print('Fuel level:' .. turtle.getFuelLevel())
  end
end


--[[
#################       Actual quarry code
--]]

turtle.turnRight()

while true do
  print("Current action:" .. stateTable["action"])
  -- #############       Move
  if stateTable["action"] == action["preMove"] then
    
    if stateTeble["xPos"] ~= 1 and stateTeble["xPos"] ~= settingsTable["xMax"] then
      stateTable["action"] = action["moveX"]
    end
    
    if stateTable["xPos"] == 1 or stateTeble["xPos"] == settingsTable["xMax"] then
      stateTable["action"] = action["moveZ"]
    end

  end
  
  
  if stateTable["action"] == action["moveX"] then
    if stateTable["xPos"] == 1 or stateTable["xPos"] == settingsTable["xMax"] then
      stateTable["action"] = action["preMove"]
      saveState()
    else
      stateTable["action"] = action["dig"]
      safeMove("forward")
    end
  end
  
  
  if stateTable["action"] == action["moveZ"] then
    stateTable["action"] = action["preMove"]
    saveState()
  end


  if stateTable["action"] == action["moveY"] then
    if stateTable["turnStage1"] == 0 then
      stateTable["turnStage1"] = 1
      if stateTable["xPos"] == 1 then
        safeMove("turnRight")
      elseif stateTable["xPos"] == settingsTable["xMax"] then
        safeMove("turnLeft")
      end
    end
    
    if stateTable["turnStage1"] == 1 and stateTable["turnStage2"] == 0 then
      turtle.dig()
      stateTable["turnStage2"] = 1
      safeMove("forward")
    end
    
    if stateTable["turnStage1"] == 1 and stateTable["turnStage2"] == 1 and stateTable["turnStage2"] == 0 then
      stateTable["turnStage3"] = 1
      if stateTable["xPos"] == 1 then
        safeMove("turnRight")
      elseif stateTable["xPos"] == settingsTable["xMax"] then
        safeMove("turnLeft")
      end
    end
    
    if stateTable["turnStage1"] == 1 and stateTable["turnStage2"] == 1 and stateTable["turnStage2"] == 1 then
      stateTable["action"] = action["preMove"]
    end
  end
  
  
  -- #############       Dig
  
  if stateTable["action"] == 10 then
    if stateTable["zPos"] == 32 then
      local previousSlot = turtle.getSelectedSlot()
      turtle.select(settingsTable["slotCobble"])
      turtle.placeUp()
      turtle.select(previousSlot)
    else
      turtle.digUp()
    end
    turtle.dig()
    turtle.digDown()
    stateTable["action"] = action["empty"]
    saveState()
  end
  
  
  -- #############       Empty Inventory
  
  if stateTable["action"] == action["empty"] then
    stateTable["action"] = action["preMove"]
    saveState()
  end
end
