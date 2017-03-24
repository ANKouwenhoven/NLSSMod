----------------------------------------
-- Loot Hoard
-- Mind if I roll need?
----------------------------------------
-- At the end of a floor boss, receive
-- additional rewards
----------------------------------------

local lootHoard = {
  itemID = Isaac.GetItemIdByName("Loot Hoard");
  costumeID = Isaac.GetCostumeIdByPath("gfx/characters/lootHoarder.anm2");
  hasItem = nil;
  hasLooted = false;
}

function spawnLoot(currentRoom)
  local number = math.random(6);
  
  if number == 1 then
    --local item = SpawnPreviewItem(0, currentRoom:GetCenterPos().X, currentRoom:GetCenterPos().Y + 40);
    local item = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, currentRoom:GetCenterPos() + Vector(0, 40), Vector(0, 0), nil)
  elseif number == 2 then
    for i = 1, math.random(3) + 5 do
      local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, currentRoom:GetCenterPos() + Vector(0, 40), RandomVector(), enemy);
    end
  elseif number == 3 then
    for i = 1, 2 do
      local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_CHEST, ChestSubType.CHEST_CLOSED, currentRoom:GetCenterPos() + Vector(0, 40), RandomVector(), enemy);
    end
  elseif number == 4 then
    for i = 1, 2 do
      local key = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, currentRoom:GetCenterPos() + Vector(0, 40), RandomVector(), enemy);
      local bomb = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, currentRoom:GetCenterPos() + Vector(0, 40), RandomVector(), enemy);
    end
  elseif number == 5 then
    for i = 1, 2 do
      local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LOCKEDCHEST, ChestSubType.CHEST_CLOSED, currentRoom:GetCenterPos() + Vector(0, 40), RandomVector(), enemy);
    end
  elseif number == 6 then
    for i = 1, 2 do
      local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMBCHEST, ChestSubType.CHEST_CLOSED, currentRoom:GetCenterPos() + Vector(0, 40), RandomVector(), enemy);
    end
  end
end

function lootHoard:onPlayerUpdate(player)
	if Game():GetFrameCount() == 1 then
		lootHoard.hasItem = false;
    lootHoard.hasLooted = false;
    SpawnPreviewItem(lootHoard.itemID, 370, 350)
	end
  
	if player:HasCollectible(lootHoard.itemID) then
		if lootHoard.hasItem == false then
			player:AddNullCostume(lootHoard.costumeID)
			lootHoard.hasItem = true
		end
	end
  
  local currentRoom = Game():GetRoom();
  
  if player:HasCollectible(lootHoard.itemID) then
    if currentRoom:GetType() == RoomType.ROOM_BOSS then
      if currentRoom:IsClear() then
        if not lootHoard.hasLooted then
          spawnLoot(currentRoom);
          lootHoard.hasLooted = true;
        end
      else
        lootHoard.hasLooted = false;
      end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, lootHoard.onPlayerUpdate)