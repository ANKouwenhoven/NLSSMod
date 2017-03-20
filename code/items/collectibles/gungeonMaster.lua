----------------------------------------
-- Gungeon Master
-- Bullet Tears
----------------------------------------
-- 2 Damage up
-- 1.5 Shotspeed up
-- Tear sprite turns to Bullet
----------------------------------------

local gungeonMaster = {
  itemID = Isaac.GetItemIdByName("Gungeon Master");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/gungeonMaster.anm2");
  tearSprite = "gfx/effects/gungeonBullet.png";
  hasItem = nil;
}

function gungeonMaster:cacheUpdate(player, cacheFlag)
  addFlatStat(gungeonMaster.itemID, 2, CacheFlag.CACHE_DAMAGE, cacheFlag);
  addFlatStat(gungeonMaster.itemID, 1.5, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
end

function gungeonMaster:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		gungeonMaster.hasItem = false
    SpawnPreviewItem(gungeonMaster.itemID, 320, 300)
	end
  
	if player:HasCollectible(gungeonMaster.itemID) then
		if gungeonMaster.hasItem == false then
			player:AddNullCostume(gungeonMaster.costumeID)
			gungeonMaster.hasItem = true
		end
	end
  
  local entities = Isaac.GetRoomEntities()
  
  for i = 1, #entities do
    local tear = entities[i]:ToTear()
    if tear ~= nil then
      if player:HasCollectible(gungeonMaster.itemID) then
        local sprite = tear:GetSprite()
        if tear.FrameCount == 0 then
          sprite:Load("gfx/Effects/gungeonBullet.anm2", true)	
          sprite:Play("Idle", true)
        end
        sprite.Rotation = tear.Velocity:GetAngleDegrees()
      end
    end
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, gungeonMaster.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, gungeonMaster.cacheUpdate)