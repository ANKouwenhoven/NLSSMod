----------------------------------------
-- The Beretta
-- Fun for the whole family
----------------------------------------
-- Shoots a single high damage tear in
-- target direction.
-- When used on Mom, instantly kills her
-- and then spawns Matricide.
----------------------------------------

local beretta = {
  itemID = Isaac.GetItemIdByName("The Beretta");
  isActive = false;
  spawnedMatricide = false;
}

function beretta:useItem()
  local player = Isaac.GetPlayer(0)
  player:AnimateCollectible(beretta.itemID, "LiftItem", "Idle")
  beretta.isActive = true
end

function updateBeretta()
  local player = Isaac.GetPlayer(0);
  local direction = player:GetFireDirection()
  local shootingDirection;
   
  -- Get shooting direction
  if direction == 0 then      -- Left
    shootingDirection = Vector(-1, 0)
  elseif direction == 1 then  -- Up
    shootingDirection = Vector(0, -1)
  elseif direction == 2 then  -- Right
    shootingDirection = Vector(1, 0)
  elseif direction == 3 then  -- Down
    shootingDirection = Vector(0, 1)
  end

  if shootingDirection ~= nil then            
    local bullet = player:FireTear(player.Position, shootingDirection, false, false, false)
    bullet.Velocity = bullet.Velocity * 50;
    bullet.CollisionDamage = player.Damage + 30;
    bullet.Color = Color(0, 0, 0, 1, 0, 0, 0);
    bullet.TearFlags = 1<<1;
    local sprite = bullet:GetSprite()
    sprite:Load("gfx/Effects/gungeonBullet.anm2", true)	
    sprite:Play("Idle", true)
    sprite.Rotation = bullet.Velocity:GetAngleDegrees()
      
    local entities = Isaac.GetRoomEntities();
    for i = 1, #entities do
      local entity = entities[i];
      if entity.Type == EntityType.ENTITY_MOM and beretta.spawnedMatricide == false then
        beretta.spawnedMatricide = true;
        entity:Kill();
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, getMatricide(), Vector(320, 350), Vector(0, 0), nil)
      end
    end
      
    player:AnimateCollectible(beretta.itemID, "HideItem", "Idle")
    beretta.isActive = false
  end
end

function beretta:onPlayerUpdate(player)  
  if beretta.isActive then
    updateBeretta();
  end
end

function beretta:onGameStart()
  SpawnPreviewItem(beretta.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, beretta.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, beretta.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, beretta.useItem, beretta.itemID)