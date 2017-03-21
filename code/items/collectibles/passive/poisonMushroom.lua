----------------------------------------
-- Poison Mushroom
-- Toxic Shots
----------------------------------------
-- Shots have a chance to create a
-- poison cloud on hit.
----------------------------------------

local poisonMushroom = {
  itemID = Isaac.GetItemIdByName("Poison Mushroom");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/poisonMushroom.anm2");
  hasItem = nil;
}

function poisonMushroom:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		poisonMushroom.hasItem = false
    SpawnPreviewItem(poisonMushroom.itemID, 320, 350)
	end
  
	if player:HasCollectible(poisonMushroom.itemID) then
		if poisonMushroom.hasItem == false then
			--player:AddNullCostume(poisonMushroom.costumeID)
			poisonMushroom.hasItem = true
		end
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, poisonMushroom.onPlayerUpdate)