----------------------------------------
-- Virtual Bart
-- The only game you need
----------------------------------------
-- Stats up that switches every room.
----------------------------------------

local virtualBart = {
  itemID = Isaac.GetItemIdByName("Virtual Bart");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/virtualBart.anm2");
  hasItem = nil;
  buffType = 1;
  buffDMG = 0;
  buffSHTSPD = 0;
  buffSPD = 0;
  buffTRS = 0;
  buffALL = 0;
  buffNONE = 0;
}

function virtualBart:cacheUpdate(player, cacheFlag)
  addFlatStat(virtualBart.itemID, 2 * virtualBart.buffDMG, CacheFlag.CACHE_DAMAGE, cacheFlag);
  addFlatStat(virtualBart.itemID, 0.6 * virtualBart.buffSHTSPD, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  addFlatStat(virtualBart.itemID, 0.5 * virtualBart.buffSPD, CacheFlag.CACHE_SPEED, cacheFlag);
  addFlatStat(virtualBart.itemID, 0.4 * player.MaxFireDelay * virtualBart.buffTRS, CacheFlag.CACHE_FIREDELAY, cacheFlag);
  
  addFlatStat(virtualBart.itemID, 0.4 * virtualBart.buffALL, CacheFlag.CACHE_DAMAGE, cacheFlag);
  addFlatStat(virtualBart.itemID, 0.2 * virtualBart.buffALL, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  addFlatStat(virtualBart.itemID, 0.3 * virtualBart.buffALL, CacheFlag.CACHE_SPEED, cacheFlag);
  addFlatStat(virtualBart.itemID, 0.2 * player.MaxFireDelay * virtualBart.buffALL, CacheFlag.CACHE_FIREDELAY, cacheFlag);
  
  addFlatStat(virtualBart.itemID, -0.5 * virtualBart.buffNONE, CacheFlag.CACHE_DAMAGE, cacheFlag);
  addFlatStat(virtualBart.itemID, -0.3 * virtualBart.buffNONE, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  addFlatStat(virtualBart.itemID, -0.3 * virtualBart.buffNONE, CacheFlag.CACHE_SPEED, cacheFlag);
  addFlatStat(virtualBart.itemID, -0.2 * player.MaxFireDelay * virtualBart.buffNONE, CacheFlag.CACHE_FIREDELAY, cacheFlag);
end

function virtualBart:onPlayerUpdate(player)  
	if player:HasCollectible(virtualBart.itemID) then
		if virtualBart.hasItem == false then
			player:AddNullCostume(virtualBart.costumeID)
			virtualBart.hasItem = true
		end
	end
end

function virtualBart:onNewRoom()
  local player = Isaac.GetPlayer(0);
  virtualBart.buffType = math.random(6);
  
  virtualBart.buffDMG = 0;
  virtualBart.buffSHTSPD = 0;
  virtualBart.buffSPD = 0;
  virtualBart.buffTRS = 0;
  virtualBart.buffALL = 0;
  virtualBart.buffNONE = 0;
  
  if virtualBart.buffType == 1 then
    virtualBart.buffDMG = 1;
  elseif virtualBart.buffType == 2 then
    virtualBart.buffSHTSPD = 1;
  elseif virtualBart.buffType == 3 then
    virtualBart.buffSPD = 1;
  elseif virtualBart.buffType == 4 then
    virtualBart.buffTRS = 1;
  elseif virtualBart.buffType == 5 then
    virtualBart.buffALL = 1;
  elseif virtualBart.buffType == 6 then
    virtualBart.buffNONE = 1;
  end
  
  player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
  player:AddCacheFlags(CacheFlag.CACHE_SPEED)
  player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
  player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
  player:EvaluateItems();
end

function virtualBart:onGameStart()
  virtualBart.hasItem = false
  virtualBart.buffType = math.random(4);
  SpawnPreviewItem(virtualBart.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, virtualBart.onNewRoom)
NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, virtualBart.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, virtualBart.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, virtualBart.cacheUpdate)