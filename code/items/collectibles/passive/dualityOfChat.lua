----------------------------------------
-- Duality of Chat
-- M A L F | J O S H | D N A
----------------------------------------
-- Stats up that switches every room.
----------------------------------------

local dualityOfChat = {
  itemID = Isaac.GetItemIdByName("Duality of Chat");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/dualityOfChat.anm2");
  hasItem = nil;
  buffType = 1;
  buffDMG = 0;
  buffSHTSPD = 0;
  buffSPD = 0;
  buffTRS = 0;
}

function dualityOfChat:cacheUpdate(player, cacheFlag)
  addFlatStat(dualityOfChat.itemID, 2 * dualityOfChat.buffDMG, CacheFlag.CACHE_DAMAGE, cacheFlag);
  addFlatStat(dualityOfChat.itemID, 0.6 * dualityOfChat.buffSHTSPD, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  addFlatStat(dualityOfChat.itemID, 0.5 * dualityOfChat.buffSPD, CacheFlag.CACHE_SPEED, cacheFlag);
  addFlatStat(dualityOfChat.itemID, 0.4 * player.MaxFireDelay * dualityOfChat.buffTRS, CacheFlag.CACHE_FIREDELAY, cacheFlag);
end

function dualityOfChat:onPlayerUpdate(player)  
	if player:HasCollectible(dualityOfChat.itemID) then
		if dualityOfChat.hasItem == false then
			--player:AddNullCostume(dualityOfChat.costumeID)
			dualityOfChat.hasItem = true
		end
	end
end

function dualityOfChat:onNewRoom()
  local player = Isaac.GetPlayer(0);
  dualityOfChat.buffType = dualityOfChat.buffType + 1;
  
  dualityOfChat.buffDMG = 0;
  dualityOfChat.buffSHTSPD = 0;
  dualityOfChat.buffSPD = 0;
  dualityOfChat.buffTRS = 0;
  
  if dualityOfChat.buffType > 4 then
    dualityOfChat.buffType = 1;
  end
  
  if dualityOfChat.buffType == 1 then
    dualityOfChat.buffDMG = 1;
  elseif dualityOfChat.buffType == 2 then
    dualityOfChat.buffSHTSPD = 1;
  elseif dualityOfChat.buffType == 3 then
    dualityOfChat.buffSPD = 1;
  elseif dualityOfChat.buffType == 4 then
    dualityOfChat.buffTRS = 1;
  end
  
  player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
  player:AddCacheFlags(CacheFlag.CACHE_SPEED)
  player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
  player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
  player:EvaluateItems();
end

function dualityOfChat:onGameStart()
  dualityOfChat.hasItem = false
  dualityOfChat.buffType = math.random(4);
  SpawnPreviewItem(dualityOfChat.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, dualityOfChat.onNewRoom)
NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, dualityOfChat.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, dualityOfChat.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, dualityOfChat.cacheUpdate)