----------------------------------------
-- Jar of Jellies
-- It's too hot in here...
----------------------------------------
-- Spawn 2 out of 4 possible Jellies
-- Jellies are randomly chosen and
-- have differing effects.
----------------------------------------

local jellies = {
  itemID = Isaac.GetItemIdByName("Jar of Jellies");
  variantID1 = Isaac.GetEntityVariantByName("jelly1");
  variantID2 = Isaac.GetEntityVariantByName("jelly2");
  variantID3 = Isaac.GetEntityVariantByName("jelly3");
  variantID4 = Isaac.GetEntityVariantByName("jelly4");
  amount = 0;
}

function jellies:cacheUpdate(player, cacheFlag)  
  if cacheFlag == CacheFlag.CACHE_FAMILIARS then
	for i = 1, 2 do
      if jellies.amount < player:GetCollectibleNum(jellies.itemID) * 2 then
        player:CheckFamiliar(randomJelly(), player:GetCollectibleNum(jellies.itemID), RNG())
        jellies.amount = jellies.amount + 1;
      end
    end
  end
end

function jellies:initFamiliar(familiar)
	familiar.IsFollower = true;
end

function jellies:familiarUpdate1(familiar)   
  familiar:FollowParent()
  setOrientation(familiar, true);
end

function jellies:familiarUpdate2(familiar)  
  local player = Isaac.GetPlayer(0);
  familiar:FollowParent()
  
  -- Leaves red creep
  if math.random(10) == 1 then
    creep1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, familiar.Position, Vector(0, 0), player) 
    creep1:SetColor(Color(1, 0, 0, 1, 250, 100, 50), 0, 0, false, false)
  end
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and math.random(10) == 1 then
    creep2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, 0, familiar.Position, Vector(0, 0), player) 
    creep2:SetColor(Color(1, 0, 0, 1, 250, 50, 25), 0, 0, false, false)
  end
  
  setOrientation(familiar, true);
end

function jellies:familiarUpdate3(familiar)
  local entities = Isaac.GetRoomEntities()
  local player = Isaac.GetPlayer(0)
   
  familiar:FollowParent()
  
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      if familiar.Position:Distance(enemy.Position, familiar.Position) < 150 and Game():GetFrameCount() % 30 == 0 then
        local shots = 2;
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
          shots = 4;
        end
        for i = 1, shots do
          local thisTear = player:FireTear(familiar.Position, RandomVector() * math.random(1, 5), false, false, false);
          local currentSprite = thisTear:GetSprite():GetFilename() 
          if currentSprite ~= "gfx/Effects/jellyTear3.anm2" then
            local newTearSprite = thisTear:GetSprite() 
            newTearSprite:Load("gfx/Effects/jellyTear3.anm2", true)	
            newTearSprite:Play("Idle", true)
          end
        end
      end
    end
  end
  
  setOrientation(familiar, true);
end

function jellies:familiarUpdate4(familiar)   
  local player = Isaac.GetPlayer(0)
   
  familiar:FollowParent()
  
  -- Leaves a floating tear in place
  if Game():GetFrameCount() % 30 == 0 then
    
    local tear = player:FireTear(familiar.Position, Vector(0, 0), false, false, false);
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
      tear.CollisionDamage = player.Damage + 10;
    else
	  tear.CollisionDamage = player.Damage + 5;
	end
	
    local currentSprite = tear:GetSprite():GetFilename() ;
    
    if currentSprite ~= "gfx/Effects/jellyTear4.anm2" then
      local newTearSprite = tear:GetSprite() 
      newTearSprite:Load("gfx/Effects/jellyTear4.anm2", true)	
      newTearSprite:Play("Idle", true)
    end
  end
  
  setOrientation(familiar, true);
end

-- Returns a random Jelly to spawn
function randomJelly()
  jellyNum = math.random(1, 4)
  
  if jellyNum == 1 then
    return jellies.variantID1;
  elseif jellyNum == 2 then
    return jellies.variantID2;
  elseif jellyNum == 3 then
    return jellies.variantID3;
  elseif jellyNum == 4 then
    return jellies.variantID4;
  end
end

function jellies:onGameStart()
  jellies.amount = 0;	
  SpawnPreviewItem(jellies.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, jellies.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, jellies.cacheUpdate)

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, jellies.initFamiliar, jellies.variantID1)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, jellies.initFamiliar, jellies.variantID2)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, jellies.initFamiliar, jellies.variantID3)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, jellies.initFamiliar, jellies.variantID4)

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, jellies.familiarUpdate1, jellies.variantID1)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, jellies.familiarUpdate2, jellies.variantID2)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, jellies.familiarUpdate3, jellies.variantID3)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, jellies.familiarUpdate4, jellies.variantID4)