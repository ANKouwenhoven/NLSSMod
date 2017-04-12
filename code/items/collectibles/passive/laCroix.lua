----------------------------------------
-- LaCroix
-- Nothing Artificial
----------------------------------------
-- 2 Tears up
-- 1 Hp up
----------------------------------------

local laCroix = {
  itemID = Isaac.GetItemIdByName("LaCroix");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/laCroix.anm2");
  hasItem = nil;
}

function laCroix:cacheUpdate(player, cacheFlag)
  addFlatStat(laCroix.itemID, player.MaxFireDelay * 0.3, CacheFlag.CACHE_FIREDELAY, cacheFlag);
end

function laCroix:onPlayerUpdate(player)  
	if player:HasCollectible(laCroix.itemID) then
		if laCroix.hasItem == false then
			player:AddNullCostume(laCroix.costumeID)
			laCroix.hasItem = true
		end
	end
end

function laCroix:onGameStart()
  laCroix.hasItem = false
  SpawnPreviewItem(laCroix.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, laCroix.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, laCroix.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, laCroix.cacheUpdate)