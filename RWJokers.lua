SMODS.Atlas {
	key = "RWJokers_Atlas",
	path = "RWJokers_Atlas.png",
	px = 71,
	py = 95
}





-- 1 rot tree joker
SMODS.Joker {
  key = 'rottree',
  loc_txt = {
      name = 'Rot Tree',
      text = {
        "Gives {X:mult,C:white}XMult{} equal to",
        "the amount of {C:clubs{}Clubs{} cards",
        "in the played hand whenever",
        "a {C:clubs}Clubs{} card is scored"
      }
  },
  config = { extra = { Xmult = 0 }},
  rarity = 3,
  atlas = 'RWJokers_Atlas',
  pos = { x = 0, y = 0 },
  cost = 7,

  calculate = function(self,card,context)
  -- count spades
    if context.before then
      local clubs = 0
      for i = 1, #context.scoring_hand do
        if context.scoring_hand[i]:is_suit('Clubs',true) then 
          clubs = clubs + 1
        end
      end
      card.ability.extra.Xmult = clubs
    end 
  -- mult per scoring
    if context.individual and context.cardarea == G.play and context.other_card:is_suit("Clubs") then
      return {
        xmult = card.ability.extra.Xmult
      }
    end 
  -- reset mult to 0
    if context.final_scoring_step then
      card.ability.extra.Xmult = 0
      return {
        message = 'Rotting...',
        colour = G.C.BLUE,
        card = card
      }
    end
  end
}





-- 2 rivulet joker
SMODS.Joker {
  key = 'rivulet',
  loc_txt = {
      name = 'Rivulet',
      text = {
        "Gives {X:mult,C:white}XMult{} equal to",
        "the current game speed",
        "{C:inactive}(Currently {}{X:mult,C:white} X#1# {}{C:inactive}){}",
      }
  },
  config = { extra = { Xmult = 1 }},
  rarity = 3,
  atlas = 'RWJokers_Atlas',
  pos = { x = 1, y = 0 },
  cost = 7,
  loc_vars = function(self,info_queue,card)
    return {vars = {G.SETTINGS.GAMESPEED}}
  end,
  
  calculate = function(self,card,context)
    -- set the XMult but stopping change if the joker area is in use
    if not context.joker_main then
      card.ability.extra.Xmult = G.SETTINGS.GAMESPEED
    else
      return {
        xmult = card.ability.extra.Xmult 
      }
    end
  end
}





-- 3 sliver of straw joker 
SMODS.Joker {
  key = 'sostraw',
  loc_txt = {
      name = 'Sliver of Straw',
      text = {
        "This Joker gains" ,
        "{X:mult,C:white} X#2# {} Mult for every",
        "{C:attention}Ace{} card in",
        "your full deck",
        "{C:inactive}(Currently {}{X:mult,C:white} X#1# {}{C:inactive}){}"
      }
  },
  config = { extra = { Xmult = 1 , Xmultmod = 0.5 }},
  rarity = 3,
  atlas = 'RWJokers_Atlas',
  pos = { x = 0, y = 0 },
  cost = 7,
  loc_vars = function(self,info_queue,card)
  -- checking how many aces there are for the description. will be repeated again later for the actual calcing.
    local ace_tally = 0
    if G.playing_cards then
      for _, playing_card in ipairs(G.playing_cards) do 
        if playing_card:get_id() == 14 then ace_tally = ace_tally + 1 end 
      end
    end
    return {vars = {card.ability.extra.Xmultmod * ace_tally + 1, card.ability.extra.Xmultmod}}
  end,

  calculate = function(self,card,context)
  --recalculating the xmult as mentioned before. 
    if context.joker_main then
      local ace_tally = 0
      if G.playing_cards then
        for _, playing_card in ipairs(G.playing_cards) do 
          if playing_card:get_id() == 14 then ace_tally = ace_tally + 1 end 
        end
        card.ability.extra.Xmult = ace_tally * card.ability.extra.Xmultmod + 1
      end
      return {
        xmult = card.ability.extra.Xmult
      }
    end
  end
}





-- 4 seven red suns joker
SMODS.Joker {
  key = 'srsuns',
  loc_txt = {
      name = 'Seven Red Suns',
      text = {
        "If played poker hand",
        "is a {C:attention}Two Pair{},",
        "turns the lower card",
        "into a {C:attention}Gold{} card"
      }
  },
  config = { extra = { type = 'Two Pair'}},
  rarity = 2,
  atlas = 'RWJokers_Atlas',
  pos = { x = 0, y = 0 },
  cost = 6,

  calculate = function(self,card,context)
    
    if context.before and next(context.poker_hands[card.ability.extra.type]) then
      local lower_card = 100
      -- finding the lower card first
      for _, scored_card in ipairs(context.scoring_hand) do
        if 
          scored_card:get_id() < lower_card and 
          not SMODS.has_enhancement(scored_card, 'm_stone') then 
            lower_card = scored_card:get_id() 
        end
      end
      -- setting the lower card to 
      for _, scored_card in ipairs(context.scoring_hand) do
        if 
          scored_card:get_id() == lower_card and 
          not SMODS.has_enhancement(scored_card, 'm_gold') then
            SMODS.calculate_effect({message = 'Gold!', colour = G.C.MONEY}, card)
            scored_card:set_ability('m_gold',nil,true)
            G.E_MANAGER:add_event(Event({
              func = function()
                scored_card:set_ability('m_gold',nil,true)
                scored_card:juice_up()
                play_sound('coin2', 0.96 + math.random() * 0.08)
                return true
              end
            }))
        end 
      end 
    end
  end
}



-- 5 chasing winds joker
SMODS.Joker {
  key = 'cwinds',
  loc_txt = {
      name = 'Chasing Winds',
      text = {
        "Gain {C:mult}+#2#{} Mult whenever a",
        "{C:spectral}Spectral{} pack is opened",
        "{C:inactive}(Currently {}{C:mult}+#1#{}{C:inactive}){}"
      }
  },
  config = { extra = { type = 'Spectral', mult = 0, multmod = 10}},
  rarity = 2,
  atlas = 'RWJokers_Atlas',
  pos = { x = 0, y = 0 },
  cost = 5,
  loc_vars = function(self, info_queue, card)
    return { vars = {card.ability.extra.mult, card.ability.extra.multmod}}
  end,

  calculate = function(self, card ,context)
    --activate if a booster is opened and check if spectral
    if context.open_booster then
      if context.card.config.center.kind == card.ability.extra.type then
        SMODS.calculate_effect({message = 'Upgrade!', colour = G.C.MULT}, card)
        card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.multmod
      end
    end
    
    --apply mult in main loop
    if context.joker_main then 
      return {
        mult = card.ability.extra.mult
      }
    end
  end
}





-- 6 five pebbles joker
SMODS.Joker {
  key = 'fpebbles',
  loc_txt = {
      name = 'Five Pebbles',
      text = {
        "Whenever a hand is scored",
        "turn a random card into",
        "{C:clubs}#1#{} suit",
        "{C:inactive}Excluding cards that{}",
        "{C:inactive}are already #1#{}",
      }
  },
  config = { extra = {suit = 'Clubs'}},
  rarity = 2,
  atlas = 'RWJokers_Atlas',
  pos = { x = 0, y = 0 },
  cost = 6,
  loc_vars = function (self, info_queue, card)
    return {vars = {card.ability.extra.suit}}
  end,

  calculate = function (self, card, context)
    if context.final_scoring_step then
    
      local notclubs = {}
      for i = 1, #context.scoring_hand do
        if not context.scoring_hand[i]:is_suit('Clubs', true) then 
          table.insert(notclubs,context.scoring_hand[i])
        end
      end

      local findcard = 0
      if #notclubs ~= 0 then
        findcard = pseudorandom_element(notclubs, 'fpebbles')
      end
      
      if findcard ~= 0 then
        G.E_MANAGER:add_event(Event({
          func = function()
            SMODS.change_base(findcard, card.ability.extra.suit)
            findcard:juice_up()
            play_sound('tarot2', 0.96 + math.random() * 0.08)
            return true
          end
        }))
        return {
          message = "Rotting...",
          colour = G.C.BLUE
        }
      end 
    end
  end
}



-- 7 grapple worm joker
SMODS.Joker {
  key = 'grapple',
  loc_txt = {
      name = 'Grapple Worm',
      text = {
        "After a hand scores",
        "send a {C:attention}random scoring card{}",
        "back into your hand"
      }
  },
  config = { extra = {}},
  rarity = 2,
  atlas = 'RWJokers_Atlas',
  pos = { x = 0, y = 0 },
  cost = 6,

  calculate = function (self, card, context)
  -- pick random card, copy it, and emplace it.
    if context.after and context.cardarea then
      local grappled = pseudorandom_element(context.scoring_hand, 'grapple')
      G.E_MANAGER:add_event(Event({
        func = function()
          SMODS.destroy_cards(grappled, nil, nil, true)
          local copy_card = copy_card(grappled, nil, nil, G.playing_card)
          copy_card:add_to_deck()
          table.insert(G.playing_cards, copy_card)
          G.hand:emplace(copy_card)
          -- say the shit
          SMODS.calculate_effect({message = "Grappled!",colour = G.C.PERISHABLE}, card)
          return true
        end
      }))      
    end
  end
  
}
  
--hope it doesnt crash :)
      

