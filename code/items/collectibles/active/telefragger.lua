----------------------------------------
-- Telefragger
-- Nuthin' personnel kid
----------------------------------------
-- Teleports a set distance forward
-- Instantly kills non-boss creatures
-- Caught in teleport destination
----------------------------------------

local telefragger = {
  itemID = Isaac.GetItemIdByName("Telefragger");
  silhouetteID = Isaac.GetEntityTypeByName("telefragSilhouette");
  silhouetteVariant = Isaac.GetEntityVariantByName("telefragSilhouette");
  particlesID = Isaac.GetEntityTypeByName("telefragParticles");
  particlesVariant = Isaac.GetEntityVariantByName("telefragParticles");
  killArea = 50;
  hasKilled = false;
  isInvulnerable = false;
}

function telefragger:useItem()
  local player = Isaac.GetPlayer(0);
  local room = Game():GetRoom();
  local currentDirection = player:GetMovementDirection();
  local directionVector = nil;
  
  if currentDirection == 0 then      -- Left
    directionVector = Vector(-1, 0)
  elseif currentDirection == 1 then  -- Up
    directionVector = Vector(0, -1)
  elseif currentDirection == 2 then  -- Right
    directionVector = Vector(1, 0)
  elseif currentDirection == 3 then  -- Down
    directionVector = Vector(0, 1)
  end
  
  local spawnSil1 = Isaac.Spawn(telefragger.silhouetteID, telefragger.silhouetteVariant, 0, player.Position + Vector(0, 3), Vector(0, 0), player);
  local spawnPart1 = Isaac.Spawn(telefragger.particlesID, telefragger.particlesVariant, 0, player.Position + Vector(0, 3), Vector(0, 0), player);
  local offsetPos = room:GetGridPosition(room:GetGridIndex(player.Position));
  local offset = player.Position - offsetPos;
  
  if directionVector ~= nil then
    player.Position = room:FindFreeTilePosition(offsetPos + directionVector * 150, 50) + offset;
    local spawnSil2 = Isaac.Spawn(telefragger.silhouetteID, telefragger.silhouetteVariant, 0, player.Position + Vector(0, 3), Vector(0, 0), player);
    local spawnPart2 = Isaac.Spawn(telefragger.particlesID, telefragger.particlesVariant, 0, player.Position + Vector(0, 3), Vector(0, 0), player);
  end
  
  for i, entity in pairs(Isaac.GetRoomEntities()) do
    if (entity.Position - player.Position):Length() < telefragger.killArea then
      if entity:IsVulnerableEnemy() then
        if entity:IsBoss() then
          entity:TakeDamage(entity.MaxHitPoints / 3, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0);
        else
          entity:Kill();
          telefragger.hasKilled = true;
        end
      end
    end
  end
  
  telefragger.isInvulnerable = true;
  return true;
end

function telefragger:onUpdate()
  local player = Isaac.GetPlayer(0);
  
  if telefragger.hasKilled then
    player:SetActiveCharge(18);
    telefragger.hasKilled = false;
  end
  
  for i, entity in pairs(Isaac.GetRoomEntities()) do
    if entity.Variant == telefragger.silhouetteVariant or entity.Variant == telefragger.particlesVariant then
      local sprite = entity:ToEffect():GetSprite();
      if sprite:IsFinished("Idle") then
        entity:Remove();
        
        if telefragger.isInvulnerable then
          telefragger.isInvulnerable = false;
        end
      end
    end
  end
  
  if player:HasCollectible(telefragger.itemID) and player:GetActiveCharge() < 18 and Game():GetFrameCount() % 20 == 0 then
    player:SetActiveCharge(player:GetActiveCharge() + 3);
  end
end

function telefragger:onDamage()
  if telefragger.isInvulnerable then
    return false;
  end
end

function telefragger:onGameStart()
  SpawnPreviewItem(telefragger.itemID)
  telefragger.hasKilled = false;
end

NLSSMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, telefragger.onDamage, EntityType.ENTITY_PLAYER)
NLSSMod:AddCallback(ModCallbacks.MC_POST_UPDATE, telefragger.onUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, telefragger.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, telefragger.useItem, telefragger.itemID)