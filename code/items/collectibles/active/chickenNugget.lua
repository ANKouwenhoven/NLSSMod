----------------------------------------
-- Chicken Nugget
-- How many can you handle?
----------------------------------------
-- Every time you eat a nugget, gain
-- 0.75 Damage, 1 range but lose
-- 0.10 speed.
-- Spawn the Nug King's Crown when
-- you've eaten more than 10 nuggets.
----------------------------------------

local chickenNugget = {
  itemID = Isaac.GetItemIdByName("Chicken Nugget");
  nugsEaten = 0;
}

function chickenNugget:useItem()
  local player = Isaac.GetPlayer(0)
  chickenNugget.nugsEaten = chickenNugget.nugsEaten + 1;
  
  if player.MoveSpeed > 0.11 then
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    player:AddCacheFlags(CacheFlag.CACHE_RANGE);
    player:AddCacheFlags(CacheFlag.CACHE_SPEED);
    player:EvaluateItems();
  end
  
  if chickenNugget.nugsEaten > 9 then
    local spawnX = player.Position.X + 30;
    local spawnY = player.Position.Y + 30;
    
    if player.Position.X > 400 then
      spawnX = player.Position.X - 30;
    end
    if player.Position.Y > 400 then
      spawnY = player.Position.Y - 30;
    end
    
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, getCrown(), Vector(spawnX, spawnY), Vector(0, 0), nil)
    player:RemoveCollectible(chickenNugget.itemID);
  end
  
  return true;
end

function chickenNugget:cacheUpdate(player, cacheFlag)
  if chickenNugget.nugsEaten > 0 then
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage + 0.75 * chickenNugget.nugsEaten;
    end
    
    if cacheFlag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed = player.MoveSpeed - 0.10 * chickenNugget.nugsEaten;
    end
    
    if cacheFlag == CacheFlag.CACHE_RANGE then
      player.TearHeight = player.TearHeight - 1 * chickenNugget.nugsEaten;
    end
  end
end

function chickenNugget:onGameStart()
  SpawnPreviewItem(chickenNugget.itemID)
  chickenNugget.nugsEaten = 0;
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, chickenNugget.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, chickenNugget.cacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, chickenNugget.useItem, chickenNugget.itemID)