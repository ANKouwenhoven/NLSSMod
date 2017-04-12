----------------------------------------
-- Scumbo
-- Scumbo want bad damage!
----------------------------------------
-- Follows the player, feeding off
-- damage that the player receives.
-- Comes in multiple stages.
-- Stage 1: Does nothing
-- Stage 2: Yells "Bad Damage" whenever
-- the player gets hit, which damages
-- and confuses enemies around it.
-- Stage 3: Has a 25% chance to negate
-- damage, spawning a lucky penny when
-- it does so.
----------------------------------------

local scumbo = {
  itemID = Isaac.GetItemIdByName("Scumbo");
  variantID = Isaac.GetEntityVariantByName("scumbo");
  textID = Isaac.GetEntityTypeByName("badDamage");
  damageCounter = 0;
  damageText = nil;
  damageFrames = 0;
  counterDelay = 0;
  scumboFlag = false;
  scumboStage = 1;
}

function scumbo:cacheUpdate(player, cacheFlag)  
  if cacheFlag == CacheFlag.CACHE_FAMILIARS then
    player:CheckFamiliar(scumbo.variantID, player:GetCollectibleNum(scumbo.itemID), RNG())
  end
end

function scumbo:onDamage(player_x, damage_amount, damage_flag, damage_source, invincibility_frames)
  local player = Isaac.GetPlayer(0);
  
  if not player:HasCollectible(scumbo.itemID) then
    return;
  end
    
  local takenDamage = nil;
  scumbo.damageCounter = scumbo.damageCounter + 1;
  
  if scumbo.damageCounter > 10 then
    scumbo.scumboStage = 3;
  elseif scumbo.damageCounter > 3 then
    scumbo.scumboStage = 2;
  end
  
  scumbo.scumboFlag = true;

  if scumbo.scumboStage == 3 then
    local entities = Isaac.GetRoomEntities();
    local player = Isaac.GetPlayer(0);
    
    if math.random(1, 4) == 1 then
      local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY, player.Position, Vector(0, 0), enemy);
      takenDamage = false;
    end
  end
  
  return takenDamage;
end

function scumbo:initFamiliar(familiar)
	familiar.IsFollower = true;
end

function scumbo:familiarUpdate(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
   
  familiar:FollowParent()
  
  if scumbo.scumboStage == 2 then
    sprite = familiar:GetSprite();
    sprite:SetAnimation("Stage2")
    sprite:Play("Stage2", true)
  end
  
  if scumbo.scumboStage == 3 then
    sprite = familiar:GetSprite();
    sprite:SetAnimation("Stage3")
    sprite:Play("Stage3", true)
  end
  
  if scumbo.scumboStage == 2 then
    if scumbo.scumboFlag == true then
      if scumbo.damageText == nil then
        scumbo.damageText = Isaac.Spawn(scumbo.textID, 1015, 0, familiar.Position, Vector(0, 0), player);
        scumbo.scumboFlag = false;
      end
    end
    if scumbo.damageText ~= nil then
      scumbo.damageText.Position = scumbo.damageText.Position + Vector(0, -2);
      scumbo.damageText.Velocity = Vector(0, 0);
      scumbo.damageText.RenderZOffset = 999;
      scumbo.counterDelay = scumbo.counterDelay + 1;
      local entities = Isaac.GetRoomEntities();
      for i = 1, #entities do
        local enemy = entities[i]
        if enemy:IsVulnerableEnemy() then
          if familiar.Position:Distance(enemy.Position, familiar.Position) < 100 then
            enemy:AddConfusion(EntityRef(familiar), 200);
          end
        end
      end
      if scumbo.counterDelay > 45 then
        scumbo.damageText:Remove();
        scumbo.damageText = nil;
        scumbo.counterDelay = 0;
      end
    end
  else
    if scumbo.damageText ~= nil then
      scumbo.damageText:Remove();
      scumbo.damageText = nil;
    end
  end
end

function scumbo:onGameStart()
  SpawnPreviewItem(scumbo.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, scumbo.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, scumbo.cacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, scumbo.initFamiliar, scumbo.variantID)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, scumbo.familiarUpdate, scumbo.variantID)
NLSSMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, scumbo.onDamage, EntityType.ENTITY_PLAYER)