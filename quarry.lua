local settingsTable = {
  xMax=32, zMax=32, slotChest=16, slotCobble=1, slotFuel=15
}

local action = {preMove=0, moveX=1, moveY=2, dig=10, empty=11}

local stateTable = {
  xPos=1, xTarget=settingsTable["xMax"], xDirection=1,
  zPos=settingsTable["zMax"], zTarget=1, zDirection=-1,
  action = action["moveX"]
}


function saveTable(table, name)
  local file = fs.open(name,"w")
  file.write(textutils.serialize(table))
  file.close()
end

function loadTable(name)
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
  local moves = {
    up        = function (x) return turtle.up() end,
    down      = function (x) return turtle.down() end,
    forward   = function (x) return turtle.forward() end,
    back      = function (x) return turtle.back() end,
    turnLeft  = function (x) return turtle.turnLeft() end,
    turnRight = function (x) return turtle.turnRight() end
  }
  local stateChange = {
    up        = function (x) stateTable["zPos"] += 1 end,
    down      = function (x) stateTable["zPos"] -= 1 end,
    forward   = function (x) stateTable["xPos"] += 1 end,
    back      = function (x) stateTable["xPos"] -= 1 end,
    turnLeft  = function (x) stateTable["turnedLeft"] = 1 end,
    turnRight = function (x) stateTable["turnedRight"] = 1 end
  }
  local previousState = stateTable
  
  stateChange["direction"]()
  saveState()
  if not moves["direction"]() then
    stateTable = previousState
    saveState()
  end
end


fuction handleInventory()
  #if cobble>60
    #drop cobble-1
  #Check space
    #if full
      #place chest, move stuff
    #Pick up chest
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


while true do
  -- #############       Move
  if stateTable["action"] = action["preMove"] then
    
    if stateTeble["xPos"] != (1 or settingsTable["xMax"]) then
      stateTable["action"] = action["moveX"]
    end
    
    if stateTable["xPos"] == (1 or settingsTable[]) then
      stateTable["action"] = action["moveY"]
    end

  end
  
  
  if stateTable["action"] = action["moveX"] then
    if stateTable["xPos"] == 1 or stateTable["xPos"] == settingsTable["xMax"]) then
      stateTable["action"] = action["moveY"]
    else
      safeMove("forward")
    end
    saveState()
  end


  if stateTable["action"] = action["moveY"] then
    if stateTable["xPos"] == 1 then
      safeMove("turnRight")
      turtle.dig()
      safeMove("forward")
      safeMove("turnLeft")
    elseif stateTable["xPos"] == settingsTable["xMax"] then
      safeMove("turnLeft")
      turtle.dig()
      safeMove("forward")
      safeMove("turnRight")
    end
  end
  
  
  -- #############       Dig
  
  if stateTable["action"] = 10 then
    if stateTable["zPos"] == 32 then
      local previousSlot = turtle.getSelectedSlot()
      turtle.select(settingsTable["slotCobble"])
      turtle.placeUp()
      turtle.select(previousSlot)
    else
      turtle.digUp()
    end
    turtle.dig()
    turtle.digForward()
    stateTable["action"] = action["empty"]
    saveState()
  end
  
  
  -- #############       Empty Inventory
  
  if stateTable["action"] = action["empty"] then
  
    stateTable["action"] = action["preMove"]
    saveState()
  end
end



