----------------------------------------
-- Book of Bolegda
-- Ancient Jamaican Rituals
----------------------------------------
-- Removes a heart container and
-- gives a damage buff every use.
----------------------------------------

local bookOfBolegda = {
  itemID = Isaac.GetItemIdByName("Book of Bolegda");
  buffCount = 0;
}

function bookOfBolegda:useItem()
  local player = Isaac.GetPlayer(0);
  
  if player:GetMaxHearts() < 4 then
    return false;
  end
  
  player:AddMaxHearts(-2);
  bookOfBolegda.buffCount = bookOfBolegda.buffCount + 1;
  player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
  player:EvaluateItems();
  return true;
end

function bookOfBolegda:cacheUpdate(player, cacheFlag)
  if cacheFlag == CacheFlag.CACHE_DAMAGE then
    player.Damage = player.Damage + 3 * bookOfBolegda.buffCount;
  end
end

function bookOfBolegda:onGameStart(player)
  SpawnPreviewItem(bookOfBolegda.itemID)
  bookOfBolegda.isActive = false;
  bookOfBolegda.buffCount = 0;
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, bookOfBolegda.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, bookOfBolegda.useItem, bookOfBolegda.itemID)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, bookOfBolegda.cacheUpdate)