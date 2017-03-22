----------------------------------------
-- Marfle-Pop!
-- ???
----------------------------------------
-- At the start of a room, has a 25%
-- chance to obliterate a random enemy.
----------------------------------------

local marflePop = {
  itemID = Isaac.GetTrinketIdByName("Marfle-Pop!");
}

function marflePop:onPlayerUpdate(player)
  if player:HasTrinket(marflePop.itemID) then
    if Game():GetRoom():GetFrameCount() == 1 and math.random(1, 4) == 1 then
      local entities = Isaac.GetRoomEntities()
      local validEntity
      for i = 1, #entities do
        local enemy = entities[i]
        if enemy:IsVulnerableEnemy() then
          validEntity = enemy;
        end
      end
      
      if validEntity ~= nil then
        local attack = math.random(1, 3);
        if attack == 1 then
          sky = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, validEntity.Position, Vector(0, 0), enemy);
          sky:SetColor(Color(1, 1, 1, 1, math.random(255) * RandomSign(), math.random(255) * RandomSign(), math.random(255) * RandomSign()), 0, 0, false, false);
        elseif attack == 2 then
          Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MONSTROS_TOOTH, 0, validEntity.Position, Vector(0, 0), enemy);
        elseif attack == 3 then
          Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOM_FOOT_STOMP, 0, validEntity.Position, Vector(0, 0), enemy);
        end
      end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, marflePop.onPlayerUpdate)