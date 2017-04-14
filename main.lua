--------------------------------------------------------
-- NLSS Itempack Mod!
-- This main file holds all utility functions.
-- All item files are loaded at the bottom of this file.
--------------------------------------------------------

-- Registers this mod
NLSSMod = RegisterMod("NLSS Memes Itempack", 1);

-- Enable this to spawn all new items in the first room when starting a run
-----------------------------
-- | | | | | | | | | | | | --
----------------------------
local PREVIEW_ITEMS = true;
-----------------------------
-- | | | | | | | | | | | | --
-----------------------------

-- Adds a stat bonus if the player has the right item
function addFlatStat(item, bonus, bonustype, cacheFlag)
  local player = Isaac.GetPlayer(0);
  if cacheFlag == bonustype then
    if player:HasCollectible(item) then
      if bonustype == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + bonus;
      elseif bonustype == CacheFlag.CACHE_RANGE then
        player.TearHeight = player.TearHeight - bonus;
      elseif bonustype == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + bonus;
      elseif bonustype == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + bonus;
      elseif bonustype == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + bonus;
      elseif bonustype == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay - bonus;
      end
    end
  end
end

-- Returns a random Float between numbers min and max
function clampedRandom(min, max) 
  return math.random() * (max - min) + min
end

-- Randomly returns 1 or -1
function randomSign()
  if math.random() < 0.5 then
    return -1;
  else
    return 1;
  end
end

-- Rounds a number to the given amount of decimals
function round(number, decimals)
  local multiplier = 10^(decimals or 0)
  return math.floor(number * multiplier + 0.5) / multiplier
end

-- Makes familiars face the way they are moving
function setOrientation(familiar, flipped)
  local sprite = familiar:GetSprite();
  local dir = ToDirection(familiar.Velocity);
  if flipped then
    if dir == Direction.LEFT then
      sprite.FlipX = true;
    else
      sprite.FlipX = false;
    end
  else
    if dir == Direction.LEFT then
      sprite.FlipX = false;
    else
      sprite.FlipX = true;
    end
  end
end

-- Returns a facing direction based off its movement vector
function ToDirection(vector)
	if vector.X > 0 then
    return Direction.RIGHT;
	elseif vector.X < 0 then
    return Direction.LEFT;
	end
  
	return Direction.NO_DIRECTION;
end

-- Returns whether there are enemies in the current room
function CheckForEnemies()
	local entities = Isaac.GetRoomEntities()
	for i = 1, #entities do
		if (entities[i]:IsActiveEnemy(false) and entities[i]:CanShutDoors()) then
			return true;
		end
	end
  return false;
end

-- For item placement in the start room
local previewGrid = {
  yCoord = 150;
  xCoord = 100;
}

-- Spawns an item in the starting room when PREVIEW_ITEMS is true
-- Automatically adjusts spawning position
function SpawnPreviewItem(Item)
  if PREVIEW_ITEMS then
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Item, Vector(previewGrid.xCoord, previewGrid.yCoord), Vector(0, 0), nil)
    if previewGrid.xCoord > 500 then
      previewGrid.yCoord = previewGrid.yCoord + 50;
      previewGrid.xCoord = 100;
    else
      previewGrid.xCoord = previewGrid.xCoord + 50;
    end
  end
end

function NLSSMod:ResetSpawnPositions()
  previewGrid.xCoord = 100;
  previewGrid.yCoord = 150;
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, NLSSMod.ResetSpawnPositions)

-- Passive items
require("code/items/collectibles/passive/bread");
require("code/items/collectibles/passive/cobaltsStreak");
require("code/items/collectibles/passive/theCoin");
require("code/items/collectibles/passive/crackedEgg");
require("code/items/collectibles/passive/eyeForAesthetic");
require("code/items/collectibles/passive/goldHat");
require("code/items/collectibles/passive/gungeonMaster");
require("code/items/collectibles/passive/laCroix");
require("code/items/collectibles/passive/lootHoard");
require("code/items/collectibles/passive/madrinas");
require("code/items/collectibles/passive/matricide");
require("code/items/collectibles/passive/mindFlood");
require("code/items/collectibles/passive/mrGreenman");
require("code/items/collectibles/passive/nugCrown");
require("code/items/collectibles/passive/poisonMushroom");
require("code/items/collectibles/passive/purpleLord");
require("code/items/collectibles/passive/rattler");
require("code/items/collectibles/passive/redShirt");
require("code/items/collectibles/passive/ryukaBuddy");
require("code/items/collectibles/passive/spaghettiIsland");
require("code/items/collectibles/passive/tennis");
require("code/items/collectibles/passive/twitchyChatter");
require("code/items/collectibles/passive/virtualBart");

-- Familiars
require("code/familiars/ghostBill");
require("code/familiars/jellies");
require("code/familiars/oceanMan");
require("code/familiars/petRock");
require("code/familiars/scumbo");
require("code/familiars/stammer");
require("code/familiars/teratomo");

-- Active items
require("code/items/collectibles/active/beretta");
require("code/items/collectibles/active/blackGlove");
require("code/items/collectibles/active/bookOfBolegda");
require("code/items/collectibles/active/chickenNugget");
require("code/items/collectibles/active/minusRealm");
require("code/items/collectibles/active/monsterTimeBoardgame");
require("code/items/collectibles/active/murph");
require("code/items/collectibles/active/radCanister");
require("code/items/collectibles/active/stapler");

-- Trinkets
require("code/items/trinkets/marflePop");
require("code/items/trinkets/radMedkit");

-- Consumables
require("code/items/consumables/RURURU");

Isaac.DebugString("Successfully loaded NLSSMod!")