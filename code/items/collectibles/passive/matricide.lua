----------------------------------------
-- Matricide
-- Heartless
----------------------------------------
-- Double damage
-- Red hearts are replaced with
-- Troll bombs
----------------------------------------

local matricide = {
  itemID = Isaac.GetItemIdByName("Matricide");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/matricide.anm2");
  hasItem = nil;
}

function matricide:cacheUpdate(player, cacheFlag)
  addFlatStat(matricide.itemID, player.Damage, CacheFlag.CACHE_DAMAGE, cacheFlag);
end

function matricide:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		matricide.hasItem = false
	end
  
	if player:HasCollectible(matricide.itemID) then
		if matricide.hasItem == false then
			player:AddNullCostume(matricide.costumeID)
			matricide.hasItem = true
		end
	end
  
  local entities = Isaac.GetRoomEntities();
  for i = 1, #entities do
    local entity = entities[i]:ToPickup();
    if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_FULL then
      if entity:IsShopItem() == false then
				entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_TROLL, false);
			else
				entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, true);
			end
    end
    
    if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_DOUBLEPACK then
      if entity:IsShopItem() == false then
				entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_SUPERTROLL, false);
			else
				entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, true);
			end
    end
    
    if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_HALF then
      if entity:IsShopItem() == false then
				entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_TROLL, false);
			else
				entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, true);
			end
    end
    
    if entities[i].Type == EntityType.ENTITY_PICKUP and entities[i].Variant == PickupVariant.PICKUP_HEART and entities[i].SubType == HeartSubType.HEART_BLENDED then
      if entity:IsShopItem() == false then
				entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_TROLL, false);
			else
				entity:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, true);
			end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, matricide.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, matricide.cacheUpdate)