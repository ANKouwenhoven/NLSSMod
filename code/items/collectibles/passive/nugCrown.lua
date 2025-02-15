----------------------------------------
-- Nug King's Crown
-- Eternal Glory
----------------------------------------
-- 3 Damage up
-- 2 Luck up
-- 0.3 Speed up
----------------------------------------

local nugCrown = {
  itemID = Isaac.GetItemIdByName("Nug King's Crown");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/nugCrown.anm2");
  hasItem = nil;
}

-- Used by Chicken Nugget to fetch this item
function getCrown()
  return nugCrown.itemID;
end

function nugCrown:cacheUpdate(player, cacheFlag)
  addFlatStat(nugCrown.itemID, 3, CacheFlag.CACHE_DAMAGE, cacheFlag);
  addFlatStat(nugCrown.itemID, 0.3, CacheFlag.CACHE_SPEED, cacheFlag);
  addFlatStat(nugCrown.itemID, 2, CacheFlag.CACHE_LUCK, cacheFlag);
end

function nugCrown:onPlayerUpdate(player)  
	if player:HasCollectible(nugCrown.itemID) then
		if nugCrown.hasItem == false then
			player:AddNullCostume(nugCrown.costumeID)
			nugCrown.hasItem = true;
		end
	end
end

function nugCrown:onGameStart()
  nugCrown.hasItem = false
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, nugCrown.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, nugCrown.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, nugCrown.cacheUpdate)