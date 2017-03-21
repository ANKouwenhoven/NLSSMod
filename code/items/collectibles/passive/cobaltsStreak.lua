----------------------------------------
-- Cobalt's Streak
-- I never lose!
----------------------------------------
-- 0.25 Damage up for every room
-- cleared without taking damage.
----------------------------------------

local cobaltsStreak = {
  itemID = Isaac.GetItemIdByName("Cobalt's Streak");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/cobalt.anm2");
  hasItem = nil;
  streak = 0;
  roomCleared = false;
}

function cobaltsStreak:cacheUpdate(player, cacheFlag)
  addFlatStat(cobaltsStreak.itemID, 0.25 * cobaltsStreak.streak, CacheFlag.CACHE_DAMAGE, cacheFlag);
end

function cobaltsStreak:streakReset(player_broken, damage_amount, damage_flag, damage_source, invincibility_frames)
  local player = Isaac.GetPlayer(0);
  
  if player:HasCollectible(cobaltsStreak.itemID) then
    cobaltsStreak.streak = 0;
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    player:EvaluateItems();
  end
end

function cobaltsStreak:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		cobaltsStreak.hasItem = false
    SpawnPreviewItem(cobaltsStreak.itemID, 270, 200)
    cobaltsStreak.streak = 0;
    cobaltsStreak.roomCleared = false;
	end
  
	if player:HasCollectible(cobaltsStreak.itemID) then
		if cobaltsStreak.hasItem == false then
			player:AddNullCostume(cobaltsStreak.costumeID)
			cobaltsStreak.hasItem = true
		end
	end
  
  local room = Game():GetRoom();
  
  if not room:IsClear() then
    cobaltsStreak.roomCleared = false;
  end
  
  if cobaltsStreak.roomCleared == false and room:IsClear() and player:HasCollectible(cobaltsStreak.itemID) then
    if cobaltsStreak.streak < 50 then
      cobaltsStreak.streak = cobaltsStreak.streak + 1;
    end
    
    cobaltsStreak.roomCleared = true;
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    player:EvaluateItems();
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, cobaltsStreak.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, cobaltsStreak.cacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, cobaltsStreak.streakReset, EntityType.ENTITY_PLAYER)