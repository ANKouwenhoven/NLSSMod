----------------------------------------
-- Gungeon Master
-- Bullet Tears
----------------------------------------
-- Damage + Shotspeed up
-- If shot kills an enemy, shot
-- continues with 1.5x damage
----------------------------------------

local gungeonMaster = {
  itemID = Isaac.GetItemIdByName("Gungeon Master");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/gungeonMaster.anm2");
  tearVariantID = Isaac.GetEntityVariantByName("gungeonBullet");
  hasItem = nil;
  radius = 50;
  scale = 1;
  subtype = 0;
  tearList = {};
}

function gungeonMaster:onCacheUpdate(player, cacheFlag)
  addFlatStat(gungeonMaster.itemID, 2, CacheFlag.CACHE_DAMAGE, cacheFlag);
  addFlatStat(gungeonMaster.itemID, 1, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
end

function gungeonMaster:onPlayerUpdate(player)  
	if player:HasCollectible(gungeonMaster.itemID) then
		if gungeonMaster.hasItem == false then
			player:AddNullCostume(gungeonMaster.costumeID)
			gungeonMaster.hasItem = true
		end
	end
  
  if player:HasCollectible(gungeonMaster.itemID) then
    local trackingTable = {};
		index, value = next(gungeonMaster.tearList, nil)
    
		while index do
      trackingTable[index] = value;
	    index, value = next(gungeonMaster.tearList, index);
    end
    
    local entities = Isaac.GetRoomEntities();
    
		for i = 1, #entities do
      local entity = entities[i];
      
			if entity.Type == EntityType.ENTITY_TEAR then
				trackingTable[entity.Index] = nil;
			end
      
			if entity.Type == EntityType.ENTITY_TEAR and entity.Variant ~= gungeonMaster.tearVariantID then
        if entity.FrameCount == 0 then
          local tear = entity:ToTear();
          
          tear:ChangeVariant(gungeonMaster.tearVariantID);
          gungeonMaster.tearList[entity.Index] = entity;
          tear.TearFlags = tear.TearFlags + 1<<9;
        end
			end
      
      if entity.Type == EntityType.ENTITY_TEAR and entity.Variant == gungeonMaster.tearVariantID then
        local sprite = entity:GetSprite();
        sprite.Rotation = entity.Velocity:GetAngleDegrees()
        
        for j = 1, #entities do
          if entities[j]:IsVulnerableEnemy() and (entity.Position - entities[j].Position):Length() < 20 and not sprite:IsPlaying("Broken") then
            sprite:Play("Broken", true);
            entity:ToTear().CollisionDamage = player.Damage * 1.5;
          end
        end
      end
		end
    
    for key, value in pairs(trackingTable) do
			if value ~= nil then
        local crumble = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, value.Position, Vector(0, 0), player)
        crumble:SetColor(Color(1, 0.8, 0, 1, 0, 0, 0), 0, 0, false, false)
				gungeonMaster.tearList[key] = nil;
			end
    end
  end
end

function gungeonMaster:onGameStart()
  gungeonMaster.hasItem = false
  SpawnPreviewItem(gungeonMaster.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, gungeonMaster.onCacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, gungeonMaster.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, gungeonMaster.onPlayerUpdate)