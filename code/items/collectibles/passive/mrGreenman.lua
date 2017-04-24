----------------------------------------
-- Mr Greenman
-- Gli&amp-8182budd%p91##
----------------------------------------
-- Mr Greenman glitches around the room
-- Damaging and inflicting status
-- effects on enemies he comes in
-- contact with.
----------------------------------------

local mrGreenman = {
  itemID = Isaac.GetItemIdByName("Mr Greenman");
  variantID = Isaac.GetEntityVariantByName("greenman");
  entityID = Isaac.GetEntityTypeByName("greenman");
  
  greenmanSpawn = nil;
  spawnDelay = 10;
  activeRoom = nil;
}

function greenmanUpdate()
  local player = Isaac.GetPlayer(0);
  local room = Game():GetRoom();
	local pos;
	local sprite;
  
  if (mrGreenman.greenmanSpawn == nil) then
		if (CheckForEnemies()) then
			mrGreenman.spawnDelay = mrGreenman.spawnDelay - 1;

			if (mrGreenman.spawnDelay <= 0) then
				pos = room:GetGridPosition(room:GetGridIndex(Isaac:GetRandomPosition())) 
				pos = room:FindFreeTilePosition(pos, 100) 
				mrGreenman.greenmanSpawn = Isaac.Spawn(mrGreenman.entityID, mrGreenman.variantID, 0, pos, Vector(0, 0), player)
				mrGreenman.activeRoom = Game():GetLevel():GetCurrentRoomIndex()
        mrGreenman.spawnDelay = 50;
        local entities = Isaac.GetRoomEntities();
        for i = 1, #entities do
          local enemy = entities[i]
          if enemy:IsVulnerableEnemy() then
            if mrGreenman.greenmanSpawn.Position:Distance(enemy.Position, mrGreenman.greenmanSpawn.Position) < 100 then
              local dice = math.random(1, 3);
              if dice == 1 then
                enemy:AddFreeze(EntityRef(player), 100)
              elseif dice == 2 then
                enemy:AddConfusion(EntityRef(player), 100, true)
              elseif dice == 3 then
                enemy:AddMidasFreeze(EntityRef(player), 100)
              end
            end
          end
        end
        
        sprite = mrGreenman.greenmanSpawn:GetSprite();
        if mrGreenman.spawnDelay <= 0 then
          sprite:SetAnimation("Appear")
          sprite:Play("Appear", true)
        end
			end
		else
			mrGreenman.spawnDelay = 1;
		end
	end
  
	if mrGreenman.greenmanSpawn ~= nil then
    
    sprite = mrGreenman.greenmanSpawn:GetSprite()
    
    if (sprite:IsFinished("Appear")) then
      mrGreenman.greenmanSpawn:Remove()
      mrGreenman.greenmanSpawn = nil
    end
    
    if CheckForEnemies() == false then
      mrGreenman.greenmanSpawn:Remove()
      mrGreenman.greenmanSpawn = nil
    end
	end
end

function mrGreenman:onPlayerUpdate()
  local player = Isaac.GetPlayer(0);
  if player:HasCollectible(mrGreenman.itemID) then
    greenmanUpdate();
  end
end

function mrGreenman:onGameStart()
  mrGreenman.hasItem = false
  mrGreenman.greenmanSpawn = nil;
  mrGreenman.spawnDelay = 10;
  mrGreenman.activeRoom = nil;
  SpawnPreviewItem(mrGreenman.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mrGreenman.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_UPDATE, mrGreenman.onPlayerUpdate)