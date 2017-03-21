----------------------------------------
-- Teratomo
-- What's the matter buddy?
----------------------------------------
-- Bounces around the room dealing
-- damage to enemies. Has a chance to
-- split into 2 when touching an enemy.
----------------------------------------

local teratomo = {
  itemID = Isaac.GetItemIdByName("Teratomo");
  variantID = Isaac.GetEntityVariantByName("teratomo");
}

function teratomo:cacheUpdate(player, cacheFlag)
  if cacheFlag == CacheFlag.CACHE_FAMILIARS then
	player:CheckFamiliar(teratomo.variantID, player:GetCollectibleNum(teratomo.itemID), RNG())
  end
end

function teratomo:initFamiliar(familiar)
  -- Nothing here, this only to make the spawn go through correctly
end

function teratomo:familiarUpdate(familiar)
  familiar:MoveDiagonally(1);
  
  local entities = Isaac.GetRoomEntities();
  
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      if familiar.Position:Distance(enemy.Position, familiar.Position) < 25 and math.random(1, 4) == 1 then
        newTomo = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, familiarList.teratomo, 0, familiar.Position, Vector(0, 0), player)
      end
    end
  end
end

function teratomo:onPlayerUpdate(player)
  if Game():GetFrameCount() == 1 then
	  SpawnPreviewItem(teratomo.itemID, 370, 150)
  end
	
  if Game():GetRoom():GetFrameCount() == 1 then
	if player:HasCollectible(teratomo.itemID) then
      for i = 1, #entities do
        local entity = entities[i]
        if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == teratomo.familiarID then
          entity:Remove();
        end
      end

	  newTomo = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, teratomo.familiarID, 0, player.Position, RandomVector(), player)
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, teratomo.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, teratomo.cacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, teratomo.initFamiliar, teratomo.variantID)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, teratomo.familiarUpdate, teratomo.variantID)