----------------------------------------
-- Zane Enabler
-- Any run can be zany!
----------------------------------------
-- Adds three random 'zany' items
----------------------------------------

local zaneEnabler = {
  itemID = Isaac.GetItemIdByName("Zane Enabler");
  zanyItemList = {};
  amountOfItems = 29;
}

zaneEnabler.zanyItemList = {
  CollectibleType.COLLECTIBLE_SOY_MILK,
  CollectibleType.COLLECTIBLE_PARASITE,
  CollectibleType.COLLECTIBLE_MUTANT_SPIDER,
  CollectibleType.COLLECTIBLE_SPOON_BENDER,
  CollectibleType.COLLECTIBLE_INNER_EYE,
  CollectibleType.COLLECTIBLE_MY_REFLECTION,
  CollectibleType.COLLECTIBLE_GUILLOTINE,
  CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR,
  CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE,
  CollectibleType.COLLECTIBLE_20_20,
  CollectibleType.COLLECTIBLE_MISSING_NO,
  CollectibleType.COLLECTIBLE_SACRED_HEART,
  CollectibleType.COLLECTIBLE_3_DOLLAR_BILL,
  CollectibleType.COLLECTIBLE_FRUIT_CAKE,
  CollectibleType.COLLECTIBLE_TINY_PLANET,
  CollectibleType.COLLECTIBLE_COMPOUND_FRACTURE,
  CollectibleType.COLLECTIBLE_THE_WIZ,
  CollectibleType.COLLECTIBLE_CONTINUUM,
  CollectibleType.COLLECTIBLE_CHAOS,
  CollectibleType.COLLECTIBLE_RUBBER_CEMENT,
  CollectibleType.COLLECTIBLE_LEAD_PENCIL,
  CollectibleType.COLLECTIBLE_EUTHANASIA,
  CollectibleType.COLLECTIBLE_JACOBS_LADDER,
  CollectibleType.COLLECTIBLE_EYE_OF_BELIAL,
  CollectibleType.COLLECTIBLE_VARICOSE_VEINS,
  CollectibleType.COLLECTIBLE_DR_FETUS,
  CollectibleType.COLLECTIBLE_SAD_BOMBS,
  CollectibleType.COLLECTIBLE_LOKIS_HORNS,
  CollectibleType.COLLECTIBLE_ANTI_GRAVITY
  }

function zaneEnabler:useItem()
  local player = Isaac.GetPlayer(0);
  
  math.randomseed(Game():GetFrameCount())
  for i = 1, 3 do
    player:AddCollectible(GetZanyItem(math.random(zaneEnabler.amountOfItems)), 0, false)
  end
  
  player:RemoveCollectible(zaneEnabler.itemID);
  return true;
end

function GetZanyItem(index)
  return zaneEnabler.zanyItemList[index];
end

function zaneEnabler:onGameStart()
  SpawnPreviewItem(zaneEnabler.itemID)
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, zaneEnabler.onGameStart)
NLSSMod:AddCallback(ModCallbacks.MC_USE_ITEM, zaneEnabler.useItem, zaneEnabler.itemID)