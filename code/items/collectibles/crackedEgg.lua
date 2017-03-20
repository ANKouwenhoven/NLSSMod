----------------------------------------
-- Cracked Eggshell
-- Badly Damaged
----------------------------------------
-- When you take damage, explode into
-- tears.
----------------------------------------

local crackedEgg = {
  itemID = Isaac.GetItemIdByName("Cracked Eggshell");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/crackedEgg.anm2");
  hasItem = nil;
}

function crackedEgg:eggEffect()
  local player = Isaac.GetPlayer(0);
  
  if not player:HasCollectible(crackedEgg.itemID) then
    return;
  end
  
  for tears = 1, 25 do
    local directionVector = Vector(RandomSign() * math.random(1, 10), RandomSign() * math.random(1, 10));
    tear1 = player:FireTear(player.Position, directionVector, false, false, false);
    tear1.Color = Color(1, 1, 1, 1, 255, 255, 255);
  end

  for tears = 1, 5 do
    local directionVector = Vector(RandomSign() * math.random(1, 3), RandomSign() * math.random(1, 5));
    tear2 = player:FireTear(player.Position, directionVector, false, false, false);
    tear2.CollisionDamage = player.Damage + 5;
    tear2.Color = Color(1, 1, 1, 1, 255, 255, 0);
  end
end

function crackedEgg:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		crackedEgg.hasItem = false
    SpawnPreviewItem(crackedEgg.itemID, 470, 300)
	end
  
	if player:HasCollectible(crackedEgg.itemID) then
		if crackedEgg.hasItem == false then
			player:AddNullCostume(crackedEgg.costumeID)
			crackedEgg.hasItem = true
		end
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, crackedEgg.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, crackedEgg.eggEffect, EntityType.ENTITY_PLAYER)