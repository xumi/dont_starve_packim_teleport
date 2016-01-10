function onPackimFishboneInit(inst)
    inst:AddComponent("packim_teleporter")
end

AddPrefabPostInit("packim_fishbone", onPackimFishboneInit)
 