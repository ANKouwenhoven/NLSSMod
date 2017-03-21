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

-- Ocean man's Aura
local oceanAura;

-- Matricide
local matricide = false;

-- The Twitchy chatter
local chatspawn;
local spawnDelay = 20;
local chatRoom;
local animationMode = 0;
local chatterBuffs = 0;

-- Mr Greenman
local greenman;
local greenDelay = 10;
local greenRoom;

-- Current amount of Jellies
local jellyAmount = 0;

-- Scumbo variables
local scumboCounter = 0;
local badDamage;
local damageFrames = 0;
local counterDelay = 0;
local scumboFlag = false;
local scumboStage = 1;

-- Nightmare variables
local nightmareAmount = 0;
local nightmareDistance = 5;

-- Minus realm data
local currentColor;
local minusRoom = false;

-- List of all new items
local itemList = {
  petRock = Isaac.GetItemIdByName("Pet Rock");
  theBeretta = Isaac.GetItemIdByName("The Beretta");
  nug = Isaac.GetItemIdByName("Chicken Nugget");
  jellies = Isaac.GetItemIdByName("Jar of Jellies");
  oceanMan = Isaac.GetItemIdByName("Ocean Man");
  murph = Isaac.GetItemIdByName("Murph");
  stapler = Isaac.GetItemIdByName("The Stapler");
  chatter = Isaac.GetItemIdByName("Twitchy Chatter");
  greenman = Isaac.GetItemIdByName("Mr Greenman");
  ghostBill = Isaac.GetItemIdByName("Ghost Bill");
  judo = Isaac.GetItemIdByName("Black Glove");
  teratomo = Isaac.GetItemIdByName("Teratomo");
  scumbo = Isaac.GetItemIdByName("Scumbo");
  stammer = Isaac.GetItemIdByName("Staggered Stammer");
  boardgame = Isaac.GetItemIdByName("Monster Time Boardgame");
  minus = Isaac.GetItemIdByName("Minus Realm");
  mushroom = Isaac.GetItemIdByName("Poison Mushroom");
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
  petRock = Isaac.GetEntityVariantByName("petRock");
  jelly1 = Isaac.GetEntityVariantByName("jelly1");
  jelly2 = Isaac.GetEntityVariantByName("jelly2");
  jelly3 = Isaac.GetEntityVariantByName("jelly3");
  jelly4 = Isaac.GetEntityVariantByName("jelly4");
  oceanMan = Isaac.GetEntityVariantByName("oceanMan");
  murph = Isaac.GetEntityVariantByName("murph");
  chatter = Isaac.GetEntityVariantByName("chatter");
  greenman = Isaac.GetEntityVariantByName("greenman");
  ghostBill = Isaac.GetEntityVariantByName("ghostBill");
  teratomo = Isaac.GetEntityVariantByName("teratomo");
  scumbo = Isaac.GetEntityVariantByName("scumbo");
  stammer = Isaac.GetEntityVariantByName("stammer");
  nightmare = Isaac.GetEntityVariantByName("nightmare");
}

-- List of all new effects
local effectList = {
  oceanWhirl = Isaac.GetEntityTypeByName("oceanWhirl");
  badDamage = Isaac.GetEntityTypeByName("badDamage");
}

-- Resets everything after restarting
function NLSSMod:reset()
  hasEatenNugs = false;
  nugCount = 0;
  usedStapler = false;
  chatterBuffs = 0;
  oceanAura = nil;
  matricide = false;
  jellyAmount = 0;
  scumboCounter = 0;
  badDamage = nil;
  damageFrames = 0;
  scumboStage = 1;
  counterDelay = 0;
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

-- Scumbo's AI on damage
function scumboEffect()
  local takenDamage = true;
  scumboCounter = scumboCounter + 1;
  
  if scumboCounter > 10 then
    scumboStage = 3;
  elseif scumboCounter > 3 then
    scumboStage = 2;
  end
  
  scumboFlag = true;

  if scumboStage == 3 then
    local entities = Isaac.GetRoomEntities();
    local player = Isaac.GetPlayer(0);
    
    if math.random(1, 4) == 1 then
      coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_LUCKYPENNY, player.Position, Vector(0, 0), enemy);
      takenDamage = false;
    end
  end
  
  return takenDamage;
end

-- Events on damage
function NLSSMod:onDamage(player_x, damage_amount, damage_flag, damage_source, invincibility_frames)
  local player = Isaac.GetPlayer(0);
  
  if player:HasCollectible(itemList.scumbo) then
    return scumboEffect();
  end
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
  
  -- Luck Stats
  addFlatStat(itemList.petRock, 1, CacheFlag.CACHE_LUCK, cacheFlag);
  
  -- Shotspeed Stats
  if minusRoom then
    addFlatStat(itemList.minus, player.ShotSpeed * 1.5, CacheFlag.CACHE_SHOTSPEED, cacheFlag);
  end
  
  -- Speed Stats
  if minusRoom then
    addFlatStat(itemList.minus, -0.7 * player.MoveSpeed, CacheFlag.CACHE_SPEED, cacheFlag);
  end
  
  -- Familiar Stats
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
    addFlatStat(itemList.chatter, 0.75 * chatterBuffs, CacheFlag.CACHE_DAMAGE, cacheFlag);
    if oceanManCheck then
      addFlatStat(itemList.oceanMan, 3, CacheFlag.CACHE_DAMAGE, cacheFlag);
      addFlatStat(itemList.oceanMan, 5, CacheFlag.CACHE_RANGE, cacheFlag);
      addFlatStat(itemList.oceanMan, 0.2, CacheFlag.CACHE_SPEED, cacheFlag);
    end
  else
    addFlatStat(itemList.chatter, 0.5 * chatterBuffs, CacheFlag.CACHE_DAMAGE, cacheFlag);
    if oceanManCheck then
      addFlatStat(itemList.oceanMan, 2, CacheFlag.CACHE_DAMAGE, cacheFlag);
      addFlatStat(itemList.oceanMan, 3, CacheFlag.CACHE_RANGE, cacheFlag);
      addFlatStat(itemList.oceanMan, 0.1, CacheFlag.CACHE_SPEED, cacheFlag);
    end
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
    player:CheckFamiliar(familiarList.petRock, player:GetCollectibleNum(itemList.petRock), RNG())
    player:CheckFamiliar(familiarList.ghostBill, player:GetCollectibleNum(itemList.ghostBill), RNG())
    player:CheckFamiliar(familiarList.oceanMan, player:GetCollectibleNum(itemList.oceanMan), RNG())
    player:CheckFamiliar(familiarList.teratomo, player:GetCollectibleNum(itemList.teratomo), RNG())
    player:CheckFamiliar(familiarList.scumbo, player:GetCollectibleNum(itemList.scumbo), RNG())
    player:CheckFamiliar(familiarList.stammer, player:GetCollectibleNum(itemList.stammer), RNG())
    player:CheckFamiliar(familiarList.nightmare, nightmareAmount, RNG())
    
    for i = 1, 2 do
      if jellyAmount < player:GetCollectibleNum(itemList.jellies) * 2 then
        player:CheckFamiliar(randomJelly(), player:GetCollectibleNum(itemList.jellies), RNG())
        jellyAmount = jellyAmount + 1;
      end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, NLSSMod.cacheUpdate)

-- Returns a random Jelly to spawn
function randomJelly()
  jellyNum = math.random(1, 4)
  
  if jellyNum == 1 then
    return familiarList.jelly1;
  elseif jellyNum == 2 then
    return familiarList.jelly2;
  elseif jellyNum == 3 then
    return familiarList.jelly3;
  elseif jellyNum == 4 then
    return familiarList.jelly4;
  end
end

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


-- Standard Familiar Initialization
function NLSSMod:initFamiliar(familiar)
  familiar.IsFollower = true;
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initFamiliar, familiarList.petRock)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initFamiliar, familiarList.ghostBill)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initFamiliar, familiarList.oceanMan)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initFamiliar, familiarList.jelly1)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initFamiliar, familiarList.jelly2)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initFamiliar, familiarList.jelly3)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initFamiliar, familiarList.jelly4)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initFamiliar, familiarList.teratomo)
NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initFamiliar, familiarList.scumbo)

-- Initializes Nightmare familiars by placing them into the correct orbit layer
function NLSSMod:initNightmare(familiar)
  familiar.OrbitLayer = 11;
  familiar:RecalculateOrbitOffset(familiar.OrbitLayer, true)
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initNightmare, familiarList.nightmare)

-- Initializes Stammer by placing it into the correct orbit layer
function NLSSMod:initStammer(familiar)
  familiar.OrbitLayer = 10;
  familiar:RecalculateOrbitOffset(familiar.OrbitLayer, true)
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, NLSSMod.initStammer, familiarList.stammer)

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

-- Handles Stammer AI
function NLSSMod:stammerUpdate(familiar)
  local player = Isaac.GetPlayer(0);
  familiar.OrbitDistance = Vector(35, 35)
  familiar.OrbitSpeed = 0.01;
  familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position;
  
  -- Shoot every 30 frames
  if familiar.FrameCount % 30 == 0 then
    directionVector = familiar.Position - player.Position;
    directionVector = directionVector:Normalized() * 50;
    tear = Isaac.GetPlayer(0):FireTear(familiar.Position, directionVector, false, false, false):ToTear();
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
      tear.CollisionDamage = 100;
    else
      tear.CollisionDamage = 50;
    end
    tear.Color = Color(0, 0, 0, 1, 0, 0, 0);
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.stammerUpdate, familiarList.stammer)

-- Handles Pet Rock AI
function NLSSMod:petRockUpdate(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
   
  familiar:FollowParent()
    
  -- Midas freezes all enemies that "collide" with pet rock
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      if familiar.Position:Distance(enemy.Position, familiar.Position) < 15 then
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
          enemy:AddMidasFreeze(EntityRef(player), 120);
        else
          enemy:AddMidasFreeze(EntityRef(player), 60);
        end
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.GOLD_PARTICLE, 0, enemy.Position, Vector(0, 0), enemy);
      end
    end
  end
  
  setOrientation(familiar, false);
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.petRockUpdate, familiarList.petRock)

-- Handles Scumbo AI
function NLSSMod:scumboUpdate(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
   
  familiar:FollowParent()
  
  if scumboStage == 2 then
    sprite = familiar:GetSprite();
    sprite:SetAnimation("Stage2")
    sprite:Play("Stage2", true)
  end
  
  if scumboStage == 3 then
    sprite = familiar:GetSprite();
    sprite:SetAnimation("Stage3")
    sprite:Play("Stage3", true)
  end
  
  if scumboStage == 2 then
    if scumboFlag == true then
      if badDamage == nil then
        badDamage = Isaac.Spawn(effectList.badDamage, 1015, 0, familiar.Position, Vector(0, 0), player);
        scumboFlag = false;
      end
    end
    if badDamage ~= nil then
      badDamage.Position = badDamage.Position + Vector(0, -2);
      badDamage.Velocity = Vector(0, 0);
      badDamage.RenderZOffset = 13999;
      counterDelay = counterDelay + 1;
      local entities = Isaac.GetRoomEntities();
      for i = 1, #entities do
        local enemy = entities[i]
        if enemy:IsVulnerableEnemy() then
          if familiar.Position:Distance(enemy.Position, familiar.Position) < 100 then
            enemy:AddConfusion(EntityRef(familiar), 200);
          end
        end
      end
      if counterDelay > 45 then
        badDamage:Remove();
        badDamage = nil;
        counterDelay = 0;
      end
    end
  else
    if badDamage ~= nil then
      badDamage:Remove();
      badDamage = nil;
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.scumboUpdate, familiarList.scumbo)

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

-- Handles Ghost Bill AI
function NLSSMod:ghostBillUpdate(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
  local direction = player:GetFireDirection()
  local shootingDirection;
   
  familiar:FollowParent()
  
  if direction == 0 then      -- Left
    shootingDirection = Vector(-1, 0)
  elseif direction == 1 then  -- Up
    shootingDirection = Vector(0, -1)
  elseif direction == 2 then  -- Right
    shootingDirection = Vector(1, 0)
  elseif direction == 3 then  -- Down
    shootingDirection = Vector(0, 1)
  end
  
  if shootingDirection ~= nil and Game():GetFrameCount() % 30 == 0 then
    local shots = math.random(1, 3);
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
      shots = math.random(2, 4);
    end
    for i = 1, shots do
      local thisTear = player:FireTear(familiar.Position, shootingDirection * 8 + Vector(math.random(-2, 2), math.random(-2, 2)), false, false, false);
      local currentSprite = thisTear:GetSprite():GetFilename() 
      if currentSprite ~= "gfx/Effects/ghostTear.anm2" then
        local newTearSprite = thisTear:GetSprite() 
        newTearSprite:Load("gfx/Effects/ghostTear.anm2", true)	
        newTearSprite:Play("Idle", true)
      end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.ghostBillUpdate, familiarList.ghostBill)

-- Handles Jelly 1 AI
function NLSSMod:jelly1Update(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
   
  familiar:FollowParent()
  
  setOrientation(familiar, true);
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.jelly1Update, familiarList.jelly1)

-- Handles Jelly 2 AI
function NLSSMod:jelly2Update(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
  
  familiar:FollowParent()
  
  -- Leaves red creep
  if math.random(10) == 1 then
    creep1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, familiar.Position, Vector(0, 0), player) 
    creep1:SetColor(Color(1, 0, 0, 1, 250, 100, 50), 0, 0, false, false)
  end
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and math.random(10) == 1 then
    creep2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, familiar.Position, Vector(0, 0), player) 
    creep2:SetColor(Color(1, 0, 0, 1, 250, 50, 25), 0, 0, false, false)
  end
  
  setOrientation(familiar, true);
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.jelly2Update, familiarList.jelly2)

-- Handles Jelly 3 AI
function NLSSMod:jelly3Update(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
   
  familiar:FollowParent()
  
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      if familiar.Position:Distance(enemy.Position, familiar.Position) < 150 and Game():GetFrameCount() % 30 == 0 then
        local shots = 2;
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
          shots = 4;
        end
        for i = 1, shots do
          local thisTear = player:FireTear(familiar.Position, Vector(math.random(-5, 5), math.random(-5, 5)), false, false, false);
          local currentSprite = thisTear:GetSprite():GetFilename() 
          if currentSprite ~= "gfx/Effects/jellyTear3.anm2" then
            local newTearSprite = thisTear:GetSprite() 
            newTearSprite:Load("gfx/Effects/jellyTear3.anm2", true)	
            newTearSprite:Play("Idle", true)
          end
        end
      end
    end
  end
  
  setOrientation(familiar, true);
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.jelly3Update, familiarList.jelly3)

-- Handles Jelly 4 AI
function NLSSMod:jelly4Update(familiar)
  local player = Isaac.GetPlayer(0)
  local entities = Isaac.GetRoomEntities()
   
  familiar:FollowParent()
  
  -- Leaves a floating tear in place
  if Game():GetFrameCount() % 30 == 0 then
    local oldRange = player.TearHeight;
    local oldDamage = player.Damage;
    player.TearHeight = player.TearHeight - 20;
    player.Damage = player.Damage + 5;
    
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
      player.Damage = player.Damage + 10;
    end
    
    local thisTear = player:FireTear(familiar.Position, Vector(0, 0), false, false, false);
    local currentSprite = thisTear:GetSprite():GetFilename() ;
    
    if currentSprite ~= "gfx/Effects/jellyTear4.anm2" then
      local newTearSprite = thisTear:GetSprite() 
      newTearSprite:Load("gfx/Effects/jellyTear4.anm2", true)	
      newTearSprite:Play("Idle", true)
    end
    
    player.TearHeight = oldRange;
    player.Damage = oldDamage;
  end
  
  setOrientation(familiar, true);
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.jelly4Update, familiarList.jelly4)

-- Handles Ocean Man AI
function NLSSMod:oceanManUpdate(familiar)
  familiar:MoveDiagonally(1);
  
  local player = Isaac.GetPlayer(0)
  local area = 120;
  
  if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
    range = 150;
  end
  
  if familiar.Position:Distance(player.Position, familiar.Position) < 120 then
    oceanManCheck = true;
  else
    oceanManCheck = false;
  end
  
  if oceanAura == nil then
    oceanAura = Isaac.Spawn(effectList.oceanWhirl, 1010, 0, familiar.Position, Vector(0, 0), player);
  else
    oceanAura.Position = familiar.Position;
    oceanAura.RenderZOffset = -999;
    oceanAura.Velocity = familiar.Velocity;
  end
  
  player:AddCacheFlags(CacheFlag.CACHE_RANGE);
  player:AddCacheFlags(CacheFlag.CACHE_DAMAGE);
  player:AddCacheFlags(CacheFlag.CACHE_SPEED);
  player:EvaluateItems();
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.oceanManUpdate, familiarList.oceanMan)

-- Handles Teratomo AI
function NLSSMod:teratomoUpdate(familiar)
  familiar:MoveDiagonally(1);
  
  -- Midas freezes all enemies that "collide" with teratomo
  local entities = Isaac.GetRoomEntities();
  
  for i = 1, #entities do
    local enemy = entities[i]
    if enemy:IsVulnerableEnemy() then
      if familiar.Position:Distance(enemy.Position, familiar.Position) < 25 and math.random(1, 4) == 1 then
        newTomo = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, familiarList.teratomo, 0, familiar.Position, Vector(0, 0), player)
      end
    end
  end
end

NLSSMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, NLSSMod.teratomoUpdate, familiarList.teratomo)

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

-- Twitchy Chatter's effect
function chatterUpdate()
	local player = Isaac.GetPlayer(0);
  local room = Game():GetRoom();
	local pos;
	local sprite;

  if (chatspawn == nil) then
		if (CheckForEnemies()) then
			spawnDelay = spawnDelay - 1;

			if (spawnDelay <= 0) then
				pos = room:GetGridPosition(room:GetGridIndex(Isaac:GetRandomPosition())) 
				pos = room:FindFreeTilePosition(pos, 100) 
				chatspawn = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, familiarList.chatter, 0, pos, Vector(0, 0), player)
        animationMode = 0;
				chatRoom = Game():GetLevel():GetCurrentRoomIndex()
			end
      
		else
			spawnDelay = 10
		end
	end
  
	if chatspawn ~= nil then
    spawnDelay = spawnDelay - 1

    if animationMode == 0 then
      sprite = chatspawn:GetSprite()
      if (sprite:GetFrame() >= 5) then
        animationMode = 1
        sprite:SetAnimation("Idle")
        sprite:Play("Idle", true)
        spawnDelay = 200;
      end
    end
  
    if animationMode == 1 then
      if (chatspawn.Position:Distance(player.Position, chatspawn.Position) < 25) or (spawnDelay <= 0) or (CheckForEnemies() == false) then
        if chatspawn.Position:Distance(player.Position, chatspawn.Position) < 25 then
          chatterBuffs = chatterBuffs + 1;
          player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
          player:EvaluateItems()
        end
        sprite = chatspawn:GetSprite()
        sprite:SetAnimation("Hide")
        sprite:Play("Hide", true)
        animationMode = 3;
      end
    end
    
    if (Game():GetLevel():GetCurrentRoomIndex() ~= chatRoom)
    or (animationMode == 3 and chatspawn:GetSprite():IsFinished("Hide")) then
      chatspawn:Remove()
      chatspawn = nil
      spawnDelay = 10;
    end
	end
end

-- Mr Greenman's Effect
function greenmanUpdate()
	local player = Isaac.GetPlayer(0);
  local room = Game():GetRoom();
	local pos;
	local sprite;

  if (greenman == nil) then
		if (CheckForEnemies()) then
			greenDelay = greenDelay - 1;

			if (greenDelay <= 0) then
				pos = room:GetGridPosition(room:GetGridIndex(Isaac:GetRandomPosition())) 
				pos = room:FindFreeTilePosition(pos, 100) 
				greenman = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, familiarList.greenman, 0, pos, Vector(0, 0), player)
				greenRoom = Game():GetLevel():GetCurrentRoomIndex()
			end
		else
			greenDelay = 10;
		end
	end
  
	if greenman ~= nil then
    
    greenDelay = greenDelay - 1;
    
    sprite = greenman:GetSprite()
    
    if greenDelay <= 0 then
      pos = room:GetGridPosition(room:GetGridIndex(Isaac:GetRandomPosition())) 
      pos = room:FindFreeTilePosition(pos, 100)
      greenman.Position = pos;
      greenDelay = 50;
      sprite:SetAnimation("Idle")
      sprite:Play("Idle", true)
      
      local entities = Isaac.GetRoomEntities();
      for i = 1, #entities do
        local enemy = entities[i]
        if enemy:IsVulnerableEnemy() then
          if greenman.Position:Distance(enemy.Position, greenman.Position) < 50 then
            local dice = math.random(1, 3);
            if dice == 1 then
              enemy:AddFreeze(EntityRef(player), 100)
            elseif dice == 2 then
              enemy:AddConfusion(EntityRef(player), 100, true)
            elseif dice == 3 then
              enemy:AddMidasFreeze(EntityRef(player), 100)
            end
          end
        end
      end
    else
      if (sprite:GetFrame() >= 5) then
        sprite:SetAnimation("Disapparate")
        sprite:Play("Disapparate", true)
      end
    end
    
    if CheckForEnemies() == false then
      greenman:Remove()
      greenman = nil
    end
	end
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
    SpawnItem(itemList.mushroom, 320, 350)
  
    SpawnItem(itemList.petRock, 370, 300)
    SpawnItem(itemList.theBeretta, 170, 300)
    
    SpawnItem(itemList.nug, 470, 250)
    SpawnItem(itemList.jellies, 420, 250)
    SpawnItem(itemList.oceanMan, 370, 250)
    SpawnItem(itemList.murph, 270, 250)
    SpawnItem(itemList.stapler, 170, 250)
    
    SpawnItem(itemList.chatter, 420, 200)
    SpawnItem(itemList.greenman, 370, 200)
    SpawnItem(itemList.ghostBill, 220, 200)
    
    SpawnItem(itemList.judo, 470, 150)
    SpawnItem(itemList.teratomo, 370, 150)
    SpawnItem(itemList.scumbo, 320, 150)
    SpawnItem(itemList.stammer, 220, 150)
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
    
    -- Teratomo reset
    if player:HasCollectible(itemList.teratomo) then
      for i = 1, #entities do
        local entity = entities[i]
        if entity.Type == EntityType.ENTITY_FAMILIAR and entity.Variant == familiarList.teratomo then
          entity:Remove();
        end
      end
      
      newTomo = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, familiarList.teratomo, 0, player.Position, Vector(0, 0), player)
    end
    
    -- Twitchy chatter reset
    if player:HasCollectible(itemList.chatter) then
      chatterBuffs = 0;
      player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
      player:EvaluateItems();
    end
    
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
  
  -- Twitchy Chatter update
  if player:HasCollectible(itemList.chatter) then
    chatterUpdate();
  end
  
  -- Mr Greenman update
  if player:HasCollectible(itemList.greenman) then
    greenmanUpdate();
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
require("code/items/collectibles/tennis");
require("code/items/collectibles/rattler");
require("code/items/collectibles/laCroix");
require("code/items/collectibles/madrinas");
require("code/items/collectibles/nugCrown");
require("code/items/collectibles/gungeonMaster");
require("code/items/collectibles/eyeForAesthetic");
require("code/items/collectibles/theCoin");
require("code/items/collectibles/crackedEgg");
require("code/items/collectibles/redShirt");
require("code/items/collectibles/mindFlood");
require("code/items/collectibles/matricide");
require("code/items/collectibles/cobaltsStreak");
require("code/items/collectibles/purpleLord");
require("code/items/collectibles/ryukaBuddy");
require("code/items/collectibles/goldHat");
require("code/items/collectibles/lootHoard");

Isaac.DebugString("Successfully loaded NLSSMod!")