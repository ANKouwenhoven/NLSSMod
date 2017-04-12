----------------------------------------
-- Madrinas Coffee
-- All Natural
----------------------------------------
-- 1 Luck up
-- 0.2 Shotspeed up
-- 0.2 Speed up
----------------------------------------

local madrinas = {
  itemID = Isaac.GetItemIdByName("Madrinas Coffee");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/madrinas.anm2");
  hasItem = nil;
}

function madrinas:cacheUpdate(player, cacheFlag)
  addFlatStat(madrinas.itemID, 1, CacheFlag.CACHE_LUCK, cacheFlag);
  addFlatStat(madrinas.itemID, 0.2, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  addFlatStat(madrinas.itemID, 0.2, CacheFlag.CACHE_SPEED, cacheFlag);
end

function madrinas:onPlayerUpdate(player)  
	if player:HasCollectible(madrinas.itemID) then
		if madrinas.hasItem == false then
			player:AddNullCostume(madrinas.costumeID)
			madrinas.hasItem = true
		end
	end
end

function madrinas:onGameStart()
  madrinas.hasItem = false
  SpawnPreviewItem(madrinas.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, madrinas.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, madrinas.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, madrinas.cacheUpdate)