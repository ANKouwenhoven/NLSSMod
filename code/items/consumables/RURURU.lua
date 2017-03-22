----------------------------------------
-- RURURU Pill
----------------------------------------
-- Confuses all enemies within 200 px
-- of the player, and creates brown
-- creep underneath them.
----------------------------------------

local RURURU = {
  pillID = Isaac.GetPillEffectByName("RURURURURURURURURU")
}

-- RURURU pill
function RURURU:takePill(pill)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities();
  
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      if player.Position:Distance(enemy.Position, player.Position) < 200 then
        enemy:AddConfusion(EntityRef(player), 120)
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_BLACK, 0, enemy.Position, Vector(0, 0), enemy);
        creep:SetColor(Color(1, 0, 0, 1, 150, 100, 50), 0, 0, false, false)
      end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_USE_PILL, RURURU.takePill, RURURU.pillID)