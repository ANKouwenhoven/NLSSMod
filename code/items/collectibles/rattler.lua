----------------------------------------
-- Rattler
-- !!! DELTTAR M'I !!!
----------------------------------------
-- 3 Damage up
-- 0.2 Shotspeed down
-- 0.15 Speed down
----------------------------------------

local rattler = {
  itemID = Isaac.GetItemIdByName("Rattler");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/rattler.anm2");
  hasItem = nil;
}

function rattler:cacheUpdate(player, cacheFlag)
  addFlatStat(rattler.itemID, 3, CacheFlag.CACHE_DAMAGE, cacheFlag);
  addFlatStat(rattler.itemID, -0.2, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  addFlatStat(rattler.itemID, -0.15, CacheFlag.CACHE_SPEED, cacheFlag);
end

function rattler:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		rattler.hasItem = false
    SpawnPreviewItem(rattler.itemID, 470, 350)
	end
  
	if player:HasCollectible(rattler.itemID) then
		if rattler.hasItem == false then
			player:AddNullCostume(rattler.costumeID)
			rattler.hasItem = true
		end
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, rattler.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, rattler.cacheUpdate)