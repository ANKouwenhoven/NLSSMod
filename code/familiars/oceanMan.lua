----------------------------------------
-- Ocean Man
-- Take him by the hand
----------------------------------------
-- Bounces around the room with an aura
-- That grants Damage, Range and Speed
-- when stood in it.
----------------------------------------

local oceanMan = {
  itemID = Isaac.GetItemIdByName("Ocean Man");
  variantID = Isaac.GetEntityVariantByName("oceanMan");
  auraID = Isaac.GetEntityTypeByName("oceanWhirl");
  
  aura = nil;
  inAura = false;
}

function oceanMan:cacheUpdate(player, cacheFlag)  
  if cacheFlag == CacheFlag.CACHE_FAMILIARS then
	player:CheckFamiliar(oceanMan.variantID, player:GetCollectibleNum(oceanMan.itemID), RNG())
  end
  
  if oceanMan.inAura then
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
      addFlatStat(oceanMan.itemID, 3, CacheFlag.CACHE_DAMAGE, cacheFlag);
      addFlatStat(oceanMan.itemID, 3, CacheFlag.CACHE_FIREDELAY, cacheFlag);
      addFlatStat(oceanMan.itemID, 5, CacheFlag.CACHE_RANGE, cacheFlag);
      addFlatStat(oceanMan.itemID, 0.4, CacheFlag.CACHE_SPEED, cacheFlag);
    else
      addFlatStat(oceanMan.itemID, 2, CacheFlag.CACHE_DAMAGE, cacheFlag);
      addFlatStat(oceanMan.itemID, 2, CacheFlag.CACHE_FIREDELAY, cacheFlag);
      addFlatStat(oceanMan.itemID, 3, CacheFlag.CACHE_RANGE, cacheFlag);
      addFlatStat(oceanMan.itemID, 0.2, CacheFlag.CACHE_SPEED, cacheFlag);
    end
  end
end

function oceanMan:initFamiliar(familiar)
  -- Nothing at the moment, this function is only here to make the spawn go through.
end

function oceanMan:familiarUpdate(familiar)
  familiar:MoveDiagonally(1);
  
  local player = Isaac.GetPlayer(0)
  local range = 120;
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
    range = 150;
  end
  
  if familiar.Position:Distance(player.Position, familiar.Position) < range then
    oceanMan.inAura = true;
  else
    oceanMan.inAura = false;
  end
  
  if oceanMan.aura == nil then
    oceanMan.aura = Isaac.Spawn(oceanMan.auraID, 1010, 0, familiar.Position, Vector(0, 0), player);
  else
    oceanMan.aura.Position = familiar.Position;
    oceanMan.aura.RenderZOffset = -999;
    oceanMan.aura.Velocity = familiar.Velocity;
  end
  
  player:AddCacheFlags(CacheFlag.CACHE_RANGE);
  player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
  player:AddCacheFlags(CacheFlag.CACHE_SPEED);
  player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY);
  player:EvaluateItems();
end

function oceanMan:onGameStart()
  SpawnPreviewItem(oceanMan.itemID)	
  oceanMan.aura = nil;
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, oceanMan.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, oceanMan.cacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, oceanMan.initFamiliar, oceanMan.variantID)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, oceanMan.familiarUpdate, oceanMan.variantID)