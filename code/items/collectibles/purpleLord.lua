----------------------------------------
-- Purple Lord
-- True Ascension
----------------------------------------
-- 1.5 Damage multiplier
-- Tears turn purple
-- Piercing tears
-- Tears leave a purple creep that
-- damages enemies
----------------------------------------

local purpleLord = {
  itemID = Isaac.GetItemIdByName("Purple Lord");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/purpleLord.anm2");
  hasItem = nil;
}

function purpleLord:cacheUpdate(player, cacheFlag)
  addFlatStat(purpleLord.itemID, 0.5 * player.Damage, CacheFlag.CACHE_DAMAGE, cacheFlag);
end

function purpleLord:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		purpleLord.hasItem = false
    SpawnPreviewItem(purpleLord.itemID, 170, 200)
	end
  
	if player:HasCollectible(purpleLord.itemID) then
		if purpleLord.hasItem == false then
			player:AddNullCostume(purpleLord.costumeID)
			purpleLord.hasItem = true
		end
	end
  
  if player:HasCollectible(purpleLord.itemID) then
    local entities = Isaac.GetRoomEntities()
    
    for i = 1, #entities do
      local tear = entities[i]:ToTear()
      if tear ~= nil then			
        if tear.FrameCount == 0 then
          tear.Color = Color(1, 1, 1, 1, 50, -100, 250);
          tear.TearFlags = 1<<1;
        elseif math.random(1, 3) == 3 then
          local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, tear.Position, Vector(0, 0), player);
          creep:SetColor(Color(1, 1, 1, 1, 0, -150, 200), 0, 0, false, false)
        end
      end
		end
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, purpleLord.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, purpleLord.cacheUpdate)