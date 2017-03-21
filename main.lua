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

-- Keeps track of the amount of nugs eaten
local nugCount = 0;
local hasEatenNugs = false;

-- Keeps track of the time Murph exists
local murphTimer = 0;

-- Keeps track of whether you've used the stapler this room
local usedStapler = false;
local removedTearDelay = 0;

-- Matricide
local matricide = false;

-- Nightmare variables
local nightmareAmount = 0;
local nightmareDistance = 5;

-- Minus realm data
local currentColor;
local minusRoom = false;

-- List of all new items
local itemList = {
  theBeretta = Isaac.GetItemIdByName("The Beretta");
  nug = Isaac.GetItemIdByName("Chicken Nugget");
  murph = Isaac.GetItemIdByName("Murph");
  stapler = Isaac.GetItemIdByName("The Stapler");
  judo = Isaac.GetItemIdByName("Black Glove");
  boardgame = Isaac.GetItemIdByName("Monster Time Boardgame");
  minus = Isaac.GetItemIdByName("Minus Realm");
}

local trinketList = {
  marflePop = Isaac.GetTrinketIdByName("Marfle-Pop!");
}

local usables = {
  pillRURURU = Isaac.GetPillEffectByName("RURURURURURURURURU")
}

-- Lists whether active items are being used
local activeUses = {
  holdingBeretta = false;
}

-- List of all new familiars
local familiarList = {
  murph = Isaac.GetEntityVariantByName("murph");
  nightmare = Isaac.GetEntityVariantByName("nightmare");
}

-- List of all new effects
local effectList = {
  badDamage = Isaac.GetEntityTypeByName("badDamage");
}

-- Resets everything after restarting
function NLSSMod:reset()
  hasEatenNugs = false;
  nugCount = 0;
  usedStapler = false;
  matricide = false;
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, NLSSMod.reset)

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

-- Minus realm'ed room
function minusEffect(player)
  local entities = Isaac.GetRoomEntities();
  for i = 1, #entities do
    entities[i].Color = Color(0, 0, 0, 1, 0, 0, 0);
    if Game():GetFrameCount() % 10 == 0 then
      entities[i].SpriteScale = Vector(math.random() * 2, math.random() * 2);
    end
  end
end

-- Events on damage
function NLSSMod:onDamage(player_x, damage_amount, damage_flag, damage_source, invincibility_frames)
  local player = Isaac.GetPlayer(0);
end

NLSSMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, NLSSMod.onDamage, EntityType.ENTITY_PLAYER)

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

-- Activate Beretta
function NLSSMod:useBeretta()
  local player = Isaac.GetPlayer(0)
  player:AnimateCollectible(itemList.theBeretta, "LiftItem", "Idle")
  activeUses.holdingBeretta = true
end

NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, NLSSMod.useBeretta, itemList.theBeretta)

-- Beretta's effect
function updateBeretta(player)
  if activeUses.holdingBeretta then
    local direction = player:GetFireDirection()
    local shootingDirection
    
    -- Get shooting direction
    if direction == 0 then      -- Left
      shootingDirection = Vector(-1, 0)
    elseif direction == 1 then  -- Up
      shootingDirection = Vector(0, -1)
    elseif direction == 2 then  -- Right
      shootingDirection = Vector(1, 0)
    elseif direction == 3 then  -- Down
      shootingDirection = Vector(0, 1)
    end

    if shootingDirection ~= nil then            
      tear = player:FireTear(player.Position, shootingDirection, false, false, false)
      tear.Velocity = tear.Velocity * 50;
      tear.CollisionDamage = player.Damage + 30;
      tear.Color = Color(0, 0, 0, 1, 0, 0, 0);
      tear.TearFlags = 1<<1;
      
      local entities = Isaac.GetRoomEntities();
      for i = 1, #entities do
        local entity = entities[i];
        if entity.Type == EntityType.ENTITY_MOM and matricide == false then
          matricide = true;
          entity:Kill();
          Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemList.matricide, Vector(320, 350), Vector(0, 0), nil)
        end
      end
      
      player:AnimateCollectible(itemList.theBeretta, "HideItem", "Idle")
      activeUses.holdingBeretta = false
    end
  end
end

-- Activate Judo Chop
function NLSSMod:useJudo()
  local player = Isaac.GetPlayer(0)
  
  local entities = Isaac.GetRoomEntities();
  for i = 1, #entities do
    if entities[i]:IsVulnerableEnemy() then
      entities[i].HitPoints = entities[i].HitPoints / 2;
      entities[i]:AddConfusion(EntityRef(player), 180, false);
    end
  end
  
  return true;
end

NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, NLSSMod.useJudo, itemList.judo)

-- Activate Minus Realm
function NLSSMod:useMinus()
  local player = Isaac.GetPlayer(0)
  Game():GetRoom():TurnGold();
  minusRoom = true;
  local entities = Isaac.GetRoomEntities();
  player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
  player:AddCacheFlags(CacheFlag.CACHE_SPEED);
  player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED);
  player.CanFly = true;
  player:EvaluateItems();
  for i = 1, #entities do
    if entities[i]:IsVulnerableEnemy() then
      entities[i]:AddFreeze(EntityRef(player), 250, false);
      entities[i]:AddSlowing(EntityRef(player), 1000, 0.1, Color(0, 0, 0, 1, 0, 0, 0))
      entities[i].Color = Color(0, 0, 0, 1, 0, 0, 0);
    end
  end
  currentColor = player.Color;
  player.Color = Color(0, 0, 0, 1, 0, 0, 0);
  
  return true;
end

NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, NLSSMod.useMinus, itemList.minus)

-- Activate Boardgame
function NLSSMod:useBoardgame()
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
  nightmareAmount = 0;
  
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      nightmareAmount = nightmareAmount + 1;
    end
  end
  
  player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS);
  player:EvaluateItems();
  
  return true;
end

NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, NLSSMod.useBoardgame, itemList.boardgame)

-- Activate Stapler
function NLSSMod:useStapler()
  local player = Isaac.GetPlayer(0)
  removedTearDelay = player.MaxFireDelay - 1;
  usedStapler = true;
  player:TakeDamage(1, 0, EntityRef(player), 0);
  player.MaxFireDelay = 1;
  
  return true;
end

NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, NLSSMod.useStapler, itemList.stapler)

-- Chicken Nug's effect
function NLSSMod:useNug()
  local player = Isaac.GetPlayer(0)
  nugCount = nugCount + 1;
  
  if player.MoveSpeed > 0.11 then
    if not hasEatenNugs then
      hasEatenNugs = true;
    end
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
    player:AddCacheFlags(CacheFlag.CACHE_RANGE);
    player:AddCacheFlags(CacheFlag.CACHE_SPEED);
    player:EvaluateItems();
  end
  
  if nugCount > 9 then
    local spawnX = player.Position.X + 30;
    local spawnY = player.Position.Y + 30;
    if player.Position.X > 400 then
      spawnX = player.Position.X - 30;
    end
    if player.Position.Y > 400 then
      spawnY = player.Position.Y - 30;
    end
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemList.nugCrown, Vector(spawnX, spawnY), Vector(0, 0), nil)
    player:RemoveCollectible(itemList.nug);
  end
  
  return true;
end

NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, NLSSMod.useNug, itemList.nug)

-- Murph's effect
function NLSSMod:useMurph()
  local player = Isaac.GetPlayer(0)
  murphTimer = 0;
  
  player:CheckFamiliar(familiarList.murph, player:GetCollectibleNum(itemList.murph), RNG())
  
  return true;
end

NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, NLSSMod.useMurph, itemList.murph)

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
  
  -- Damage Stats
  if minusRoom then
    addFlatStat(itemList.minus, player.Damage * 2, CacheFlag.CACHE_DAMAGE, cacheFlag);
  end
  
  -- Shotspeed Stats
  if minusRoom then
    addFlatStat(itemList.minus, player.ShotSpeed * 1.5, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  end
  
  -- Speed Stats
  if minusRoom then
    addFlatStat(itemList.minus, -0.7 * player.MoveSpeed, CacheFlag.CACHE_SPEED, cacheFlag);
  end
  
  -- Nug Stats
  if hasEatenNugs then
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
      player.Damage = player.Damage + 0.75 * nugCount;
    end
    
    if cacheFlag == CacheFlag.CACHE_SPEED then
      player.MoveSpeed = player.MoveSpeed - 0.10 * nugCount;
    end
    
    if cacheFlag == CacheFlag.CACHE_RANGE then
      player.TearHeight = player.TearHeight - 1 * nugCount;
    end
  end
  
  -- All familiar changes
  if cacheFlag == CacheFlag.CACHE_FAMILIARS then
    player:CheckFamiliar(familiarList.nightmare, nightmareAmount, RNG())
  end
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

-- Initializes Nightmare familiars by placing them into the correct orbit layer
function NLSSMod:initNightmare(familiar)
  familiar.OrbitLayer = 11;
  familiar:RecalculateOrbitOffset(familiar.OrbitLayer, true)
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initNightmare, familiarList.nightmare)

-- Handles Nightmare AI
function NLSSMod:nightmareUpdate(familiar)
  local player = Isaac.GetPlayer(0);
  familiar.OrbitSpeed = 0.01;
  familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position;
  
  local targetLocation;
  local entities = Isaac.GetRoomEntities();
  
  -- Look for an enemy close enough to chase
  for i = 1, #entities do
    entity = entities[i]
    if entity:IsVulnerableEnemy() then
      if familiar.Position:Distance(entity.Position, familiar.Position) < 100 then
        targetLocation = entity.Position;
        directionVector = entity.Position - familiar.Position;
        directionVector = directionVector:Normalized() * 5;
        familiar.Velocity = directionVector
      end
    end
  end
  
  -- No enemies to chase
  if targetLocation == nil then
    if familiar.Position:Distance(player.Position, familiar.Position) > 75 then
      
      -- Chase the player if we are too far away from it
      targetLocation = player.Position;
      directionVector = player.Position - familiar.Position;
      directionVector = directionVector:Normalized() * 5;
      familiar.Velocity = directionVector
    else
      
      -- Orbit the player
      targetLocation = familiar:GetOrbitPosition(player.Position)
      familiar.OrbitDistance = Vector(nightmareDistance, nightmareDistance)
      if nightmareDistance < 35 then
        nightmareDistance = nightmareDistance + 1;
      else
        nightmareDistance = 50 + 15 * math.sin((math.pi / 180) * (Game():GetFrameCount() * 6))       
      end
      familiar.Velocity = targetLocation - familiar.Position
    end
  end
  
  -- Induce fear in enemies that are close enough
  for i = 1, #entities do
    entity = entities[i]
    if entity:IsVulnerableEnemy() then
      if familiar.Position:Distance(entity.Position, familiar.Position) < 50 then
        entity:AddFear(EntityRef(familiar), 150)
      end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.nightmareUpdate, familiarList.nightmare)

-- Handles Murph AI
function NLSSMod:murphUpdate(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
  Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, familiar.Position, Vector(0, 0), familiar);
    
  for i = 1, #entities do
    local entity = entities[i]
    if entity:IsVulnerableEnemy() or entity.Type == EntityType.ENTITY_TEAR or entity.Type == EntityType.ENTITY_PICKUP then
      local directionVector = familiar.Position - entity.Position
      directionVector = directionVector:Normalized() * 3;
      entity.Velocity = entity.Velocity + directionVector
      
      if familiar.Position:Distance(entity.Position, familiar.Position) < 15 and entity:IsVulnerableEnemy() then
        Game():SpawnParticles(entity.Position, 43, 1, 0, Color(0.3, 0.1, 1, 1, 0, 0, 0), 0);
      end
    end
  end
  
  if murphTimer == 120 then
    familiar:Remove();
  else
    murphTimer = murphTimer + 1;
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.murphUpdate, familiarList.murph)

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
  
  -- Spawn all mod items on the very first frame
  if Game():GetFrameCount() == 1 and PREVIEW_ITEMS then
    SpawnItem(itemList.minus, 420, 350)
  
    SpawnItem(itemList.theBeretta, 170, 300)
    
    SpawnItem(itemList.nug, 470, 250)
    SpawnItem(itemList.murph, 270, 250)
    SpawnItem(itemList.stapler, 170, 250)
    
    SpawnItem(itemList.judo, 470, 150)
    SpawnItem(itemList.boardgame, 170, 150)
  end
  
  -- Workaround for the wonky firedelay stat
  if updateFireDelay then
    if not usedStapler then
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
  
  -- Things at the start of a room
  if Game():GetRoom():GetFrameCount() == 1 then
    
    local entities = Isaac.GetRoomEntities();
    
    -- Stapler reset
    if usedStapler == true then
      player.MaxFireDelay = player.MaxFireDelay + removedTearDelay;
      usedStapler = false;
      player:EvaluateItems();
    end
    
    -- Monster Time Boardgame reset
    if player:HasCollectible(itemList.boardgame) then
      nightmareAmount = 0;
      nightmareDistance = 5;
      player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS);
      player:EvaluateItems();
    end
    
    -- Minus Realm reset
    if currentColor ~= nil then
      player.Color = currentColor;
      currentColor = nil;
    end
    
    minusRoom = false;
    
    if player:HasCollectible(itemList.minus) then
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
      player:AddCacheFlags(CacheFlag.CACHE_SPEED);
      player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED);
      player.CanFly = false;
      player:EvaluateItems();
    end
  end
  
  -- Minus room handling
  if minusRoom then
    minusEffect(player);
  end
  
  -- Beretta effect
  if activeUses.holdingBeretta then
    updateBeretta(player);
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

Isaac.DebugString("Successfully loaded NLSSMod!")