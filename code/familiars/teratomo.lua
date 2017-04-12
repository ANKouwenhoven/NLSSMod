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
  
  local player = Isaac.GetPlayer(0);
  local entities = Isaac.GetRoomEntities();
  
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      if familiar.Position:Distance(enemy.Position, familiar.Position) < 25 and math.random(1, 4) == 1 then
        local newTomo = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, teratomo.variantID, 0, familiar.Position, Vector(0, 0), player)
      end
    end
  end
end

function teratomo:onNewRoom()
  local player = Isaac.GetPlayer(0);
  player:CheckFamiliar(teratomo.variantID, player:GetCollectibleNum(teratomo.itemID), RNG())
end

function teratomo:onGameStart()
  SpawnPreviewItem(teratomo.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, teratomo.onNewRoom)
NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, teratomo.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, teratomo.cacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, teratomo.initFamiliar, teratomo.variantID)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, teratomo.familiarUpdate, teratomo.variantID)