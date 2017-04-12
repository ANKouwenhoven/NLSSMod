----------------------------------------
-- The Stapler
-- For nuts only
----------------------------------------
-- Damages the player for 1/2 heart
-- Maxes out tears for the rest of
-- the room.
----------------------------------------

local stapler = {
  itemID = Isaac.GetItemIdByName("The Stapler");
  isActive = false;
  removedDelay = 0;
}

function staplerActive()
  return stapler.isActive;
end

function stapler:useItem()
  local player = Isaac.GetPlayer(0)
  stapler.removedDelay = player.MaxFireDelay - 1;
  stapler.isActive = true;
  player:TakeDamage(1, 0, EntityRef(player), 0);
  player.MaxFireDelay = 1;
  
  return true;
end

function stapler:onPlayerUpdate(player)  
  if stapler.isActive then
    player.MaxFireDelay = 1;
  end
end

function stapler:onGameStart()
  SpawnPreviewItem(stapler.itemID)
  stapler.isActive = false;
end

function stapler:onNewRoom()
  if stapler.isActive == true then
    local player = Isaac.GetPlayer(0);
    player.MaxFireDelay = player.MaxFireDelay + stapler.removedDelay;
    stapler.isActive = false;
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
    player:EvaluateItems();
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, stapler.onNewRoom)
NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, stapler.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, stapler.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, stapler.useItem, stapler.itemID)