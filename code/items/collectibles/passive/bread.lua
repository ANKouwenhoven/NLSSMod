----------------------------------------
-- Bread with Integrity
-- Chili Resistant
----------------------------------------
-- Health up
-- Resistance to creep damage
----------------------------------------

local bread = {
  itemID = Isaac.GetItemIdByName("Bread with Integrity");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/bread.anm2");
  hasItem = nil;
}

function bread:onDamage(player_x, damage, flag, source, countdown)
  local player = Isaac.GetPlayer(0);
	if player:HasCollectible(bread.itemID) and flag == DamageFlag.DAMAGE_ACID then
		return false;
	end
end

function bread:onPlayerUpdate(player)  
	if player:HasCollectible(bread.itemID) then
		if bread.hasItem == false then
			player:AddNullCostume(bread.costumeID)
			bread.hasItem = true
		end
	end
end

function bread:onGameStart()
  bread.hasItem = false
  SpawnPreviewItem(bread.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, bread.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, bread.onPlayerUpdate)
NLSSMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, bread.onDamage, EntityType.ENTITY_PLAYER)