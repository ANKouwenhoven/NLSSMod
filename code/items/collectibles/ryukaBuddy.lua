----------------------------------------
-- Ryuka Buddy
-- Open the door!
----------------------------------------
-- 0.3 Speed up
-- Normal doors now stay open.
----------------------------------------

local ryuka = {
  itemID = Isaac.GetItemIdByName("Ryuka Buddy");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/ryuka.anm2");
  hasItem = nil;
}

function ryuka:cacheUpdate(player, cacheFlag)
  addFlatStat(ryuka.itemID, 0.3, CacheFlag.CACHE_SPEED, cacheFlag);
end

function ryuka:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		ryuka.hasItem = false
    SpawnPreviewItem(ryuka.itemID, 420, 150)
	end
  
	if player:HasCollectible(ryuka.itemID) then
		if ryuka.hasItem == false then
			player:AddNullCostume(ryuka.costumeID)
			ryuka.hasItem = true
		end
	end
  
  if player:HasCollectible(ryuka.itemID) then
    local currentRoom = Game():GetRoom();
    
    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
      thisDoor = currentRoom:GetDoor(i);
      if thisDoor ~= nil and thisDoor:IsRoomType(RoomType.ROOM_DEFAULT) and not thisDoor:IsOpen() then
        thisDoor:Open();
      end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ryuka.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ryuka.cacheUpdate)