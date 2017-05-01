----------------------------------------
-- Bowl of Spaghetti
-- Why is this inserter not working?
----------------------------------------
-- Empty heart up
-- When all heart containers are filled
-- all red heart drops turn into soul
-- heart drops.
-- When not all heart containers are
-- filled, all soul heart drops turn
-- into red heart drops.
----------------------------------------

local spaghetti = {
  itemID = Isaac.GetItemIdByName("Spaghetti Island");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/spaghetti.anm2");
  hasItem = nil;
}

function spaghetti:onPlayerUpdate(player)  
	if player:HasCollectible(spaghetti.itemID) then
		if spaghetti.hasItem == false then
			player:AddNullCostume(spaghetti.costumeID)
			spaghetti.hasItem = true
		end
	end
  
  if player:HasCollectible(spaghetti.itemID) then
    if player:HasFullHearts() then
      local entities = Isaac.GetRoomEntities();
      for i = 1, #entities do
        local entity = entities[i]:ToPickup();
        if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_FULL then
          if entity:IsShopItem() == false then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, false);
          else
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, true);
          end
        end
        
        if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_DOUBLEPACK then
          if entity:IsShopItem() == false then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, false);
          else
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, true);
          end
        end
        
        if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_HALF then
          if entity:IsShopItem() == false then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, false);
          else
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, true);
          end
        end
        
        if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_BLENDED then
          if entity:IsShopItem() == false then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, false);
          else
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, true);
          end
        end
        
        if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_SCARED then
          if entity:IsShopItem() == false then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, false);
          else
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, true);
          end
        end
      end
    else
      local entities = Isaac.GetRoomEntities();
      for i = 1, #entities do
        local entity = entities[i]:ToPickup();
        if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_SOUL then
          if entity:IsShopItem() == false then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, false);
          else
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, true);
          end
        end
        
        if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_BLENDED then
          if entity:IsShopItem() == false then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, false);
          else
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, true);
          end
        end
        
        if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_HALF_SOUL then
          if entity:IsShopItem() == false then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, false);
          else
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, true);
          end
        end
        
        if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_BLACK then
          if entity:IsShopItem() == false then
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, false);
          else
            entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, true);
          end
        end
      end
    end
  end
end

function spaghetti:onGameStart()
  spaghetti.hasItem = false
  SpawnPreviewItem(spaghetti.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, spaghetti.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, spaghetti.onPlayerUpdate)