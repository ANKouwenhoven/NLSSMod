----------------------------------------
-- Staggered Stammer
-- Raining down on me
----------------------------------------
-- Orbits the player, shooting high
-- damage, high shotspeed tears outward.
----------------------------------------

local stammer = {
  itemID = Isaac.GetItemIdByName("Staggered Stammer");
  variantID = Isaac.GetEntityVariantByName("stammer");
}

function stammer:cacheUpdate(player, cacheFlag)  
  if cacheFlag == CacheFlag.CACHE_FAMILIARS then
	player:CheckFamiliar(stammer.variantID, player:GetCollectibleNum(stammer.itemID), RNG())
  end
end

function stammer:initFamiliar(familiar)
  familiar.OrbitLayer = 10;
  familiar:RecalculateOrbitOffset(familiar.OrbitLayer, true)
end

function stammer:familiarUpdate(familiar)
  local player = Isaac.GetPlayer(0);
  familiar.OrbitDistance = Vector(35, 35)
  familiar.OrbitSpeed = 0.01;
  familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position;
  
  -- Shoot every 30 frames
  if familiar.FrameCount % 30 == 0 then
    directionVector = familiar.Position - player.Position;
    directionVector = directionVector:Normalized() * 50;
    tear = Isaac.GetPlayer(0):FireTear(familiar.Position, directionVector, false, false, false):ToTear();
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
      tear.CollisionDamage = 100;
    else
      tear.CollisionDamage = 50;
    end
    tear.Color = Color(0, 0, 0, 1, 0, 0, 0);
  end
end

function stammer:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		SpawnPreviewItem(stammer.itemID, 220, 150)
	end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, stammer.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, stammer.cacheUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, stammer.initFamiliar, stammer.variantID)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, stammer.familiarUpdate, stammer.variantID)