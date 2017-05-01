----------------------------------------
-- BE ADVISED!!! Pill
----------------------------------------
-- Max speed for the rest of the room.
----------------------------------------

local beAdvised = {
  pillID = Isaac.GetPillEffectByName("BE ADVISED!!!");
  speedDiff = 0;
  isActive = 0;
}

-- beAdvised pill
function beAdvised:takePill(pill)
  local player = Isaac.GetPlayer(0);
  beAdvised.speedDiff = 2 - player.MoveSpeed;
  beAdvised.isActive = 1;
  player:AddCacheFlags(CacheFlag.CACHE_SPEED);
  player:EvaluateItems();
end

function beAdvised:onCacheUpdate(player, cacheFlag)
  if cacheFlag == CacheFlag.CACHE_SPEED then
    player.MoveSpeed = player.MoveSpeed + beAdvised.speedDiff * beAdvised.isActive;
  end
end

function beAdvised:onNewRoom()
  local player = Isaac.GetPlayer(0);
  beAdvised.isActive = 0;
  
  player:AddCacheFlags(CacheFlag.CACHE_SPEED);
  player:EvaluateItems();
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, beAdvised.onNewRoom)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, beAdvised.onCacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_USE_PILL, beAdvised.takePill, beAdvised.pillID)