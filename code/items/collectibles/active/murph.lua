----------------------------------------
-- Murph
-- Don't let me leave!
----------------------------------------
-- Places a black hole on the ground
-- that sucks in enemies and shots.
----------------------------------------

local murph = {
  itemID = Isaac.GetItemIdByName("Murph");
  variantID = Isaac.GetEntityVariantByName("murph");
  lifetime = 0;
}

function murph:useItem()
  local player = Isaac.GetPlayer(0)
  murph.lifetime = 0;
  
  player:CheckFamiliar(murph.variantID, player:GetCollectibleNum(murph.itemID), RNG())
  
  return true;
end

function murph:familiarUpdate(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities();
  
  Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, familiar.Position, Vector(0, 0), familiar);
  if math.random(50) == 1 then
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0, familiar.Position + Vector(0, 10), Vector(0, 0), familiar);
    poof:SetColor(Color(0, 0, 0, 1, 50, 0, 100), 0, 0, false, false);
    poof.RenderZOffset = -999;
  end
    
  for i = 1, #entities do
    local entity = entities[i]
    if entity:IsVulnerableEnemy() or entity.Type == EntityType.ENTITY_TEAR or entity.Type == EntityType.ENTITY_PICKUP then
      local directionVector = familiar.Position - entity.Position
      directionVector = directionVector:Normalized() * 3;
      entity:AddVelocity(directionVector);
      
      if familiar.Position:Distance(entity.Position, familiar.Position) < 15 and entity:IsVulnerableEnemy() then
        Game():SpawnParticles(entity.Position, 43, 1, 0, Color(0.3, 0.1, 1, 1, 0, 0, 0), 0);
      end
    end
  end
  
  if murph.lifetime == 120 then
    familiar:Remove();
  else
    murph.lifetime = murph.lifetime + 1;
  end
  
  local sprite = familiar:GetSprite()
  sprite.Rotation = Game():GetFrameCount() * 20;
end

function murph:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
    SpawnPreviewItem(murph.itemID, 270, 250)
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, murph.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, murph.useItem, murph.itemID)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, murph.familiarUpdate, murph.variantID)