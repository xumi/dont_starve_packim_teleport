local function teleportPackimTo(inst)

  -- We check if we have a valid instance
  if not inst then
    return false
  end
  
  -- We find Packim
  local packim   = TheSim:FindFirstEntityWithTag("packim")

  -- We find the position of the destination
  local x,y,z    = inst.Transform:GetWorldPosition()

  -- If Packim is dead
  if not packim then
    local deadFX = SpawnPrefab("smoke_out")
    deadFX.Transform:SetPosition(x,y,z)
    return false
  end

  -- Create a small FX where Packim is before being teleported
  local originFX = SpawnPrefab("small_puff")
  originFX.Transform:SetPosition(packim.Transform:GetWorldPosition())

  -- Teleport Packim to the instance
  packim.Transform:SetPosition(x,y,z)

  -- Create a small FX where Packim is being teleported
  local destinationFX = SpawnPrefab("small_puff")
  destinationFX.Transform:SetScale(2,2,2)
  destinationFX.Transform:SetPosition(x,y,z)
  -- Add this one too, why not!
  destinationFX = SpawnPrefab("sparklefx")
  destinationFX.Transform:SetPosition(x,y,z)

end

local OnRefuseItem = function()
  -- We make the character talk (sound and animation)
  GetPlayer().sg:GoToState("talk")
  -- We display the text (should be translated eventually)
  GetPlayer().components.talker:Say("Not fishy enough!")
end

local OnAcceptItem = function()
  -- We teleport Packim to the Fishbone
  teleportPackimTo( TheSim:FindFirstEntityWithTag("packim_fishbone") )
end

local checkOffering = function(item)
  -- The Fishbone only accepts Fish, Tropical Fish and Swordfish
  return (item.prefab == "fish")  or (item.prefab == "tropical_fish") or (item.prefab == "swordfish")
end

local PackimTeleporterComponent = Class(function(self, inst)
  -- We add a new component to the Fishbone
  inst:AddComponent("trader")
  -- Here we define the rules for good trade
  inst.components.trader:SetAcceptTest(function(inst, item)
    -- If we have a valid item (some kind of good fish)
    local validOffering = checkOffering(item)
    -- If Packim is somewhere in the world (ie. not dead)
    local packim = TheSim:FindFirstEntityWithTag("packim")
    -- Should be both true to have a valid trade
    return packim and validOffering
  end)

  -- What should happen when the player gives a good item (some kind of fish)
  inst.components.trader.onaccept = OnAcceptItem
  -- What should happen when the player gives an irrelevant item
  inst.components.trader.onrefuse = OnRefuseItem

  -- Every seconds or so
  inst:DoPeriodicTask(1, function()
    -- We find Packim in the world
    local packim = TheSim:FindFirstEntityWithTag("packim")
    -- If Packim is available (Alive!)
    if packim then
      -- We enable the trade ability
      inst.components.trader:Enable()
    -- If Packim is dead :'(
    else
      -- We disable the trade ability
      inst.components.trader:Disable()
    end
  end)

end)

return PackimTeleporterComponent