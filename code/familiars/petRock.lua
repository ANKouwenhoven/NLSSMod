----------------------------------------
-- Pet Rock
-- Golden Touch
----------------------------------------
-- 1 Luck up
-- Summons a Pet Rock familiar that
-- follows the player and turns enemies
-- gold on collision.
----------------------------------------

local petRock = {
  itemID = Isaac.GetItemIdByName("Pet Rock");
  variantID = Isaac.GetEntityVariantByName("petRock");
}

function petRock:cacheUpdate(player, cacheFlag)
  addFlatStat(petRock.itemID, 1, CacheFlag.CACHE_LUCK, cacheFlag);
  
  if cacheFlag == CacheFlag.CACHE_FAMILIARS then
	player:CheckFamiliar(petRock.variantID, player:GetCollectibleNum(petRock.itemID), RNG())
  end
end

function petRock:initFamiliar(familiar)
	familiar.IsFollower = true;
end

function petRock:familiarUpdate(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
   
  familiar:FollowParent()
    
  -- Midas freezes all enemies that "collide" with pet rock
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      if familiar.Position:Distance(enemy.Position, familiar.Position) < 15 then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
          enemy:AddMidasFreeze(EntityRef(player), 120);
        else
          enemy:AddMidasFreeze(EntityRef(player), 60);
        end
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GOLD_PARTICLE, 0, enemy.Position, Vector(0, 0), enemy);
      end
    end
  end
  
  setOrientation(familiar, false);
end

function petRock:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		SpawnPreviewItem(petRock.itemID, 370, 300)
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, petRock.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, petRock.cacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, petRock.initFamiliar, petRock.variantID)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, petRock.familiarUpdate, petRock.variantID)