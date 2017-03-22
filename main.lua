-- Registers this mod
NLSSMod = RegisterMod("NLSSMod", 1);

-- Enable this to spawn all new items in the first room when starting a run
local PREVIEW_ITEMS = true;

-- Minimum allowed tear delay
local MIN_TEAR_DELAY = 5;

-- Flag whether FireDelay is to be updated
local updateFireDelay = false;

-- Amount to change FireDelay with
local fireDelayChange = 0;

local trinketList = {
  marflePop = Isaac.GetTrinketIdByName("Marfle-Pop!");
}

local usables = {
  pillRURURU = Isaac.GetPillEffectByName("RURURURURURURURURU")
}

-- Returns a random Float between numbers min and max
function RandomFloatBetween(min, max) 
  return math.random() * (max - min) + min
end

-- Randomly returns 1 or -1
function RandomSign()
  if math.random() < 0.5 then return -1 else return 1 end
end

function round(number, decimals)
  local multiplier = 10^(decimals or 0)
  return math.floor(number * multiplier + 0.5) / multiplier
end

-- Checks sprites for being already custom
function isCustomSprite(sprite)
  if sprite == "gfx/Effects/gungeonBullet.anm2" then
    return true;
  end
    
  if sprite == "gfx/Effects/jellyTear3.anm2" then
    return true;
  end
    
  if sprite == "gfx/Effects/jellyTear4.anm2" then
    return true;
  end
    
  if sprite == "gfx/Effects/ghostTear.anm2" then
    return true;
  end
    
  return false;
end

-- Effect of the Marfle-Pop trinket
function marflePopEffect(player)
  if Game():GetRoom():GetFrameCount() == 1 and math.random(1, 4) == 1 then
    local entities = Isaac.GetRoomEntities()
    local validentity
    for i = 1, #entities do
      local enemy = entities[i]
      if enemy:IsVulnerableEnemy() then
        validentity = enemy
      end
    end
    
    local attack = math.random(1, 3);
    if attack == 1 then
      sky = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, validentity.Position, Vector(0, 0), enemy);
      sky:SetColor(Color(1, 1, 1, 1, math.random(255) * RandomSign(), math.random(255) * RandomSign(), math.random(255) * RandomSign()), 0, 0, false, false);
    elseif attack == 2 then
      Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MONSTROS_TOOTH, 0, validentity.Position, Vector(0, 0), enemy);
    elseif attack == 3 then
      Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MOM_FOOT_STOMP, 0, validentity.Position, Vector(0, 0), enemy);
    end
  end
end

-- RURURU pill
function NLSSMod:takeRUPill(pillRURURU)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities();
  
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      if player.Position:Distance(enemy.Position, player.Position) < 200 then
        enemy:AddConfusion(EntityRef(player), 120)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GOLD_PARTICLE, 0, enemy.Position, Vector(0, 0), enemy);
      end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_USE_PILL, NLSSMod.takeRUPill, usables.pillRURURU)

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
        fireDelayChange = fireDelayChange + bonus;
        updateFireDelay = true;
      end
    end
  end
end

-- Updates stat changes - called whenever the stat cache is updated
function NLSSMod:cacheUpdate(player, cacheFlag)
  -- Firedelay Stats
  fireDelayChange = 0;
end

NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, NLSSMod.cacheUpdate)

-- Makes familiars face the way they are moving
function setOrientation(familiar, flipped)
  local sprite = familiar:GetSprite();
  local dir = toDirection(familiar.Velocity);
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
function toDirection(vector)
	if vector.X > 0 then
    return Direction.RIGHT;
	elseif vector.X < 0 then
    return Direction.LEFT;
	end

	return Direction.NO_DIRECTION
end

-- Returns whether there are enemies in the current room
function CheckForEnemies()
	local entities = Isaac.GetRoomEntities()
	for i = 1, #entities do
		if (entities[i]:IsActiveEnemy(false) and entities[i]:CanShutDoors()) then
			return true
		end
	end
  return false
end

-- Quality of life item spawn function
function SpawnPreviewItem(Item, X, Y)
  if PREVIEW_ITEMS then
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Item, Vector(X, Y), Vector(0, 0), nil)
  end
end

-- Code that has to run every frame
function NLSSMod:onUpdate()
  local player = Isaac.GetPlayer(0);
  
  -- Workaround for the wonky firedelay stat
  if updateFireDelay then
    if not staplerActive() then
      if (player.MaxFireDelay - fireDelayChange > MIN_TEAR_DELAY) then
        player.MaxFireDelay = player.MaxFireDelay - fireDelayChange;
      elseif (player.MaxFireDelay - fireDelayChange > 4) then
        player.MaxFireDelay = MIN_TEAR_DELAY;
      elseif (player.MaxFireDelay - fireDelayChange > 2) then
        player.MaxFireDelay = 4;
      else
        player.MaxFireDelay = 3;
      end
    else
      player.MaxFireDelay = 1;
    end
    updateFireDelay = false
  end
  
  -- Marfle-Pop trinket effect
  if player:HasTrinket(trinketList.marflePop) then
    marflePopEffect(player)
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_UPDATE, NLSSMod.onUpdate)

-- Passive items
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
require("code/items/collectibles/passive/tennis");
require("code/items/collectibles/passive/twitchyChatter");

-- Familiars
require("code/familiars/ghostBill");
require("code/familiars/jellies");
require("code/familiars/oceanMan");
require("code/familiars/petRock");
require("code/familiars/scumbo");
require("code/familiars/stammer");
require("code/familiars/teratomo");

-- Actives
require("code/items/collectibles/active/chickenNugget");
require("code/items/collectibles/active/murph");
require("code/items/collectibles/active/beretta");
require("code/items/collectibles/active/stapler");
require("code/items/collectibles/active/blackGlove");
require("code/items/collectibles/active/monsterTimeBoardgame");
require("code/items/collectibles/active/minusRealm");

Isaac.DebugString("Successfully loaded NLSSMod!")