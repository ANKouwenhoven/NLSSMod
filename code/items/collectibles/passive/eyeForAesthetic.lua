----------------------------------------
-- Eye for Aesthetic
-- Zany Tears
----------------------------------------
-- 4 tears up
-- Fired tears have a small spread
-- Fired tears have a random shotspeed
-- Fired tears have a random color
----------------------------------------

local eyeForA = {
  itemID = Isaac.GetItemIdByName("Eye for Aesthetic");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/eyeForAesthetic.anm2");
  hasItem = nil;
  laserColor = Color(1, 1, 1, 1, 0, 0, 0);
}

function eyeForA:cacheUpdate(player, cacheFlag)
  addFlatStat(eyeForA.itemID, player.MaxFireDelay * 0.5, CacheFlag.CACHE_FIREDELAY, cacheFlag);
end

function aestheticEffect(player)
  local entities = Isaac.GetRoomEntities();
  for i = 1, #entities do

    -- Normal tears
    if entities[i].Type == EntityType.ENTITY_TEAR and entities[i].FrameCount == 0 and entities[i].SpawnerType == EntityType.ENTITY_PLAYER then
      entities[i].Color = Color(math.random(), math.random(), math.random(), 1, 0, 0, 0);
      entities[i].Velocity = entities[i].Velocity:Rotated(clampedRandom(-12, 12))
      entities[i].Velocity = entities[i].Velocity * clampedRandom(0.6, 1.4);
    end
    
    -- Brimstone / Technology synergy
    if player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) or player:HasWeaponType(WeaponType.WEAPON_LASER) then
      if entities[i]:ToLaser() ~= nil and entities[i].SpawnerType == EntityType.ENTITY_PLAYER and clampedRandom(1, 2) > 1.5 then
        entities[i]:ToLaser().Angle = entities[i]:ToLaser().Angle + clampedRandom(1.5, 3) * randomSign()
        entities[i].Color = eyeForA.laserColor;
      end
      
      -- Brimstone + Ludovico Technique synergy
      if entities[i]:ToLaser() ~= nil and entities[i].SpawnerType == EntityType.ENTITY_PLAYER and entities[i]:ToLaser():IsCircleLaser() then
        entities[i]:AddVelocity(RandomVector() * clampedRandom(0.5, 1.4))
        entities[i].Color = eyeForA.laserColor;
      end
      
      if Game():GetFrameCount() % 15 == 0 then
        eyeForA.laserColor = Color(math.random(), math.random(), math.random(), 1, math.random(250), math.random(250), math.random(250));
      end
    end
    
    -- Mom's Knife synergy
    if player:HasWeaponType(WeaponType.WEAPON_KNIFE) then
      if entities[i]:ToKnife() ~= nil and lastKnifeFlying == false and entities[i]:ToKnife():IsFlying() == true then
        entities[i]:ToKnife().Rotation = entities[i]:ToKnife().Rotation + clampedRandom(-14, 14)
      end
      if entities[i]:ToKnife() ~= nil then
        lastKnifeFlying = entities[i]:ToKnife():IsFlying()
      end
    end
    
    -- Ludovico Technique synergy
    if player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
      if entities[i].Type == EntityType.ENTITY_TEAR then
        entities[i]:AddVelocity(RandomVector() * clampedRandom(0.3, 1.2))
        if Game():GetFrameCount() % 30 == 0 then
          entities[i].Color = Color(math.random(), math.random(), math.random(), 1, 0, 0, 0);
        end
      end
    end
    
    -- Dr Fetus synergy
    if player:HasWeaponType(WeaponType.WEAPON_BOMBS) then
      if entities[i].Type == EntityType.ENTITY_BOMBDROP then 
        if entities[i]:ToBomb().IsFetus == true and entities[i].FrameCount == 0 then
          entities[i].Velocity = entities[i].Velocity:Rotated(clampedRandom(-12, 12))
        end
      end
    end
	end
end

function eyeForA:onPlayerUpdate(player)  
	if player:HasCollectible(eyeForA.itemID) then
		if eyeForA.hasItem == false then
			player:AddNullCostume(eyeForA.costumeID)
			eyeForA.hasItem = true
		end
    
    aestheticEffect(player);
	end
end

function eyeForA:onGameStart()
  eyeForA.hasItem = false
  SpawnPreviewItem(eyeForA.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, eyeForA.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, eyeForA.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, eyeForA.cacheUpdate)