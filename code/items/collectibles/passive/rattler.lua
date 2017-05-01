----------------------------------------
-- Rattler
-- !!! DELTTAR M'I !!!
----------------------------------------
-- 3 Damage up
-- 0.2 Shotspeed down
-- 0.15 Speed down
----------------------------------------

local rattler = {
  itemID = Isaac.GetItemIdByName("Rattler");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/rattler.anm2");
  statusEntity = Isaac.GetEntityTypeByName("rattlerStatus");
  statusVariant = Isaac.GetEntityVariantByName("rattlerStatus");
  status = nil;
  hasItem = nil;
  buffLevel = 0;
}

function rattler:cacheUpdate(player, cacheFlag)
  addFlatStat(rattler.itemID, 0.5 + rattler.buffLevel, CacheFlag.CACHE_DAMAGE, cacheFlag);
  addFlatStat(rattler.itemID, -0.2 + rattler.buffLevel * 0.3, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  addFlatStat(rattler.itemID, -0.15 + rattler.buffLevel * 0.3, CacheFlag.CACHE_SPEED, cacheFlag);
end

function rattler:onDamage()
  local player = Isaac.GetPlayer(0);
  if player:HasCollectible(rattler.itemID) then
    if rattler.buffLevel < 3 then
      rattler.buffLevel = rattler.buffLevel + 1;
      readjustStats();
      
      if rattler.buffLevel == 1 then
        rattler.status = Isaac.Spawn(rattler.statusEntity, rattler.statusVariant, 0,
          player.Position - Vector(0, player.Size * player.SizeMulti.Y + 48), Vector(0,0), player);
        
        rattler.status.RenderZOffset = 99999;
        rattler.status:ToEffect():FollowParent(player);
        local statusSprite = rattler.status:GetSprite();
        statusSprite:Play("Stage1", true);
      elseif rattler.buffLevel == 2 then
        local statusSprite = rattler.status:GetSprite();
        statusSprite:Play("Stage2", true);
      elseif rattler.buffLevel == 3 then
        local statusSprite = rattler.status:GetSprite();
        statusSprite:Play("Stage3", true);
      end
    end
  end
end

function readjustStats()
  local player = Isaac.GetPlayer(0);
  player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
  player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED);
  player:AddCacheFlags(CacheFlag.CACHE_SPEED);
  player:EvaluateItems();
end

function rattler:onNewRoom()
  rattler.buffLevel = 0;
  readjustStats();
end

function rattler:onPlayerUpdate(player)  
	if player:HasCollectible(rattler.itemID) then
		if rattler.hasItem == false then
			player:AddNullCostume(rattler.costumeID)
			rattler.hasItem = true
		end
	end
end

function rattler:onGameStart()
  rattler.hasItem = false
  SpawnPreviewItem(rattler.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, rattler.onNewRoom)
NLSSMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, rattler.onDamage, EntityType.ENTITY_PLAYER)
NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, rattler.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, rattler.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, rattler.cacheUpdate)