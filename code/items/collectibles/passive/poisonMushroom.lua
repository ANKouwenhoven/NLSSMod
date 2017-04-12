----------------------------------------
-- Poison Mushroom
-- Toxic Shots
----------------------------------------
-- Shots have a chance to create a
-- poison cloud on hit.
----------------------------------------

local poisonMushroom = {
  itemID = Isaac.GetItemIdByName("Poison Mushroom");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/mushroom.anm2");
  tearVariantID = Isaac.GetEntityVariantByName("mushroom");
  hasItem = nil;
  radius = 50;
  scale = 1;
  subtype = 0;
  tearList = {};
}

function poisonMushroom:onDamage(entity, amount, flag, source, countdown)
  if source.Type == EntityType.ENTITY_TEAR and source.Variant == poisonMushroom.tearVariantID then
    Game():Fart(entity.Position, poisonMushroom.radius, nil, poisonMushroom.scale, poisonMushroom.subtype)
  end
end

function poisonMushroom:onPlayerUpdate(player)  
	if player:HasCollectible(poisonMushroom.itemID) then
		if poisonMushroom.hasItem == false then
			player:AddNullCostume(poisonMushroom.costumeID)
			poisonMushroom.hasItem = true
		end
	end
  
  if player:HasCollectible(poisonMushroom.itemID) then
    local trackingTable = {};
		index, value = next(poisonMushroom.tearList, nil)
    
		while index do
      trackingTable[index] = value;
	    index, value = next(poisonMushroom.tearList, index);
    end
    
    local entities = Isaac.GetRoomEntities();
    
		for i = 1, #entities do
      local entity = entities[i];
      
			if entity.Type == EntityType.ENTITY_TEAR then
				trackingTable[entity.Index] = nil;
			end
      
			if entity.Type == EntityType.ENTITY_TEAR and entity.Variant ~= poisonMushroom.tearVariantID and
      entity.FrameCount == 0 and math.random(1, math.abs(10 - player.Luck)) == 1 then
				entity:ToTear():ChangeVariant(poisonMushroom.tearVariantID);
				poisonMushroom.tearList[entity.Index] = entity;
			end
		end
    
    for key, value in pairs(trackingTable) do
			if value ~= nil then
				local goop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF04, 0, value.Position, Vector(0, 0), player)
        goop:SetColor(Color(0.5, 0.5, 0.5, 1, 75, 0, 150), 0, 0, false, false)
				poisonMushroom.tearList[key] = nil;
			end
    end
  end
end

function poisonMushroom:onGameStart()
  poisonMushroom.hasItem = false
  SpawnPreviewItem(poisonMushroom.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, poisonMushroom.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, poisonMushroom.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, poisonMushroom.onDamage)