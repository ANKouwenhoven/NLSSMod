----------------------------------------
-- Irradiated Medkit
-- Nuclear Healing
----------------------------------------
-- When hit, restore all red hearts,
-- give one soul heart, poison all
-- enemies in the room
----------------------------------------

local radMedkit = {
  itemID = Isaac.GetTrinketIdByName("Irradiated Medkit");
}

function radMedkit:onDamage(player_x, damage, flag, source, countdown) 
  local player = Isaac.GetPlayer(0);
  
  if player:HasTrinket(radMedkit.itemID) then
    
    player:AddHearts(player:GetMaxHearts());
    player:AddSoulHearts(3);
    local heartEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HEART, 0, player.Position, Vector(0, 0), player);
    
    local entities = Isaac.GetRoomEntities();
    for i = 1, #entities do
      if entities[i]:IsVulnerableEnemy() then
        entities[i]:AddPoison(EntityRef(player), 180, player.Damage);
      end
    end
    
    player:TryRemoveTrinket(radMedkit.itemID);
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, radMedkit.onDamage, EntityType.ENTITY_PLAYER)