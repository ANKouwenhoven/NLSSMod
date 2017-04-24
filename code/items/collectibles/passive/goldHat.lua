----------------------------------------
-- Golden Hat
-- He's here, baby!
----------------------------------------
-- Pennies have a 25% of being nickels
-- instead.
-- Double damage at 99 cents.
----------------------------------------

local goldHat = {
  itemID = Isaac.GetItemIdByName("Golden Hat");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/goldHat.anm2");
  hasItem = nil;
  hatBuff = 0;
}

function goldHat:cacheUpdate(player, cacheFlag)
  addFlatStat(goldHat.itemID, player.Damage * goldHat.hatBuff, CacheFlag.CACHE_DAMAGE, cacheFlag);
end

function goldHat:onPlayerUpdate(player)  
	if player:HasCollectible(goldHat.itemID) then
		if goldHat.hasItem == false then
			player:AddNullCostume(goldHat.costumeID)
			goldHat.hasItem = true
		end
	end
  
  if player:HasCollectible(goldHat.itemID) then
    local entities = Isaac.GetRoomEntities();
    for i = 1, #entities do
      local entity = entities[i]:ToPickup();    
      if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_COIN and entities[i].SubType == CoinSubType.COIN_PENNY then
        if entities[i].FrameCount == 1 and math.random(1, 4) == 1 then
          if entity:IsShopItem() == false then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, false);
          else
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL, true);
          end
        end
      end
    end
  end
  
  if player:GetNumCoins() == 99 then
    if goldHat.hatBuff == 0 then
      goldHat.hatBuff = 1;
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
      player:EvaluateItems();
    end
  else
    if goldHat.hatBuff == 1 then
      goldHat.hatBuff = 0;
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
      player:EvaluateItems();
    end
  end
end

function goldHat:onGameStart()
  goldHat.hasItem = false
  SpawnPreviewItem(goldHat.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, goldHat.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, goldHat.onPlayerUpdate)