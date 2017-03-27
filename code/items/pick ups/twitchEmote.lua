----------------------------------------
-- Twitch Emote
----------------------------------------
-- New type of pick up
----------------------------------------

local twitchEmote = {
  pickupVariant = Isaac.GetEntityVariantByName("twitchEmote");
  sound = SFXManager();
  subTypeEmote = 1;
}

function twitchEmote:onPlayerUpdate(player)
  
end

NLSSMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, twitchEmote.onPlayerUpdate)