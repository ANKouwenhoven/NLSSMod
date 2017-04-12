----------------------------------------
-- Twitchy Chatter
-- Strength in numbers
----------------------------------------
-- Spawns little chatters in combat
-- Every chatter picked up grants 0.5
-- damage for the rest of the room.
----------------------------------------

local twitchyChatter = {
  itemID = Isaac.GetItemIdByName("Twitchy Chatter");
  variantID = Isaac.GetEntityVariantByName("chatter");
  
  chatterSpawn = nil;
  spawnDelay = 20;
  activeRoom = nil;
  animationMode = 0;
  buffCount = 0;
}

function twitchyChatter:cacheUpdate(player, cacheFlag)
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
    addFlatStat(twitchyChatter.itemID, 0.75 * twitchyChatter.buffCount, CacheFlag.CACHE_DAMAGE, cacheFlag);
  else
    addFlatStat(twitchyChatter.itemID, 0.5 * twitchyChatter.buffCount, CacheFlag.CACHE_DAMAGE, cacheFlag);
  end
end

function chatterUpdate()
  local player = Isaac.GetPlayer(0);
  local room = Game():GetRoom();
	local pos;
	local sprite;

  if (twitchyChatter.chatterSpawn == nil) then
		if (CheckForEnemies()) then
			twitchyChatter.spawnDelay = twitchyChatter.spawnDelay - 1;

			if (twitchyChatter.spawnDelay <= 0) then
				pos = room:GetGridPosition(room:GetGridIndex(Isaac:GetRandomPosition())) 
				pos = room:FindFreeTilePosition(pos, 100) 
				twitchyChatter.chatterSpawn = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, twitchyChatter.variantID, 0, pos, Vector(0, 0), player)
        twitchyChatter.animationMode = 0;
				twitchyChatter.activeRoom = Game():GetLevel():GetCurrentRoomIndex()
			end
      
		else
			twitchyChatter.spawnDelay = 10
		end
	end
  
	if twitchyChatter.chatterSpawn ~= nil then
    twitchyChatter.spawnDelay = twitchyChatter.spawnDelay - 1

    if twitchyChatter.animationMode == 0 then
      sprite = twitchyChatter.chatterSpawn:GetSprite()
      if (sprite:GetFrame() >= 5) then
        twitchyChatter.animationMode = 1
        sprite:SetAnimation("Idle")
        sprite:Play("Idle", true)
        twitchyChatter.spawnDelay = 200;
      end
    end
  
    if twitchyChatter.animationMode == 1 then
      if (twitchyChatter.chatterSpawn.Position:Distance(player.Position, twitchyChatter.chatterSpawn.Position) < 25) or (twitchyChatter.spawnDelay <= 0) or (CheckForEnemies() == false) then
        if twitchyChatter.chatterSpawn.Position:Distance(player.Position, twitchyChatter.chatterSpawn.Position) < 25 then
          twitchyChatter.buffCount = twitchyChatter.buffCount + 1;
          player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
          player:EvaluateItems()
        end
        sprite = twitchyChatter.chatterSpawn:GetSprite()
        sprite:SetAnimation("Hide")
        sprite:Play("Hide", true)
        twitchyChatter.animationMode = 3;
      end
    end
    
    if (Game():GetLevel():GetCurrentRoomIndex() ~= twitchyChatter.activeRoom)
    or (twitchyChatter.animationMode == 3 and twitchyChatter.chatterSpawn:GetSprite():IsFinished("Hide")) then
      twitchyChatter.chatterSpawn:Remove()
      twitchyChatter.chatterSpawn = nil
      twitchyChatter.spawnDelay = 10;
    end
	end
end

function twitchyChatter:onPlayerUpdate(player)  
  if player:HasCollectible(twitchyChatter.itemID) then
    chatterUpdate();
  end
end

function twitchyChatter:onNewRoom()
  local player = Isaac.GetPlayer(0);
  
  if player:HasCollectible(twitchyChatter.itemID) then
    twitchyChatter.buffCount = 0;
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems();
  end
end

function twitchyChatter:onGameStart()
  SpawnPreviewItem(twitchyChatter.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, twitchyChatter.onNewRoom)
NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, twitchyChatter.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, twitchyChatter.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, twitchyChatter.cacheUpdate)