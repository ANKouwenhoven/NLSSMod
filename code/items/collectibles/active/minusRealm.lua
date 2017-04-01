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
  activeRoom = false;
}

function minusRealm:useItem()
  local player = Isaac.GetPlayer(0)
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
      entities[i].Color = Color(0, 0, 0, 1, math.random(255), math.random(255), math.random(255))
    end
  end
  
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
  
  if Game():GetRoom():GetFrameCount() == 0 then    
    minusRealm.activeRoom = false;
    
    if player:HasCollectible(minusRealm.itemID) then
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
      player:AddCacheFlags(CacheFlag.CACHE_SPEED);
      player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED);
      player.CanFly = false;
      player:EvaluateItems();
    end
    
    local entities = Isaac.GetRoomEntities();
    for i = 1, #entities do
      entities[i].Color = Color(1, 1, 1, 1, 0, 0, 0);
    end
  end
  
  if minusRealm.activeRoom then
    local entities = Isaac.GetRoomEntities();
    for i = 1, #entities do
      if Game():GetFrameCount() % 10 == 0 or entities[i].FrameCount == 0 then
        entities[i].Color = Color(0, 0, 0, 1, math.random(255), math.random(255), math.random(255));
        entities[i].SpriteScale = Vector(math.random() * 2, math.random() * 2);
      end
    end
    
    if Game():GetFrameCount() % 30 == 0 then
      Game():GetRoom():SetWallColor(Color(0, 0, 0, 1, math.random(255), math.random(255), math.random(255)));
      Game():GetRoom():SetFloorColor(Color(0, 0, 0, 1, math.random(255), math.random(255), math.random(255)));
    end
    
    Game():Darken(math.abs(math.sin((math.pi / 180) * Game():GetFrameCount() * 2)), 1)
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, minusRealm.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, minusRealm.useItem, minusRealm.itemID)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, minusRealm.cacheUpdate)