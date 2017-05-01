----------------------------------------
-- The Swarm
-- BZZZZZ Bombs
----------------------------------------
-- Bombs spawn random locusts on
-- detonation.
----------------------------------------

local theSwarm = {
  itemID = Isaac.GetItemIdByName("The Swarm");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/theSwarm.anm2");
  hasItem = nil;
}

function theSwarm:onPlayerUpdate(player)  
	if player:HasCollectible(theSwarm.itemID) then
		if theSwarm.hasItem == false then
			player:AddNullCostume(theSwarm.costumeID)
			theSwarm.hasItem = true
		end
	end

	if player:HasCollectible(theSwarm.itemID) == true then
		for i, entity in pairs(Isaac.GetRoomEntities()) do
			if entity.Type == EntityType.ENTITY_BOMBDROP and entity.SpawnerType == EntityType.ENTITY_PLAYER then
				
        local sprite = entity:GetSprite();

				if entity.FrameCount == 1 then
					sprite:Load("gfx/effects/hiveBomb.anm2", true)
					sprite:LoadGraphics()
				end

				if sprite:IsPlaying("Explode") and entity:GetData().hasSpawned == nil then
					for i = 1, math.random(1, 4) do
            local bee = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, GetRandomLocust(), entity.Position, Vector(0, 0), player);
            bee:GetSprite():Load("gfx/effects/swarmBee.anm2",true)
            bee:GetSprite():Play("Idle",true)
          end
          
          entity:GetData().hasSpawned = true;
				end
			end
		end
	end
end

function GetRandomLocust()
  local rand = math.random(5);
  if rand == 1 then 
    return LocustSubtypes.LOCUST_OF_CONQUEST;
  elseif rand == 2 then
    return LocustSubtypes.LOCUST_OF_DEATH;
  elseif rand == 3 then
    return LocustSubtypes.LOCUST_OF_FAMINE;
  elseif rand == 4 then
    return LocustSubtypes.LOCUST_OF_PESTILENCE;
  else
    return LocustSubtypes.LOCUST_OF_WRATH;
  end
end

function theSwarm:onGameStart()
  theSwarm.hasItem = false
  SpawnPreviewItem(theSwarm.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, theSwarm.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, theSwarm.onPlayerUpdate)