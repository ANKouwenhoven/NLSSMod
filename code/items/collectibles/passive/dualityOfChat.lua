----------------------------------------
-- Duality of Chat
-- M A L F | J O S H | D N A
----------------------------------------
-- Marks enemies either red or green.
-- Red and green marked enemies
-- attach each other.
----------------------------------------

local dualityOfChat = {
  itemID = Isaac.GetItemIdByName("Duality of Chat");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/dualityOfChat.anm2");
  statusEffectEntity = Isaac.GetEntityTypeByName("dualityStatus");
  statusEffectVariant = Isaac.GetEntityVariantByName("dualityStatus");
  tearVariantIDY = Isaac.GetEntityVariantByName("voteYea");
  tearVariantIDN = Isaac.GetEntityVariantByName("voteNay");
  hasItem = nil;
  
  tearListY = {};
  tearListN = {};
  currentTearType = 1;
  
  enemyList = {};
  enemyIndex = 1;
  
  effectsList = {};
}

function dualityOfChat:onDamage(entity, amount, flag, source, countdown)
  if not entity:IsVulnerableEnemy() then
    return;
  end
  
  if source.Type == EntityType.ENTITY_TEAR then
    if source.Variant == dualityOfChat.tearVariantIDY or source.Variant == dualityOfChat.tearVariantIDN then
      dualityOfChat.enemyList[dualityOfChat.enemyIndex] = entity;
      
      entity:AddEntityFlags(EntityFlag.FLAG_CHARM);
      
      dualityOfChat.effectsList[dualityOfChat.enemyIndex] = Isaac.Spawn(dualityOfChat.statusEffectEntity, dualityOfChat.statusEffectVariant, 0,
        entity.Position - Vector(0, entity.Size * entity.SizeMulti.Y + 48), Vector(0,0), entity)
      
      dualityOfChat.effectsList[dualityOfChat.enemyIndex]:ToEffect():FollowParent(entity)
      dualityOfChat.effectsList[dualityOfChat.enemyIndex].RenderZOffset = 999999;
      spriteStatus = dualityOfChat.effectsList[dualityOfChat.enemyIndex]:GetSprite();
      
      if source.Variant == dualityOfChat.tearVariantIDY then
        spriteStatus:Play("Yea", true); 
      else
        spriteStatus:Play("Nay", true); 
      end
      
      dualityOfChat.enemyIndex = dualityOfChat.enemyIndex + 1;
      
      for i, entity2 in pairs(Isaac.GetRoomEntities()) do
      if entity2:IsVulnerableEnemy() and (entity.Position - entity2.Position):Length() < 100 then
        dualityOfChat.enemyList[dualityOfChat.enemyIndex] = entity2;
      
        entity2:AddEntityFlags(EntityFlag.FLAG_CHARM);
      
        dualityOfChat.effectsList[dualityOfChat.enemyIndex] = Isaac.Spawn(dualityOfChat.statusEffectEntity, dualityOfChat.statusEffectVariant, 0,
          entity2.Position - Vector(0, entity2.Size * entity2.SizeMulti.Y + 48), Vector(0,0), entity2)
      
        dualityOfChat.effectsList[dualityOfChat.enemyIndex]:ToEffect():FollowParent(entity2)
        dualityOfChat.effectsList[dualityOfChat.enemyIndex].RenderZOffset = 999999;
        spriteStatus = dualityOfChat.effectsList[dualityOfChat.enemyIndex]:GetSprite();
      
        if math.random(2) == 1 then
          spriteStatus:Play("Yea", true); 
        else
          spriteStatus:Play("Nay", true); 
        end
      
        dualityOfChat.enemyIndex = dualityOfChat.enemyIndex + 1;
      end
    end
    end
  end
end

function dualityOfChat:onNPCUpdate(entity)
  for n = 1, dualityOfChat.enemyIndex do
    if dualityOfChat.enemyList[n] ~= nil then
      if dualityOfChat.enemyList[n]:IsActiveEnemy() == false then
        if dualityOfChat.effectsList[n] ~= nil then
          dualityOfChat.effectsList[n]:Remove()
        end
      end
    end
  end
end

function dualityOfChat:onPlayerUpdate(player)  
	if player:HasCollectible(dualityOfChat.itemID) then
		if dualityOfChat.hasItem == false then
			player:AddNullCostume(dualityOfChat.costumeID)
			dualityOfChat.hasItem = true
		end
	end
  
  if player:HasCollectible(dualityOfChat.itemID) then
    local trackingTableY = {};
		index, value = next(dualityOfChat.tearListY, nil)
    
		while index do
      trackingTableY[index] = value;
	    index, value = next(dualityOfChat.tearListY, index);
    end
    
    local trackingTableN = {};
		index, value = next(dualityOfChat.tearListN, nil)
    
		while index do
      trackingTableN[index] = value;
	    index, value = next(dualityOfChat.tearListN, index);
    end
    
    local entities = Isaac.GetRoomEntities();
    
		for i = 1, #entities do
      local entity = entities[i];
      
			if entity.Type == EntityType.ENTITY_TEAR then
				trackingTableY[entity.Index] = nil;
        trackingTableN[entity.Index] = nil;
			end
      
      local procChance = math.random(1, math.floor(math.max(1, 15 - player.Luck)));
      
			if entity.Type == EntityType.ENTITY_TEAR and entity.Variant ~= dualityOfChat.tearVariantIDY and
      entity.FrameCount == 0 and dualityOfChat.currentTearType == 1 and procChance == 1 then
				entity:ToTear():ChangeVariant(dualityOfChat.tearVariantIDY);
				dualityOfChat.tearListY[entity.Index] = entity;
        dualityOfChat.currentTearType = 2;
			elseif entity.Type == EntityType.ENTITY_TEAR and entity.Variant ~= dualityOfChat.tearVariantIDN and
      entity.FrameCount == 0 and dualityOfChat.currentTearType == 2 and procChance == 1 then
        entity:ToTear():ChangeVariant(dualityOfChat.tearVariantIDN);
				dualityOfChat.tearListN[entity.Index] = entity;
        dualityOfChat.currentTearType = 1;
      end
		end
    
    for key, value in pairs(trackingTableY) do
			if value ~= nil then
				local goop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF, 0, value.Position, Vector(0, 0), player)
        goop:SetColor(Color(0, 1, 0, 1, 0, 200, 0), 0, 0, false, false)
				dualityOfChat.tearListY[key] = nil;
			end
    end
    
    for key, value in pairs(trackingTableN) do
			if value ~= nil then
				local goop = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BULLET_POOF, 0, value.Position, Vector(0, 0), player)
        goop:SetColor(Color(1, 0, 0, 1, 100, 0, 0), 0, 0, false, false)
				dualityOfChat.tearListN[key] = nil;
			end
    end
  end
end

function dualityOfChat:onGameStart()
  dualityOfChat.hasItem = false
  SpawnPreviewItem(dualityOfChat.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, dualityOfChat.onNPCUpdate);
NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, dualityOfChat.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, dualityOfChat.onDamage)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, dualityOfChat.onPlayerUpdate)