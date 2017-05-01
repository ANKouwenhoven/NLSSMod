----------------------------------------
-- Spreadsheet
-- It's not cheating!
----------------------------------------
-- Fired tears sometimes shoot directly
-- at nearby enemies.
----------------------------------------

local spreadsheet = {
  itemID = Isaac.GetItemIdByName("Spreadsheet");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/spreadsheet.anm2");
  hasItem = nil;
}

function spreadsheet:onPlayerUpdate(player)  
	if player:HasCollectible(spreadsheet.itemID) then
		if spreadsheet.hasItem == false then
			--player:AddNullCostume(spreadsheet.costumeID)
			spreadsheet.hasItem = true
		end
	end
  
  if player:HasCollectible(spreadsheet.itemID) then
    for i, entity in pairs(Isaac.GetRoomEntities()) do
      if entity.Type == EntityType.ENTITY_TEAR and entity.FrameCount == 1 and math.random(100) <= (math.abs(player.Luck) + 1) * 100 / 20 then
        local tear = entity:ToTear();
        tear.Color = Color(1, 0, 0, 1, 0, 0, 0);
        tear.CollisionDamage = 1.5 * player.Damage;
        if GetClosestEnemy() ~= nil then
          tear.Velocity = (GetClosestEnemy().Position - tear.Position):Normalized() * player.ShotSpeed * 10;
        end
      end
    end
  end
end

function GetClosestEnemy()
  local player = Isaac.GetPlayer(0);
  local closestDist = 1000;
  local closestEntity = nil;
  
  for i, entity in pairs(Isaac.GetRoomEntities()) do
    if entity:IsVulnerableEnemy() then
      if (player.Position - entity.Position):Length() < closestDist then
        closestDist = (player.Position - entity.Position):Length();
        closestEntity = entity;
      end
    end
  end
  
  return closestEntity;
end

function spreadsheet:onGameStart()
  spreadsheet.hasItem = false
  SpawnPreviewItem(spreadsheet.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, spreadsheet.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, spreadsheet.onPlayerUpdate)