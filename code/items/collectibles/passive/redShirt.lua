----------------------------------------
-- Red Shirt
-- Social Engineering
----------------------------------------
-- At the start of a room enemies have a
-- chance of being charmed immediately.
----------------------------------------

local redShirt = {
  itemID = Isaac.GetItemIdByName("Red Shirt");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/redShirt.anm2");
  hasItem = nil;
}

function redShirt:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		redShirt.hasItem = false
    SpawnPreviewItem(redShirt.itemID, 220, 250)
	end
  
	if player:HasCollectible(redShirt.itemID) then
		if redShirt.hasItem == false then
			player:AddNullCostume(redShirt.costumeID)
			redShirt.hasItem = true
		end
	end
  
  if player:HasCollectible(redShirt.itemID) and Game():GetRoom():GetFrameCount() == 1 then
    local entities = Isaac.GetRoomEntities();
    
    for i = 1, #entities do
      local enemy = entities[i]
      if enemy:IsVulnerableEnemy() and math.random(1, 4) == 1 then
        enemy:AddCharmed(120);
      end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, redShirt.onPlayerUpdate)