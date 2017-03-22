----------------------------------------
-- Black Glove
-- Can I interest you in a JUDOCHOP?
----------------------------------------
-- Confuses all enemies in the room and
-- cuts their health in half.
----------------------------------------

local blackGlove = {
  itemID = Isaac.GetItemIdByName("Black Glove");
}

function blackGlove:useItem()
  local player = Isaac.GetPlayer(0)
  
  local entities = Isaac.GetRoomEntities();
  for i = 1, #entities do
    if entities[i]:IsVulnerableEnemy() then
      entities[i].HitPoints = entities[i].HitPoints / 2;
      entities[i]:AddConfusion(EntityRef(player), 180, false);
    end
  end
  
  return true;
end

function blackGlove:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
    SpawnPreviewItem(blackGlove.itemID, 470, 150)
    blackGlove.isActive = false;
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, blackGlove.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, blackGlove.useItem, blackGlove.itemID)