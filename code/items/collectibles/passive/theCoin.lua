----------------------------------------
-- The Coin
-- It's mine!
----------------------------------------
-- 0.25 Damage up for every enemy in
-- the room.
----------------------------------------

local theCoin = {
  itemID = Isaac.GetItemIdByName("The Coin");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/theCoin.anm2");
  hasItem = nil;
  currentEnemies = 0;
}

function theCoin:cacheUpdate(player, cacheFlag)
  addFlatStat(theCoin.itemID, 0.25 * theCoin.currentEnemies, CacheFlag.CACHE_DAMAGE, cacheFlag);
end

function theCoin:onPlayerUpdate(player)  
	if player:HasCollectible(theCoin.itemID) then
		if theCoin.hasItem == false then
			player:AddNullCostume(theCoin.costumeID)
			theCoin.hasItem = true
		end
	end
  
  local entities = Isaac.GetRoomEntities();
  theCoin.currentEnemies = 0;
  
  for i = 1, #entities do
    entity = entities[i]
    if entity:IsVulnerableEnemy() and entity:IsActiveEnemy(false) then
			theCoin.currentEnemies = theCoin.currentEnemies + 1;
		end
	end
  
  player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
  player:EvaluateItems();
end

function theCoin:onGameStart()
  theCoin.hasItem = false
  SpawnPreviewItem(theCoin.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, theCoin.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, theCoin.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, theCoin.cacheUpdate)