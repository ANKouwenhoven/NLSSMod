----------------------------------------
-- Minus Realm
-- Far below the grinders
----------------------------------------
-- Turns current room to the minus realm
-- All entities turn completely black.
-- Triple damage, 2.5 x shotspeed,
-- 0.3 x speed.
-- Enemies freeze at first, then are
-- Slowed. Spritescales go wack.
----------------------------------------

local minusRealm = {
  itemID = Isaac.GetItemIdByName("Minus Realm");
  currentColor = nil;
  activeRoom = false;
}

function minusRealm:useItem()
  local player = Isaac.GetPlayer(0)
  Game():GetRoom():TurnGold();
  minusRealm.activeRoom = true;
  
  player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
  player:AddCacheFlags(CacheFlag.CACHE_SPEED);
  player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED);
  player.CanFly = true;
  player:EvaluateItems();
  
  local entities = Isaac.GetRoomEntities();
  for i = 1, #entities do
    if entities[i]:IsVulnerableEnemy() then
      entities[i]:AddFreeze(EntityRef(player), 250, false);
      entities[i]:AddSlowing(EntityRef(player), 1000, 0.1, Color(0, 0, 0, 1, 0, 0, 0))
      entities[i].Color = Color(0, 0, 0, 1, 0, 0, 0);
    end
  end
  minusRealm.currentColor = player.Color;
  player.Color = Color(0, 0, 0, 1, 0, 0, 0);
  
  return true;
end

function minusRealm:cacheUpdate(player, cacheFlag)
  if minusRealm.activeRoom then
    addFlatStat(minusRealm.itemID, player.Damage * 2, CacheFlag.CACHE_DAMAGE, cacheFlag);
  end
  
  if minusRealm.activeRoom then
    addFlatStat(minusRealm.itemID, player.ShotSpeed * 1.5, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  end
  
  if minusRealm.activeRoom then
    addFlatStat(minusRealm.itemID, -0.7 * player.MoveSpeed, CacheFlag.CACHE_SPEED, cacheFlag);
  end
end

function minusRealm:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
    SpawnPreviewItem(minusRealm.itemID, 420, 350)
	end
  
  if minusRealm.activeRoom then
    local entities = Isaac.GetRoomEntities();
    for i = 1, #entities do
      entities[i].Color = Color(0, 0, 0, 1, 0, 0, 0);
      if Game():GetFrameCount() % 10 == 0 then
        entities[i].SpriteScale = Vector(math.random() * 2, math.random() * 2);
      end
    end
  end
  
  if Game():GetRoom():GetFrameCount() == 1 then
    if minusRealm.currentColor ~= nil then
      player.Color = minusRealm.currentColor;
      minusRealm.currentColor = nil;
    end
    
    minusRealm.activeRoom = false;
    
    if player:HasCollectible(minusRealm.itemID) then
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
      player:AddCacheFlags(CacheFlag.CACHE_SPEED);
      player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED);
      player.CanFly = false;
      player:EvaluateItems();
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, minusRealm.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, minusRealm.useItem, minusRealm.itemID)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, minusRealm.cacheUpdate)