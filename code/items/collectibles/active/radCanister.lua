----------------------------------------
-- Rad Canister
-- Nuclear health
----------------------------------------
-- 
----------------------------------------

local radCanister = {
  itemID = Isaac.GetItemIdByName("Rad Canister");
}

function radCanister:useItem()  
  return true;
end

function radCanister:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
    SpawnPreviewItem(radCanister.itemID, 170, 350)
    radCanister.isActive = false;
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, radCanister.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, radCanister.useItem, radCanister.itemID)