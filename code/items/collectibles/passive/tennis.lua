----------------------------------------
-- Tennis
-- King of context
----------------------------------------
-- 0.5 Damage up
-- 0.25 Shotspeed up
-- 0.15 Speed up
-- 2 Range up
----------------------------------------

local tennis = {
  itemID = Isaac.GetItemIdByName("Tennis");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/tennis.anm2");
  hasItem = nil;
}

function tennis:cacheUpdate(player, cacheFlag)
  addFlatStat(tennis.itemID, 0.5, CacheFlag.CACHE_DAMAGE, cacheFlag);
  addFlatStat(tennis.itemID, 0.25, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  addFlatStat(tennis.itemID, 0.15, CacheFlag.CACHE_SPEED, cacheFlag);
  addFlatStat(tennis.itemID, 2, CacheFlag.CACHE_RANGE, cacheFlag);
end

function tennis:onPlayerUpdate(player)  
	if player:HasCollectible(tennis.itemID) then
		if tennis.hasItem == false then
			player:AddNullCostume(tennis.costumeID)
			tennis.hasItem = true
		end
	end
end

function tennis:onGameStart()
  tennis.hasItem = false
  SpawnPreviewItem(tennis.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, tennis.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, tennis.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, tennis.cacheUpdate)