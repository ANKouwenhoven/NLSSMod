----------------------------------------
-- Monster Time Boardgame
-- By RaccAttack Inc.
----------------------------------------
-- Summons a nightmare for every enemy
-- in the room, which circle the player
-- until an enemy comes too close.
-- Nightmares will attack and fear
-- enemies they find.
----------------------------------------

local boardGame = {
  itemID = Isaac.GetItemIdByName("Monster Time Boardgame");
  variantID = Isaac.GetEntityVariantByName("nightmare");
  activeAmount = 0;
  orbitDistance = 5;
}

function boardGame:useItem()
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
  boardGame.activeAmount = 0;
  
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      boardGame.activeAmount = boardGame.activeAmount + 1;
    end
  end
  
  player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS);
  player:EvaluateItems();
  
  return true;
end

function boardGame:initFamiliar(familiar)
  familiar.OrbitLayer = 11;
  familiar:RecalculateOrbitOffset(familiar.OrbitLayer, true)
end

function boardGame:cacheUpdate(player, cacheFlag)  
  if cacheFlag == CacheFlag.CACHE_FAMILIARS then
    player:CheckFamiliar(boardGame.variantID, boardGame.activeAmount, RNG())
  end
end

function boardGame:familiarUpdate(familiar)
  local player = Isaac.GetPlayer(0);
  familiar.OrbitSpeed = 0.01;
  familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position;
  
  local targetLocation;
  local entities = Isaac.GetRoomEntities();
  
  -- Look for an enemy close enough to chase
  for i = 1, #entities do
    local entity = entities[i]
    if entity:IsVulnerableEnemy() and entity:IsActiveEnemy() then
      if familiar.Position:Distance(entity.Position, familiar.Position) < 100 then
        targetLocation = entity.Position;
         local directionVector = entity.Position - familiar.Position;
        directionVector = directionVector:Normalized() * 5;
        familiar.Velocity = directionVector
      end
    end
  end
  
  -- No enemies to chase
  if targetLocation == nil then
    if familiar.Position:Distance(player.Position, familiar.Position) > 75 then
      
      -- Chase the player if we are too far away from it
      targetLocation = player.Position;
      local directionVector = player.Position - familiar.Position;
      directionVector = directionVector:Normalized() * 5;
      familiar.Velocity = directionVector
    else
      
      -- Orbit the player
      targetLocation = familiar:GetOrbitPosition(player.Position)
      familiar.OrbitDistance = Vector(boardGame.orbitDistance, boardGame.orbitDistance)
      if boardGame.orbitDistance < 35 then
        boardGame.orbitDistance = boardGame.orbitDistance + 1;
      else
        boardGame.orbitDistance = 50 + 15 * math.sin((math.pi / 180) * (Game():GetFrameCount() * 6))       
      end
      familiar.Velocity = targetLocation - familiar.Position
    end
  end
  
  -- Induce fear in enemies that are close enough
  for i = 1, #entities do
    entity = entities[i]
    if entity:IsVulnerableEnemy() then
      if familiar.Position:Distance(entity.Position, familiar.Position) < 50 then
        entity:AddFear(EntityRef(familiar), 150)
      end
    end
  end
end

function boardGame:onGameStart()
  SpawnPreviewItem(boardGame.itemID)
end

function boardGame:onNewRoom()
  local player = Isaac.GetPlayer(0);
  if player:HasCollectible(boardGame.itemID) then
    boardGame.activeAmount = 0;
    boardGame.orbitDistance = 5;
    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS);
    player:EvaluateItems();
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, boardGame.onNewRoom)
NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, boardGame.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, boardGame.cacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, boardGame.useItem, boardGame.itemID)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, boardGame.initFamiliar, boardGame.variantID)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, boardGame.familiarUpdate, boardGame.variantID)