----------------------------------------
-- Ghost Bill
-- Works at the cheeto factory
----------------------------------------
-- Throws ghost cheetos
----------------------------------------

local ghostBill = {
  itemID = Isaac.GetItemIdByName("Ghost Bill");
  variantID = Isaac.GetEntityVariantByName("ghostBill");
}

function ghostBill:cacheUpdate(player, cacheFlag)  
  if cacheFlag == CacheFlag.CACHE_FAMILIARS then
	player:CheckFamiliar(ghostBill.variantID, player:GetCollectibleNum(ghostBill.itemID), RNG())
  end
end

function ghostBill:initFamiliar(familiar)
	familiar.IsFollower = true;
end

function ghostBill:familiarUpdate(familiar)
  local player = Isaac.GetPlayer(0)
  local direction = player:GetFireDirection()
  local shootingDirection;
   
  familiar:FollowParent()
  
  if direction == 0 then      -- Left
    shootingDirection = Vector(-1, 0)
  elseif direction == 1 then  -- Up
    shootingDirection = Vector(0, -1)
  elseif direction == 2 then  -- Right
    shootingDirection = Vector(1, 0)
  elseif direction == 3 then  -- Down
    shootingDirection = Vector(0, 1)
  end
  
  if shootingDirection ~= nil and Game():GetFrameCount() % 30 == 0 then
    local shots = math.random(1, 3);
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
      shots = math.random(2, 4);
    end
    for i = 1, shots do
      local thisTear = player:FireTear(familiar.Position, shootingDirection * 8 + Vector(math.random(-2, 2), math.random(-2, 2)), false, false, false);
      local currentSprite = thisTear:GetSprite():GetFilename() 
      if currentSprite ~= "gfx/Effects/ghostTear.anm2" then
        local newTearSprite = thisTear:GetSprite() 
        newTearSprite:Load("gfx/Effects/ghostTear.anm2", true)	
        newTearSprite:Play("Idle", true)
      end
    end
  end
end

function ghostBill:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		SpawnPreviewItem(ghostBill.itemID, 220, 200)
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ghostBill.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ghostBill.cacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, ghostBill.initFamiliar, ghostBill.variantID)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, ghostBill.familiarUpdate, ghostBill.variantID)