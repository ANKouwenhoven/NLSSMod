----------------------------------------
-- Mind Flood
-- Hands for hair
----------------------------------------
-- Damage and Speed up and
-- leave a creep whenever an enemy gets
-- too close to the player.
----------------------------------------

local mindFlood = {
  itemID = Isaac.GetItemIdByName("Mind Flood");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/mindFlood.anm2");
  hasItem = nil;
  floodBuff = 0;
}

function mindFlood:cacheUpdate(player, cacheFlag)
  if floodBuff ~= nil then
    addFlatStat(mindFlood.itemID, 3 * floodBuff, CacheFlag.CACHE_DAMAGE, cacheFlag);
    addFlatStat(mindFlood.itemID, 0.6 * floodBuff, CacheFlag.CACHE_SPEED, cacheFlag);
  end
end

function mindFlood:onPlayerUpdate(player)  
	if player:HasCollectible(mindFlood.itemID) then
		if mindFlood.hasItem == false then
			player:AddNullCostume(mindFlood.costumeID)
			mindFlood.hasItem = true
		end
	end
  
  if player:HasCollectible(mindFlood.itemID) then
    local entities = Isaac.GetRoomEntities();
    
    for i = 1, #entities do
      local enemy = entities[i]
      if enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy(false) then
        if player.Position:Distance(enemy.Position, player.Position) < 150 then
          if math.random(1, 4) == 4 then
            creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, 0, player.Position, Vector(0, 0), player);
            creep:SetColor(Color(0, 0, 1, 1, 100, 150, 250), 0, 0, false, false)
          end
          floodBuff = round((150 - player.Position:Distance(enemy.Position, player.Position)) / 150, 1);
          break;
        else
          floodBuff = 0;
        end
      end
    end
  end
  
  player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
  player:AddCacheFlags(CacheFlag.CACHE_SPEED);
  player:EvaluateItems();
end

function mindFlood:onGameStart()
  mindFlood.hasItem = false
  SpawnPreviewItem(mindFlood.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mindFlood.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, mindFlood.cacheUpdate)