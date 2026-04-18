-- BiS.lua — Best enchant/gem recommendations per class+spec combination
-- Enchant IDs are SpellItemEnchantment effect IDs as they appear in item links.
-- These are NOT spell IDs — they come from the enchantId field of
-- |Hitem:itemID:enchantId:gem1:gem2:gem3:gem4:...|h
--
-- To update for a new phase: add/change IDs in the tables below.
-- ids = list of ACCEPTABLE enchant effect IDs (any match = correct)

RaidInspectorBiS = {}
local B = RaidInspectorBiS

-- ── Enchant Effect IDs (SpellItemEnchantment) ────────────────────────────────
-- Common TBC enchants referenced below (for readability)
local ENC = {
    -- Head (Glyph/Arcanum from TBC factions — Revered)
    ARCANUM_FEROCITY        = 3003,  -- +34 AP / +16 hit (Cenarion Expedition)
    ARCANUM_RENEWAL         = 3001,  -- +35 healing / +12 spell / +7 mp5 (Honor Hold/Thrallmar)
    ARCANUM_POWER           = 3002,  -- +22 spell dmg / +14 hit (Sha'tar)
    ARCANUM_PROTECTION      = 2999,  -- +16 def / +17 dodge (Keepers of Time)
    ARCANUM_GLADIATOR       = 3004,  -- +18 stam / +20 resilience (SSO)

    -- Head (Resistance Warding Glyphs — Honored)
    GLYPH_ARCANE_WARDING    = 3006,  -- +20 arcane resist
    GLYPH_FIRE_WARDING      = 3007,  -- +20 fire resist
    GLYPH_FROST_WARDING     = 3008,  -- +20 frost resist
    GLYPH_SHADOW_WARDING    = 3009,  -- +20 shadow resist
    GLYPH_NATURE_WARDING    = 3005,  -- +20 nature resist

    -- Shoulder (Greater Inscriptions — Aldor Exalted)
    GREATER_INS_VENGEANCE   = 2986,  -- +30 AP / +10 crit (phys dps)
    GREATER_INS_DISCIPLINE  = 2982,  -- +18 spell dmg / +10 spell crit (caster)
    GREATER_INS_FAITH       = 2980,  -- +33 healing / +11 spell / +4 mp5 (healer)
    GREATER_INS_WARDING     = 2978,  -- +15 dodge / +10 def (tank)
    -- Shoulder (Greater Inscriptions — Scryers Exalted)
    GREATER_INS_ORBS        = 2995,  -- +15 spell crit / +12 spell dmg (caster)
    GREATER_INS_BLADE       = 2997,  -- +15 crit / +20 AP (phys dps)
    GREATER_INS_KNIGHT      = 2991,  -- +15 def / +10 dodge (tank)
    GREATER_INS_ORACLE      = 2993,  -- +6 mp5 / +22 healing (healer)
    -- Shoulder (Lesser Inscriptions — Aldor Honored)
    INS_VENGEANCE           = 2983,  -- +26 AP (phys dps)
    INS_DISCIPLINE          = 2981,  -- +15 spell dmg (caster)
    INS_FAITH               = 2979,  -- +29 healing / +10 spell (healer)
    INS_WARDING             = 2977,  -- +13 dodge (tank)
    -- Shoulder (Lesser Inscriptions — Scryers Honored)
    INS_BLADE               = 2996,  -- +13 crit (phys dps)
    INS_ORBS                = 2994,  -- +13 spell crit (caster)
    INS_KNIGHT              = 2990,  -- +13 def (tank)
    INS_ORACLE              = 2992,  -- +5 mp5 (healer)
    -- Shoulder (Naxxramas — Sapphiron drops)
    MIGHT_OF_THE_SCOURGE    = 2717,  -- +26 AP / +14 crit (phys dps)
    POWER_OF_THE_SCOURGE    = 2721,  -- +15 spell dmg / +14 spell crit (caster)
    RESILIENCE_OF_THE_SCOURGE = 2715, -- +31 healing / +5 mp5 (healer)
    FORTITUDE_OF_THE_SCOURGE = 2716,  -- +16 dodge / +100 armor (tank)
    -- Shoulder (Zul'Gurub — Zandalar Signets)
    SIGNET_SERENITY         = 2604,  -- +33 healing / +11 spell dmg (healer)
    SIGNET_MOJO             = 2605,  -- +18 spell dmg (caster dps)
    SIGNET_MIGHT            = 2606,  -- +30 AP (phys dps)

    -- Chest
    ENCHANT_CHEST_EXCEPTIONAL_STATS  = 2661,  -- +6 all stats
    ENCHANT_CHEST_EXCEPTIONAL_HEALTH = 2659,  -- +150 health (tank alt)
    ENCHANT_CHEST_MAJOR_RESILIENCE   = 2933,  -- +15 resilience (PvP)

    -- Legs (Leatherworking — DPS)
    NETHERCOBRA_LEG_ARMOR   = 3012,  -- +50 AP / +12 crit (phys dps best)
    COBRAHIDE_LEG_ARMOR     = 3010,  -- +40 AP / +10 crit (phys dps lesser)
    -- Legs (Leatherworking — Tank)
    NETHERCLEFT_LEG_ARMOR   = 3013,  -- +40 stam / +12 agi (tank best)
    CLEFTHIDE_LEG_ARMOR     = 3011,  -- +30 stam / +10 agi (tank lesser)
    -- Legs (Tailoring — Caster)
    RUNIC_SPELLTHREAD       = 2748,  -- +35 spell dmg / +20 stam (caster dps best)
    MYSTIC_SPELLTHREAD      = 2747,  -- +25 spell dmg / +15 stam (caster dps lesser)
    -- Legs (Tailoring — Healer)
    GOLDEN_SPELLTHREAD      = 2746,  -- +66 healing / +22 spell / +20 stam (healer best)
    SILVER_SPELLTHREAD      = 2745,  -- +46 healing / +16 spell / +15 stam (healer lesser)

    -- Feet
    ENCHANT_BOOTS_CATS_SWIFTNESS = 2939,  -- +6 agi / minor speed
    ENCHANT_BOOTS_BOARS_SPEED    = 2940,  -- +9 stam / minor speed
    ENCHANT_BOOTS_DEXTERITY      = 2657,  -- +12 agi
    ENCHANT_BOOTS_FORTITUDE      = 2649,  -- +12 stam
    ENCHANT_BOOTS_SUREFOOTED     = 2658,  -- +10 hit / +10 crit / snare resist
    ENCHANT_BOOTS_VITALITY       = 2656,  -- +4 hp5 / +4 mp5 (healer)

    -- Wrists
    ENCHANT_BRACER_SPELLPOWER   = 2650,  -- +15 spell dmg
    ENCHANT_BRACER_HEALING      = 2617,  -- +30 healing / +10 spell dmg
    ENCHANT_BRACER_ASSAULT      = 1593,  -- +24 AP (phys)
    ENCHANT_BRACER_STATS        = 1891,  -- +4 all stats
    ENCHANT_BRACER_FORTITUDE    = 2649,  -- +12 stamina (tank)
    ENCHANT_BRACER_INTELLECT    = 369,   -- +12 intellect (healer)
    ENCHANT_BRACER_STRENGTH     = 2647,  -- +12 strength (warrior/paladin)

    -- Hands
    ENCHANT_GLOVES_SUPERIOR_AGILITY = 2564,  -- +15 agi
    ENCHANT_GLOVES_MAJOR_SPELLPOWER = 2937,  -- +20 spell dmg
    ENCHANT_GLOVES_THREAT           = 2613,  -- +2% threat (tank)
    ENCHANT_GLOVES_MAJOR_STRENGTH   = 684,   -- +15 strength

    -- Back
    ENCHANT_CLOAK_GREATER_AGILITY   = 368,   -- +12 agi (phys)
    ENCHANT_CLOAK_SUBTLETY          = 2621,  -- -2% threat reduction
    ENCHANT_CLOAK_SPELL_PENETRATION = 2938,  -- +20 spell pen (caster)

    -- Hands (additional)
    ENCHANT_GLOVES_ASSAULT          = 1594,  -- +26 AP
    ENCHANT_GLOVES_SPELL_STRIKE     = 2935,  -- +15 spell hit rating
    ENCHANT_GLOVES_BLASTING         = 2934,  -- +10 spell crit rating
    ENCHANT_GLOVES_MAJOR_HEALING    = 2322,  -- +35 healing / +12 spell

    -- Back (additional)
    ENCHANT_CLOAK_DODGE             = 2622,  -- +12 dodge rating
    ENCHANT_CLOAK_MAJOR_ARMOR       = 2662,  -- +120 armor
    ENCHANT_CLOAK_STEELWEAVE        = 2648,  -- +12 def rating

    -- Main Hand weapons (1H)
    ENCHANT_WEAPON_MONGOOSE         = 2673,  -- 120 agi / 2% haste proc (best phys)
    ENCHANT_WEAPON_MAJOR_SPELLPOWER = 2669,  -- +40 spell dmg (caster)
    ENCHANT_WEAPON_SUNFIRE          = 2671,  -- +50 fire/arcane dmg (fire mage)
    ENCHANT_WEAPON_SOULFROST        = 2672,  -- +54 shadow/frost dmg (lock/frost mage)
    ENCHANT_WEAPON_SPELLSURGE       = 2674,  -- mana restore proc (healer alt)
    ENCHANT_WEAPON_BATTLEMASTER     = 2675,  -- HP proc (tank alt)
    ENCHANT_WEAPON_CRUSADER         = 1900,  -- +100 str proc (classic)
    ENCHANT_WEAPON_MAJOR_INTELLECT  = 2666,  -- +30 int
    ENCHANT_WEAPON_GREATER_AGILITY  = 3222,  -- +20 agi
    ENCHANT_WEAPON_POTENCY          = 2668,  -- +20 str
    ENCHANT_WEAPON_MAJOR_HEALING    = 2343,  -- +81 healing / +27 spell dmg
    ENCHANT_WEAPON_HEALING_POWER    = 2505,  -- +55 healing / +19 spell dmg (vanilla MC)
    ENCHANT_WEAPON_SPELL_POWER_30   = 2504,  -- +30 spell damage (vanilla)
    ENCHANT_WEAPON_MIGHTY_SPIRIT    = 2567,  -- +20 spirit (vanilla)
    ENCHANT_WEAPON_EXECUTIONER      = 3225,  -- ignore 840 armor proc (Sunwell patch)
    -- Two-Handed weapons
    ENCHANT_2H_SAVAGERY             = 2667,  -- +70 AP (2H only)
    ENCHANT_2H_MAJOR_AGILITY       = 2670,  -- +35 agi (2H only)

    -- Off Hand (shields)
    ENCHANT_SHIELD_TOUGH_SHIELD     = 2653,  -- +18 block value
    ENCHANT_SHIELD_RESILIENCE       = 3229,  -- +12 resilience (PvP)
    ENCHANT_SHIELD_MAJOR_STAMINA    = 1071,  -- +18 stamina (tank shield)
    ENCHANT_SHIELD_BLOCK            = 2655,  -- +15 block rating
    ENCHANT_SHIELD_INTELLECT        = 2654,  -- +12 intellect

    -- Ranged (hunter scopes)
    STABILIZED_ETERNIUM_SCOPE       = 2724,  -- +28 crit rating
    KHORIUM_SCOPE                   = 2723,  -- +12 damage
    BIZNICKS_SCOPE                  = 2523,  -- +30 hit rating (engineering)
}

-- ── Gem Color IDs ─────────────────────────────────────────────────────────────
-- Maps TBC gem item IDs → socket color category
-- Used to validate whether a socketed gem matches the spec recommendation.
-- Note: Prismatic gems (Nightmare Tear, etc.) satisfy any socket color.

B.GEM_COLORS = {
    -- Meta gems
    [25896] = "META",  -- Relentless Earthstorm Diamond
    [25901] = "META",  -- Brute Force Meta
    [25890] = "META",  -- Mystical Skyfire Diamond
    [32409] = "META",  -- Swift Skyfire Diamond
    [32410] = "META",  -- Ember Skyfire Diamond
    [32411] = "META",  -- Chaotic Skyfire Diamond (caster)
    [32412] = "META",  -- Thundering Skyfire Diamond
    [34220] = "META",  -- Destructive Skyfire Diamond
    [34222] = "META",  -- Insightful Earthstorm Diamond (healer mana)

    -- Red gems (strength/agility/spell dmg/crit)
    [24027] = "RED",   -- Bold Living Ruby (+8 str)
    [24030] = "RED",   -- Subtle Living Ruby (dodge)
    [24031] = "RED",   -- Flashing Living Ruby (parry)
    [24032] = "RED",   -- Bright Living Ruby (AP)
    [28363] = "RED",   -- Bold Stone of Blades (engineering gem, +8 str)
    [24036] = "RED",   -- Teardrop Living Ruby (+18 healing)
    [24037] = "RED",   -- Runed Living Ruby (+9 spell dmg)
    [24038] = "RED",   -- Crimson Spinel (+9 str, phase 3+)

    -- Blue gems (stamina/intellect/mp5/spell pen)
    [24047] = "BLUE",  -- Sparkling Star of Elune (+9 mp5)
    [24048] = "BLUE",  -- Solid Star of Elune (+12 sta)
    [24050] = "BLUE",  -- Lustrous Star of Elune (mp5)
    [24051] = "BLUE",  -- Stormy Star of Elune (spell pen)
    [24054] = "BLUE",  -- Royal Nightseye (+9 healing / +2 mp5)
    [32193] = "BLUE",  -- Solid Empyrean Sapphire (+12 sta, phase 3+)

    -- Yellow gems (hit/spell hit/haste/resilience)
    [24057] = "YELLOW", -- Rigid Dawnstone (+8 hit)
    [24058] = "YELLOW", -- Smooth Dawnstone (+8 crit)
    [24059] = "YELLOW", -- Gleaming Dawnstone (+8 crit)
    [24060] = "YELLOW", -- Thick Dawnstone (+6 def)
    [24061] = "YELLOW", -- Mystic Dawnstone (resilience)
    [24062] = "YELLOW", -- Brilliant Dawnstone (+8 int)
    [32196] = "YELLOW", -- Brilliant Lionseye (+8 int, phase 3+)
    [32212] = "YELLOW", -- Rigid Lionseye (+8 hit, phase 3+)

    -- Orange gems (str+hit, AP+crit, etc.) — satisfy red or yellow sockets
    [24065] = "ORANGE", -- Inscribed Noble Topaz (+5 str / +4 crit)
    [24066] = "ORANGE", -- Potent Noble Topaz (+5 spell dmg / +4 crit)
    [24067] = "ORANGE", -- Glinting Noble Topaz (+5 agi / +4 hit)
    [24068] = "ORANGE", -- Reckless Noble Topaz (+5 spell dmg / +3 haste)
    [24069] = "ORANGE", -- Veiled Noble Topaz (+5 spell dmg / +4 hit)

    -- Purple gems (str+sta, spell+sta, etc.) — satisfy red or blue sockets
    [24071] = "PURPLE", -- Shifting Nightseye (+4 str / +6 sta)
    [24072] = "PURPLE", -- Balanced Nightseye (AP+sta)
    [24073] = "PURPLE", -- Glowing Nightseye (+5 spell dmg / +6 sta)
    [24074] = "PURPLE", -- Infused Nightseye (healing+mp5)

    -- Green gems — satisfy yellow or blue sockets
    [24077] = "GREEN",  -- Dazzling Talasite (+4 int / +2 mp5)
    [24078] = "GREEN",  -- Jagged Talasite (+6 crit / +6 sta)
    [24079] = "GREEN",  -- Radiant Talasite (spell pen+mp5)
    [24080] = "GREEN",  -- Enduring Talasite (def+sta)
    [24081] = "GREEN",  -- Steady Talasite (hit+sta)
    [24082] = "GREEN",  -- Turbid Talasite (spell pen+sta)

    -- Prismatic — satisfies any socket color
    [25897] = "PRISMATIC",  -- Nightmare Tear (+2 all stats? verify)
}

-- Helper: does this gem satisfy a socket of the given color?
function B.GemSatisfiesSocket(gemId, socketColor)
    local gemColor = B.GEM_COLORS[gemId]
    if not gemColor then return false end
    if gemColor == "PRISMATIC" then return true end
    if socketColor == "META" then return gemColor == "META" end
    -- Orange satisfies RED or YELLOW; Purple satisfies RED or BLUE; Green satisfies YELLOW or BLUE
    if gemColor == "ORANGE" then return socketColor == "RED"    or socketColor == "YELLOW" end
    if gemColor == "PURPLE" then return socketColor == "RED"    or socketColor == "BLUE"   end
    if gemColor == "GREEN"  then return socketColor == "YELLOW" or socketColor == "BLUE"   end
    return gemColor == socketColor
end

-- ── BiS Enchant Database ──────────────────────────────────────────────────────
-- Structure: B.ENCHANTS[class][specTab][slotId] = { ids={...}, name="..." }
-- specTab: 1/2/3 matching Spec.TAB_NAMES order
-- ids: list of acceptable enchant spell IDs (any match = passes)

B.ENCHANTS = {}

-- ── WARRIOR ───────────────────────────────────────────────────────────────────
-- Tab 1=Arms, Tab 2=Fury, Tab 3=Protection
B.ENCHANTS["WARRIOR"] = {
    [1] = { -- Arms (often uses 2H weapons)
        [1]  = { ids={ENC.ARCANUM_FEROCITY},                          name="Arcanum of Ferocity" },
        [3]  = { ids={ENC.GREATER_INS_VENGEANCE, ENC.GREATER_INS_BLADE, ENC.INS_VENGEANCE, ENC.INS_BLADE, ENC.MIGHT_OF_THE_SCOURGE, ENC.SIGNET_MIGHT}, name="Inscription of Vengeance / Blade / Might of the Scourge / Signet of Might" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},           name="+6 All Stats" },
        [7]  = { ids={ENC.NETHERCOBRA_LEG_ARMOR, ENC.COBRAHIDE_LEG_ARMOR}, name="Nethercobra / Cobrahide Leg Armor" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_SUREFOOTED, ENC.ENCHANT_BOOTS_CATS_SWIFTNESS, ENC.ENCHANT_BOOTS_DEXTERITY}, name="Surefooted / Cat's Swiftness / Dexterity" },
        [9]  = { ids={ENC.ENCHANT_BRACER_STRENGTH, ENC.ENCHANT_BRACER_ASSAULT, ENC.ENCHANT_BRACER_STATS}, name="+12 Strength / Assault / Stats" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_STRENGTH, ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY, ENC.ENCHANT_GLOVES_ASSAULT}, name="Major Strength / Agility / Assault" },
        [15] = { ids={ENC.ENCHANT_CLOAK_GREATER_AGILITY, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Greater Agility / Subtlety" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_WEAPON_EXECUTIONER, ENC.ENCHANT_2H_SAVAGERY, ENC.ENCHANT_2H_MAJOR_AGILITY, ENC.ENCHANT_WEAPON_CRUSADER}, name="Mongoose / Executioner / Savagery" },
    },
    [2] = { -- Fury (dual wield)
        [1]  = { ids={ENC.ARCANUM_FEROCITY},                          name="Arcanum of Ferocity" },
        [3]  = { ids={ENC.GREATER_INS_VENGEANCE, ENC.GREATER_INS_BLADE, ENC.INS_VENGEANCE, ENC.INS_BLADE, ENC.MIGHT_OF_THE_SCOURGE, ENC.SIGNET_MIGHT}, name="Inscription of Vengeance / Blade / Might of the Scourge / Signet of Might" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},           name="+6 All Stats" },
        [7]  = { ids={ENC.NETHERCOBRA_LEG_ARMOR, ENC.COBRAHIDE_LEG_ARMOR}, name="Nethercobra / Cobrahide Leg Armor" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_SUREFOOTED, ENC.ENCHANT_BOOTS_CATS_SWIFTNESS, ENC.ENCHANT_BOOTS_DEXTERITY}, name="Surefooted / Cat's Swiftness / Dexterity" },
        [9]  = { ids={ENC.ENCHANT_BRACER_STRENGTH, ENC.ENCHANT_BRACER_ASSAULT, ENC.ENCHANT_BRACER_STATS}, name="+12 Strength / Assault / Stats" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_STRENGTH, ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY, ENC.ENCHANT_GLOVES_ASSAULT}, name="Major Strength / Agility / Assault" },
        [15] = { ids={ENC.ENCHANT_CLOAK_GREATER_AGILITY, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Greater Agility / Subtlety" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_WEAPON_EXECUTIONER, ENC.ENCHANT_WEAPON_CRUSADER, ENC.ENCHANT_WEAPON_GREATER_AGILITY}, name="Mongoose / Executioner / Crusader" },
        [17] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_WEAPON_EXECUTIONER, ENC.ENCHANT_WEAPON_CRUSADER, ENC.ENCHANT_WEAPON_GREATER_AGILITY}, name="Mongoose / Executioner / Crusader" },
    },
    [3] = { -- Protection
        [1]  = { ids={ENC.ARCANUM_PROTECTION},                        name="Arcanum of the Protector" },
        [3]  = { ids={ENC.GREATER_INS_WARDING, ENC.GREATER_INS_KNIGHT, ENC.INS_WARDING, ENC.INS_KNIGHT, ENC.FORTITUDE_OF_THE_SCOURGE, ENC.SIGNET_MIGHT}, name="Inscription of Warding / Knight / Fortitude of the Scourge / Signet of Might" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS, ENC.ENCHANT_CHEST_EXCEPTIONAL_HEALTH}, name="+6 Stats / +150 Health" },
        [7]  = { ids={ENC.NETHERCLEFT_LEG_ARMOR, ENC.CLEFTHIDE_LEG_ARMOR, ENC.NETHERCOBRA_LEG_ARMOR}, name="Nethercleft / Clefthide / Nethercobra" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED, ENC.ENCHANT_BOOTS_SUREFOOTED, ENC.ENCHANT_BOOTS_DEXTERITY}, name="Fortitude / Boar's Speed / Surefooted" },
        [9]  = { ids={ENC.ENCHANT_BRACER_FORTITUDE, ENC.ENCHANT_BRACER_STRENGTH, ENC.ENCHANT_BRACER_STATS, ENC.ENCHANT_BRACER_ASSAULT}, name="Fortitude / +12 Strength / Stats / Assault" },
        [10] = { ids={ENC.ENCHANT_GLOVES_THREAT, ENC.ENCHANT_GLOVES_MAJOR_STRENGTH, ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY}, name="Threat / Strength / Agility" },
        [15] = { ids={ENC.ENCHANT_CLOAK_DODGE, ENC.ENCHANT_CLOAK_SUBTLETY, ENC.ENCHANT_CLOAK_GREATER_AGILITY, ENC.ENCHANT_CLOAK_STEELWEAVE, ENC.ENCHANT_CLOAK_MAJOR_ARMOR}, name="Dodge / Subtlety / Agility / Steelweave / Armor" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_WEAPON_EXECUTIONER, ENC.ENCHANT_WEAPON_POTENCY, ENC.ENCHANT_WEAPON_CRUSADER, ENC.ENCHANT_WEAPON_BATTLEMASTER}, name="Mongoose / Executioner / Potency / Battlemaster" },
        [17] = { ids={ENC.ENCHANT_SHIELD_MAJOR_STAMINA, ENC.ENCHANT_SHIELD_BLOCK, ENC.ENCHANT_SHIELD_TOUGH_SHIELD}, name="Major Stamina / Block / Tough Shield" },
    },
}

-- ── PALADIN ───────────────────────────────────────────────────────────────────
-- Tab 1=Holy, Tab 2=Protection, Tab 3=Retribution
B.ENCHANTS["PALADIN"] = {
    [1] = { -- Holy
        [1]  = { ids={ENC.ARCANUM_RENEWAL},                           name="Arcanum of Renewal" },
        [3]  = { ids={ENC.GREATER_INS_FAITH, ENC.GREATER_INS_ORACLE, ENC.INS_FAITH, ENC.INS_ORACLE, ENC.RESILIENCE_OF_THE_SCOURGE, ENC.SIGNET_SERENITY}, name="Inscription of Faith / Oracle / Resilience of the Scourge / Signet of Serenity" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},           name="+6 All Stats" },
        [7]  = { ids={ENC.GOLDEN_SPELLTHREAD, ENC.SILVER_SPELLTHREAD}, name="Golden / Silver Spellthread" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_VITALITY, ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Vitality / Fortitude / Boar's Speed" },
        [9]  = { ids={ENC.ENCHANT_BRACER_HEALING, ENC.ENCHANT_BRACER_SPELLPOWER, ENC.ENCHANT_BRACER_STATS, ENC.ENCHANT_BRACER_INTELLECT}, name="+30 Healing / +15 SP / Stats / +12 Intellect" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER, ENC.ENCHANT_GLOVES_MAJOR_HEALING, ENC.ENCHANT_GLOVES_BLASTING}, name="+20 Spell Power / +35 Healing / Blasting" },
        [15] = { ids={ENC.ENCHANT_CLOAK_SUBTLETY, ENC.ENCHANT_CLOAK_MAJOR_ARMOR}, name="Subtlety / Major Armor" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_HEALING, ENC.ENCHANT_WEAPON_SPELLSURGE, ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_MAJOR_INTELLECT, ENC.ENCHANT_WEAPON_HEALING_POWER, ENC.ENCHANT_WEAPON_MIGHTY_SPIRIT}, name="Major Healing / Spellsurge / SP / Intellect / +55 Healing / +20 Spirit" },
        [17] = { ids={ENC.ENCHANT_SHIELD_INTELLECT, ENC.ENCHANT_SHIELD_MAJOR_STAMINA}, name="Intellect / Major Stamina (Shield)" },
    },
    [2] = { -- Protection (prot paladins use SP for threat — spell enchants are valid)
        [1]  = { ids={ENC.ARCANUM_PROTECTION, ENC.ARCANUM_POWER},     name="Arcanum of Protector / Power" },
        [3]  = { ids={ENC.GREATER_INS_WARDING, ENC.GREATER_INS_KNIGHT, ENC.INS_WARDING, ENC.INS_KNIGHT, ENC.GREATER_INS_DISCIPLINE, ENC.GREATER_INS_ORBS, ENC.INS_DISCIPLINE, ENC.INS_ORBS, ENC.FORTITUDE_OF_THE_SCOURGE, ENC.POWER_OF_THE_SCOURGE, ENC.SIGNET_MOJO}, name="Inscription of Warding / Discipline / Scourge / Signet of Mojo" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS, ENC.ENCHANT_CHEST_EXCEPTIONAL_HEALTH}, name="+6 Stats / +150 Health" },
        [7]  = { ids={ENC.NETHERCLEFT_LEG_ARMOR, ENC.CLEFTHIDE_LEG_ARMOR, ENC.RUNIC_SPELLTHREAD, ENC.MYSTIC_SPELLTHREAD}, name="Nethercleft / Clefthide / Spellthread" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED, ENC.ENCHANT_BOOTS_SUREFOOTED}, name="Fortitude / Boar's Speed / Surefooted" },
        [9]  = { ids={ENC.ENCHANT_BRACER_FORTITUDE, ENC.ENCHANT_BRACER_STATS, ENC.ENCHANT_BRACER_SPELLPOWER}, name="Fortitude / Stats / Spellpower" },
        [10] = { ids={ENC.ENCHANT_GLOVES_THREAT, ENC.ENCHANT_GLOVES_MAJOR_STRENGTH, ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER, ENC.ENCHANT_GLOVES_SPELL_STRIKE}, name="Threat / Strength / Spell Power" },
        [15] = { ids={ENC.ENCHANT_CLOAK_DODGE, ENC.ENCHANT_CLOAK_SUBTLETY, ENC.ENCHANT_CLOAK_STEELWEAVE, ENC.ENCHANT_CLOAK_MAJOR_ARMOR, ENC.ENCHANT_CLOAK_GREATER_AGILITY}, name="Dodge / Subtlety / Steelweave / Major Armor / Greater Agility" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_BATTLEMASTER, ENC.ENCHANT_WEAPON_SPELLSURGE}, name="Major Spell Power / Battlemaster / Spellsurge" },
        [17] = { ids={ENC.ENCHANT_SHIELD_MAJOR_STAMINA, ENC.ENCHANT_SHIELD_BLOCK, ENC.ENCHANT_SHIELD_TOUGH_SHIELD, ENC.ENCHANT_SHIELD_INTELLECT}, name="Major Stamina / Block / Intellect" },
    },
    [3] = { -- Retribution (2H weapon — some ret paladins use SP for Seal threat)
        [1]  = { ids={ENC.ARCANUM_FEROCITY},                          name="Arcanum of Ferocity" },
        [3]  = { ids={ENC.GREATER_INS_VENGEANCE, ENC.GREATER_INS_BLADE, ENC.INS_VENGEANCE, ENC.INS_BLADE, ENC.MIGHT_OF_THE_SCOURGE, ENC.SIGNET_MIGHT}, name="Inscription of Vengeance / Blade / Might of the Scourge / Signet of Might" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},           name="+6 All Stats" },
        [7]  = { ids={ENC.NETHERCOBRA_LEG_ARMOR, ENC.COBRAHIDE_LEG_ARMOR}, name="Nethercobra / Cobrahide Leg Armor" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_SUREFOOTED, ENC.ENCHANT_BOOTS_CATS_SWIFTNESS, ENC.ENCHANT_BOOTS_DEXTERITY}, name="Surefooted / Cat's Swiftness / Dexterity" },
        [9]  = { ids={ENC.ENCHANT_BRACER_STRENGTH, ENC.ENCHANT_BRACER_ASSAULT, ENC.ENCHANT_BRACER_STATS},  name="+12 Strength / Assault / Stats" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_STRENGTH, ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY, ENC.ENCHANT_GLOVES_ASSAULT}, name="Major Strength / Superior Agility / Assault" },
        [15] = { ids={ENC.ENCHANT_CLOAK_GREATER_AGILITY, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Greater Agility / Subtlety" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_WEAPON_EXECUTIONER, ENC.ENCHANT_2H_SAVAGERY, ENC.ENCHANT_WEAPON_CRUSADER, ENC.ENCHANT_2H_MAJOR_AGILITY}, name="Mongoose / Executioner / Savagery" },
    },
}

-- ── HUNTER ────────────────────────────────────────────────────────────────────
-- Tab 1=Beast Mastery, Tab 2=Marksmanship, Tab 3=Survival
-- All hunter specs share similar gear enchants
local hunterEnchants = {
    [1]  = { ids={ENC.ARCANUM_FEROCITY},                              name="Arcanum of Ferocity" },
    [3]  = { ids={ENC.GREATER_INS_VENGEANCE, ENC.GREATER_INS_BLADE, ENC.INS_VENGEANCE, ENC.INS_BLADE, ENC.MIGHT_OF_THE_SCOURGE, ENC.SIGNET_MIGHT}, name="Inscription of Vengeance / Blade / Might of the Scourge / Signet of Might" },
    [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},               name="+6 All Stats" },
    [7]  = { ids={ENC.NETHERCOBRA_LEG_ARMOR, ENC.COBRAHIDE_LEG_ARMOR}, name="Nethercobra / Cobrahide Leg Armor" },
    [8]  = { ids={ENC.ENCHANT_BOOTS_SUREFOOTED, ENC.ENCHANT_BOOTS_DEXTERITY, ENC.ENCHANT_BOOTS_CATS_SWIFTNESS}, name="Surefooted / Dexterity / Cat's Swiftness" },
    [9]  = { ids={ENC.ENCHANT_BRACER_ASSAULT, ENC.ENCHANT_BRACER_STATS}, name="Assault / Stats" },
    [10] = { ids={ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY, ENC.ENCHANT_GLOVES_ASSAULT}, name="Superior Agility / Assault" },
    [15] = { ids={ENC.ENCHANT_CLOAK_GREATER_AGILITY, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Greater Agility / Subtlety" },
    [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_WEAPON_GREATER_AGILITY, ENC.ENCHANT_2H_SAVAGERY, ENC.ENCHANT_2H_MAJOR_AGILITY}, name="Mongoose / Greater Agility / Savagery" },
    [18] = { ids={ENC.STABILIZED_ETERNIUM_SCOPE, ENC.KHORIUM_SCOPE, ENC.BIZNICKS_SCOPE}, name="Stabilized Eternium / Khorium Scope" },
}
B.ENCHANTS["HUNTER"] = { [1]=hunterEnchants, [2]=hunterEnchants, [3]=hunterEnchants }

-- ── ROGUE ─────────────────────────────────────────────────────────────────────
-- Tab 1=Assassination, Tab 2=Combat, Tab 3=Subtlety
local rogueEnchants = {
    [1]  = { ids={ENC.ARCANUM_FEROCITY},                              name="Arcanum of Ferocity" },
    [3]  = { ids={ENC.GREATER_INS_VENGEANCE, ENC.GREATER_INS_BLADE, ENC.INS_VENGEANCE, ENC.INS_BLADE, ENC.MIGHT_OF_THE_SCOURGE, ENC.SIGNET_MIGHT}, name="Inscription of Vengeance / Blade / Might of the Scourge / Signet of Might" },
    [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},               name="+6 All Stats" },
    [7]  = { ids={ENC.NETHERCOBRA_LEG_ARMOR, ENC.COBRAHIDE_LEG_ARMOR}, name="Nethercobra / Cobrahide Leg Armor" },
    [8]  = { ids={ENC.ENCHANT_BOOTS_CATS_SWIFTNESS, ENC.ENCHANT_BOOTS_SUREFOOTED, ENC.ENCHANT_BOOTS_DEXTERITY}, name="Cat's Swiftness / Surefooted / Dexterity" },
    [9]  = { ids={ENC.ENCHANT_BRACER_ASSAULT, ENC.ENCHANT_BRACER_STATS}, name="Assault / Stats" },
    [10] = { ids={ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY, ENC.ENCHANT_GLOVES_ASSAULT}, name="Superior Agility / Assault" },
    [15] = { ids={ENC.ENCHANT_CLOAK_GREATER_AGILITY, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Greater Agility / Subtlety" },
    [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_WEAPON_EXECUTIONER, ENC.ENCHANT_WEAPON_GREATER_AGILITY, ENC.ENCHANT_WEAPON_CRUSADER}, name="Mongoose / Executioner / Crusader" },
    [17] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_WEAPON_EXECUTIONER, ENC.ENCHANT_WEAPON_GREATER_AGILITY, ENC.ENCHANT_WEAPON_CRUSADER}, name="Mongoose / Executioner / Crusader" },
}
B.ENCHANTS["ROGUE"] = { [1]=rogueEnchants, [2]=rogueEnchants, [3]=rogueEnchants }

-- ── PRIEST ────────────────────────────────────────────────────────────────────
-- Tab 1=Discipline, Tab 2=Holy, Tab 3=Shadow
local priestHealEnchants = {
    [1]  = { ids={ENC.ARCANUM_RENEWAL},                               name="Arcanum of Renewal" },
    [3]  = { ids={ENC.GREATER_INS_FAITH, ENC.GREATER_INS_ORACLE, ENC.INS_FAITH, ENC.INS_ORACLE, ENC.RESILIENCE_OF_THE_SCOURGE, ENC.SIGNET_SERENITY}, name="Inscription of Faith / Oracle / Resilience of the Scourge / Signet of Serenity" },
    [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},               name="+6 All Stats" },
    [7]  = { ids={ENC.GOLDEN_SPELLTHREAD, ENC.SILVER_SPELLTHREAD},    name="Golden / Silver Spellthread" },
    [8]  = { ids={ENC.ENCHANT_BOOTS_VITALITY, ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Vitality / Fortitude / Boar's Speed" },
    [9]  = { ids={ENC.ENCHANT_BRACER_HEALING, ENC.ENCHANT_BRACER_SPELLPOWER, ENC.ENCHANT_BRACER_STATS, ENC.ENCHANT_BRACER_INTELLECT}, name="+30 Healing / +15 SP / Stats / +12 Intellect" },
    [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER, ENC.ENCHANT_GLOVES_MAJOR_HEALING}, name="+20 Spell Power / +35 Healing" },
    [15] = { ids={ENC.ENCHANT_CLOAK_SUBTLETY, ENC.ENCHANT_CLOAK_MAJOR_ARMOR}, name="Subtlety / Major Armor" },
    [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_HEALING, ENC.ENCHANT_WEAPON_SPELLSURGE, ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_MAJOR_INTELLECT, ENC.ENCHANT_WEAPON_HEALING_POWER, ENC.ENCHANT_WEAPON_MIGHTY_SPIRIT}, name="Major Healing / Spellsurge / SP / Intellect / +55 Healing / +20 Spirit" },
}
local priestDpsEnchants = {
    [1]  = { ids={ENC.ARCANUM_POWER},                                 name="Arcanum of Power" },
    [3]  = { ids={ENC.GREATER_INS_ORBS, ENC.GREATER_INS_DISCIPLINE, ENC.INS_ORBS, ENC.INS_DISCIPLINE, ENC.POWER_OF_THE_SCOURGE, ENC.SIGNET_MOJO}, name="Inscription of Orbs / Discipline / Power of the Scourge / Signet of Mojo" },
    [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},               name="+6 All Stats" },
    [7]  = { ids={ENC.RUNIC_SPELLTHREAD, ENC.MYSTIC_SPELLTHREAD},     name="Runic / Mystic Spellthread" },
    [8]  = { ids={ENC.ENCHANT_BOOTS_VITALITY, ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Vitality / Fortitude / Boar's Speed" },
    [9]  = { ids={ENC.ENCHANT_BRACER_SPELLPOWER, ENC.ENCHANT_BRACER_STATS}, name="+15 Spell Power / Stats" },
    [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER, ENC.ENCHANT_GLOVES_SPELL_STRIKE, ENC.ENCHANT_GLOVES_BLASTING}, name="+20 Spell Power / Spell Strike / Blasting" },
    [15] = { ids={ENC.ENCHANT_CLOAK_SPELL_PENETRATION, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Spell Penetration / Subtlety" },
    [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_SOULFROST}, name="Major Spell Power / Soulfrost" },
}
B.ENCHANTS["PRIEST"] = { [1]=priestHealEnchants, [2]=priestHealEnchants, [3]=priestDpsEnchants }

-- ── SHAMAN ────────────────────────────────────────────────────────────────────
-- Tab 1=Elemental, Tab 2=Enhancement, Tab 3=Restoration
B.ENCHANTS["SHAMAN"] = {
    [1] = { -- Elemental
        [1]  = { ids={ENC.ARCANUM_POWER},                             name="Arcanum of Power" },
        [3]  = { ids={ENC.GREATER_INS_ORBS, ENC.GREATER_INS_DISCIPLINE, ENC.INS_ORBS, ENC.INS_DISCIPLINE, ENC.POWER_OF_THE_SCOURGE, ENC.SIGNET_MOJO}, name="Inscription of Orbs / Discipline / Power of the Scourge / Signet of Mojo" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},           name="+6 All Stats" },
        [7]  = { ids={ENC.RUNIC_SPELLTHREAD, ENC.MYSTIC_SPELLTHREAD}, name="Runic / Mystic Spellthread" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_VITALITY, ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Vitality / Fortitude / Boar's Speed" },
        [9]  = { ids={ENC.ENCHANT_BRACER_SPELLPOWER, ENC.ENCHANT_BRACER_STATS}, name="+15 Spell Power / Stats" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER, ENC.ENCHANT_GLOVES_SPELL_STRIKE, ENC.ENCHANT_GLOVES_BLASTING}, name="+20 Spell Power / Spell Strike / Blasting" },
        [15] = { ids={ENC.ENCHANT_CLOAK_SPELL_PENETRATION, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Spell Penetration / Subtlety" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_SPELLSURGE}, name="Major Spell Power / Spellsurge" },
        [17] = { ids={ENC.ENCHANT_SHIELD_INTELLECT, ENC.ENCHANT_SHIELD_MAJOR_STAMINA}, name="Intellect / Major Stamina (Shield)" },
    },
    [2] = { -- Enhancement (dual wield — some use SP for burst/shocks)
        [1]  = { ids={ENC.ARCANUM_FEROCITY},                          name="Arcanum of Ferocity" },
        [3]  = { ids={ENC.GREATER_INS_VENGEANCE, ENC.GREATER_INS_BLADE, ENC.INS_VENGEANCE, ENC.INS_BLADE, ENC.MIGHT_OF_THE_SCOURGE, ENC.SIGNET_MIGHT}, name="Inscription of Vengeance / Blade / Might of the Scourge / Signet of Might" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},           name="+6 All Stats" },
        [7]  = { ids={ENC.NETHERCOBRA_LEG_ARMOR, ENC.COBRAHIDE_LEG_ARMOR}, name="Nethercobra / Cobrahide Leg Armor" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_SUREFOOTED, ENC.ENCHANT_BOOTS_CATS_SWIFTNESS, ENC.ENCHANT_BOOTS_DEXTERITY}, name="Surefooted / Cat's Swiftness / Dexterity" },
        [9]  = { ids={ENC.ENCHANT_BRACER_ASSAULT, ENC.ENCHANT_BRACER_STRENGTH, ENC.ENCHANT_BRACER_STATS}, name="Assault / +12 Strength / Stats" },
        [10] = { ids={ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY, ENC.ENCHANT_GLOVES_ASSAULT, ENC.ENCHANT_GLOVES_MAJOR_STRENGTH}, name="Superior Agility / Assault / Strength" },
        [15] = { ids={ENC.ENCHANT_CLOAK_GREATER_AGILITY, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Greater Agility / Subtlety" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_WEAPON_EXECUTIONER, ENC.ENCHANT_WEAPON_GREATER_AGILITY, ENC.ENCHANT_WEAPON_CRUSADER}, name="Mongoose / Executioner / Crusader" },
        [17] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_WEAPON_EXECUTIONER, ENC.ENCHANT_WEAPON_GREATER_AGILITY, ENC.ENCHANT_WEAPON_CRUSADER}, name="Mongoose / Executioner / Crusader" },
    },
    [3] = { -- Restoration
        [1]  = { ids={ENC.ARCANUM_RENEWAL},                           name="Arcanum of Renewal" },
        [3]  = { ids={ENC.GREATER_INS_FAITH, ENC.GREATER_INS_ORACLE, ENC.INS_FAITH, ENC.INS_ORACLE, ENC.RESILIENCE_OF_THE_SCOURGE, ENC.SIGNET_SERENITY}, name="Inscription of Faith / Oracle / Resilience of the Scourge / Signet of Serenity" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},           name="+6 All Stats" },
        [7]  = { ids={ENC.GOLDEN_SPELLTHREAD, ENC.SILVER_SPELLTHREAD}, name="Golden / Silver Spellthread" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_VITALITY, ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Vitality / Fortitude / Boar's Speed" },
        [9]  = { ids={ENC.ENCHANT_BRACER_HEALING, ENC.ENCHANT_BRACER_SPELLPOWER, ENC.ENCHANT_BRACER_STATS, ENC.ENCHANT_BRACER_INTELLECT}, name="+30 Healing / +15 SP / Stats / +12 Intellect" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER, ENC.ENCHANT_GLOVES_MAJOR_HEALING}, name="+20 Spell Power / +35 Healing" },
        [15] = { ids={ENC.ENCHANT_CLOAK_SUBTLETY, ENC.ENCHANT_CLOAK_MAJOR_ARMOR}, name="Subtlety / Major Armor" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_HEALING, ENC.ENCHANT_WEAPON_SPELLSURGE, ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_MAJOR_INTELLECT, ENC.ENCHANT_WEAPON_HEALING_POWER, ENC.ENCHANT_WEAPON_MIGHTY_SPIRIT}, name="Major Healing / Spellsurge / SP / Intellect / +55 Healing / +20 Spirit" },
        [17] = { ids={ENC.ENCHANT_SHIELD_INTELLECT, ENC.ENCHANT_SHIELD_MAJOR_STAMINA}, name="Intellect / Major Stamina (Shield)" },
    },
}

-- ── MAGE ──────────────────────────────────────────────────────────────────────
-- Tab 1=Arcane, Tab 2=Fire, Tab 3=Frost
local mageEnchants = {
    [1]  = { ids={ENC.ARCANUM_POWER},                                 name="Arcanum of Power" },
    [3]  = { ids={ENC.GREATER_INS_ORBS, ENC.GREATER_INS_DISCIPLINE, ENC.INS_ORBS, ENC.INS_DISCIPLINE, ENC.POWER_OF_THE_SCOURGE, ENC.SIGNET_MOJO}, name="Inscription of Orbs / Discipline / Power of the Scourge / Signet of Mojo" },
    [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},               name="+6 All Stats" },
    [7]  = { ids={ENC.RUNIC_SPELLTHREAD, ENC.MYSTIC_SPELLTHREAD},     name="Runic / Mystic Spellthread" },
    [8]  = { ids={ENC.ENCHANT_BOOTS_VITALITY, ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Vitality / Fortitude / Boar's Speed" },
    [9]  = { ids={ENC.ENCHANT_BRACER_SPELLPOWER, ENC.ENCHANT_BRACER_STATS, ENC.ENCHANT_BRACER_INTELLECT}, name="+15 Spell Power / Stats / +12 Intellect" },
    [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER, ENC.ENCHANT_GLOVES_SPELL_STRIKE, ENC.ENCHANT_GLOVES_BLASTING}, name="+20 Spell Power / Spell Strike / Blasting" },
    [15] = { ids={ENC.ENCHANT_CLOAK_SPELL_PENETRATION, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Spell Penetration / Subtlety" },
    [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_SOULFROST, ENC.ENCHANT_WEAPON_SUNFIRE, ENC.ENCHANT_WEAPON_MAJOR_INTELLECT, ENC.ENCHANT_WEAPON_SPELLSURGE}, name="Major Spell Power / Soulfrost / Sunfire" },
}
B.ENCHANTS["MAGE"] = { [1]=mageEnchants, [2]=mageEnchants, [3]=mageEnchants }

-- ── WARLOCK ───────────────────────────────────────────────────────────────────
-- Tab 1=Affliction, Tab 2=Demonology, Tab 3=Destruction
local warlockEnchants = {
    [1]  = { ids={ENC.ARCANUM_POWER},                                 name="Arcanum of Power" },
    [3]  = { ids={ENC.GREATER_INS_ORBS, ENC.GREATER_INS_DISCIPLINE, ENC.INS_ORBS, ENC.INS_DISCIPLINE, ENC.POWER_OF_THE_SCOURGE, ENC.SIGNET_MOJO}, name="Inscription of Orbs / Discipline / Power of the Scourge / Signet of Mojo" },
    [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},               name="+6 All Stats" },
    [7]  = { ids={ENC.RUNIC_SPELLTHREAD, ENC.MYSTIC_SPELLTHREAD},     name="Runic / Mystic Spellthread" },
    [8]  = { ids={ENC.ENCHANT_BOOTS_VITALITY, ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Vitality / Fortitude / Boar's Speed" },
    [9]  = { ids={ENC.ENCHANT_BRACER_SPELLPOWER, ENC.ENCHANT_BRACER_STATS}, name="+15 Spell Power / Stats" },
    [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER, ENC.ENCHANT_GLOVES_SPELL_STRIKE, ENC.ENCHANT_GLOVES_BLASTING}, name="+20 Spell Power / Spell Strike / Blasting" },
    [15] = { ids={ENC.ENCHANT_CLOAK_SPELL_PENETRATION, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Spell Penetration / Subtlety" },
    [16] = { ids={ENC.ENCHANT_WEAPON_SOULFROST, ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_SUNFIRE, ENC.ENCHANT_WEAPON_SPELLSURGE}, name="Soulfrost / Major Spell Power / Sunfire" },
}
B.ENCHANTS["WARLOCK"] = { [1]=warlockEnchants, [2]=warlockEnchants, [3]=warlockEnchants }

-- ── DRUID ─────────────────────────────────────────────────────────────────────
-- Tab 1=Balance, Tab 2=Feral Combat, Tab 3=Restoration
B.ENCHANTS["DRUID"] = {
    [1] = { -- Balance
        [1]  = { ids={ENC.ARCANUM_POWER},                             name="Arcanum of Power" },
        [3]  = { ids={ENC.GREATER_INS_ORBS, ENC.GREATER_INS_DISCIPLINE, ENC.INS_ORBS, ENC.INS_DISCIPLINE, ENC.POWER_OF_THE_SCOURGE, ENC.SIGNET_MOJO}, name="Inscription of Orbs / Discipline / Power of the Scourge / Signet of Mojo" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},           name="+6 All Stats" },
        [7]  = { ids={ENC.RUNIC_SPELLTHREAD, ENC.MYSTIC_SPELLTHREAD}, name="Runic / Mystic Spellthread" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_VITALITY, ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Vitality / Fortitude / Boar's Speed" },
        [9]  = { ids={ENC.ENCHANT_BRACER_SPELLPOWER, ENC.ENCHANT_BRACER_STATS}, name="+15 Spell Power / Stats" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER, ENC.ENCHANT_GLOVES_SPELL_STRIKE, ENC.ENCHANT_GLOVES_BLASTING}, name="+20 Spell Power / Spell Strike / Blasting" },
        [15] = { ids={ENC.ENCHANT_CLOAK_SPELL_PENETRATION, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Spell Penetration / Subtlety" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_MAJOR_INTELLECT, ENC.ENCHANT_WEAPON_SPELLSURGE, ENC.ENCHANT_WEAPON_SUNFIRE}, name="Major Spell Power / Intellect / Spellsurge / Sunfire" },
    },
    [2] = { -- Feral Combat (Cat/Bear — uses 2H staff/mace)
        [1]  = { ids={ENC.ARCANUM_FEROCITY, ENC.ARCANUM_PROTECTION},  name="Arcanum of Ferocity / Protector" },
        [3]  = { ids={ENC.GREATER_INS_VENGEANCE, ENC.GREATER_INS_BLADE, ENC.GREATER_INS_WARDING, ENC.GREATER_INS_KNIGHT, ENC.INS_VENGEANCE, ENC.INS_BLADE, ENC.INS_WARDING, ENC.INS_KNIGHT, ENC.MIGHT_OF_THE_SCOURGE, ENC.FORTITUDE_OF_THE_SCOURGE, ENC.SIGNET_MIGHT}, name="Inscription of Vengeance / Blade / Warding / Knight / Scourge / Signet of Might" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS, ENC.ENCHANT_CHEST_EXCEPTIONAL_HEALTH}, name="+6 All Stats / +150 Health" },
        [7]  = { ids={ENC.NETHERCOBRA_LEG_ARMOR, ENC.COBRAHIDE_LEG_ARMOR, ENC.NETHERCLEFT_LEG_ARMOR, ENC.CLEFTHIDE_LEG_ARMOR}, name="Nethercobra / Nethercleft Leg Armor" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_CATS_SWIFTNESS, ENC.ENCHANT_BOOTS_SUREFOOTED, ENC.ENCHANT_BOOTS_DEXTERITY, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Cat's Swiftness / Surefooted / Dexterity / Boar's Speed" },
        [9]  = { ids={ENC.ENCHANT_BRACER_ASSAULT, ENC.ENCHANT_BRACER_STATS, ENC.ENCHANT_BRACER_FORTITUDE}, name="Assault / Stats / Fortitude" },
        [10] = { ids={ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY, ENC.ENCHANT_GLOVES_ASSAULT, ENC.ENCHANT_GLOVES_THREAT}, name="Superior Agility / Assault / Threat" },
        [15] = { ids={ENC.ENCHANT_CLOAK_DODGE, ENC.ENCHANT_CLOAK_GREATER_AGILITY, ENC.ENCHANT_CLOAK_MAJOR_ARMOR, ENC.ENCHANT_CLOAK_STEELWEAVE, ENC.ENCHANT_CLOAK_SUBTLETY}, name="Dodge / Greater Agility / Major Armor / Steelweave / Subtlety" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_2H_MAJOR_AGILITY, ENC.ENCHANT_2H_SAVAGERY, ENC.ENCHANT_WEAPON_GREATER_AGILITY}, name="Mongoose / Major Agility / Savagery" },
    },
    [3] = { -- Restoration
        [1]  = { ids={ENC.ARCANUM_RENEWAL},                           name="Arcanum of Renewal" },
        [3]  = { ids={ENC.GREATER_INS_FAITH, ENC.GREATER_INS_ORACLE, ENC.INS_FAITH, ENC.INS_ORACLE, ENC.RESILIENCE_OF_THE_SCOURGE, ENC.SIGNET_SERENITY}, name="Inscription of Faith / Oracle / Resilience of the Scourge / Signet of Serenity" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS},           name="+6 All Stats" },
        [7]  = { ids={ENC.GOLDEN_SPELLTHREAD, ENC.SILVER_SPELLTHREAD}, name="Golden / Silver Spellthread" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_VITALITY, ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Vitality / Fortitude / Boar's Speed" },
        [9]  = { ids={ENC.ENCHANT_BRACER_HEALING, ENC.ENCHANT_BRACER_SPELLPOWER, ENC.ENCHANT_BRACER_STATS, ENC.ENCHANT_BRACER_INTELLECT}, name="+30 Healing / +15 SP / Stats / +12 Intellect" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER, ENC.ENCHANT_GLOVES_MAJOR_HEALING}, name="+20 Spell Power / +35 Healing" },
        [15] = { ids={ENC.ENCHANT_CLOAK_SUBTLETY, ENC.ENCHANT_CLOAK_MAJOR_ARMOR}, name="Subtlety / Major Armor" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_HEALING, ENC.ENCHANT_WEAPON_SPELLSURGE, ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_MAJOR_INTELLECT, ENC.ENCHANT_WEAPON_HEALING_POWER, ENC.ENCHANT_WEAPON_MIGHTY_SPIRIT}, name="Major Healing / Spellsurge / SP / Intellect / +55 Healing / +20 Spirit" },
    },
}

-- ── Sweat Mode Enchant Database ───────────────────────────────────────────────
-- Ultimate BiS only — one enchant per slot, no alternatives.
-- When sweat mode is active, ONLY these enchants are accepted.
-- Structure: same as B.ENCHANTS — B.SWEAT_ENCHANTS[class][specTab][slotId] = { ids={...}, name="..." }

B.SWEAT_ENCHANTS = {}

-- ── Shared sweat templates ───────────────────────────────────────────────────

local sweatPhysDps = {
    [1]  = { ids={ENC.ARCANUM_FEROCITY},               name="Arcanum of Ferocity" },
    [3]  = { ids={ENC.GREATER_INS_VENGEANCE, ENC.GREATER_INS_BLADE}, name="Greater Inscription of Vengeance / Blade" },
    [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS}, name="+6 All Stats" },
    [7]  = { ids={ENC.NETHERCOBRA_LEG_ARMOR},           name="Nethercobra Leg Armor" },
    [8]  = { ids={ENC.ENCHANT_BOOTS_CATS_SWIFTNESS},    name="Cat's Swiftness" },
    [9]  = { ids={ENC.ENCHANT_BRACER_ASSAULT},           name="+24 Attack Power" },
    [10] = { ids={ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY},  name="+15 Agility" },
    [15] = { ids={ENC.ENCHANT_CLOAK_GREATER_AGILITY},    name="+12 Agility" },
}

local sweatCasterDps = {
    [1]  = { ids={ENC.ARCANUM_POWER},                   name="Arcanum of Power" },
    [3]  = { ids={ENC.GREATER_INS_DISCIPLINE, ENC.GREATER_INS_ORBS}, name="Greater Inscription of Discipline / Orbs" },
    [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS}, name="+6 All Stats" },
    [7]  = { ids={ENC.RUNIC_SPELLTHREAD},               name="Runic Spellthread" },
    [8]  = { ids={ENC.ENCHANT_BOOTS_BOARS_SPEED},       name="Boar's Speed" },
    [9]  = { ids={ENC.ENCHANT_BRACER_SPELLPOWER},       name="+15 Spell Damage" },
    [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER}, name="+20 Spell Damage" },
    [15] = { ids={ENC.ENCHANT_CLOAK_SUBTLETY},          name="Subtlety" },
}

local sweatHealer = {
    [1]  = { ids={ENC.ARCANUM_RENEWAL},                 name="Arcanum of Renewal" },
    [3]  = { ids={ENC.GREATER_INS_FAITH, ENC.GREATER_INS_ORACLE}, name="Greater Inscription of Faith / Oracle" },
    [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS}, name="+6 All Stats" },
    [7]  = { ids={ENC.GOLDEN_SPELLTHREAD},              name="Golden Spellthread" },
    [8]  = { ids={ENC.ENCHANT_BOOTS_BOARS_SPEED},       name="Boar's Speed" },
    [9]  = { ids={ENC.ENCHANT_BRACER_HEALING},          name="+30 Healing" },
    [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_HEALING},    name="+35 Healing" },
    [15] = { ids={ENC.ENCHANT_CLOAK_SUBTLETY},          name="Subtlety" },
    [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_HEALING},    name="+81 Healing" },
}

-- sweatTank covers both avoidance/EHP and threat gear sets
local sweatTank = {
    [1]  = { ids={ENC.ARCANUM_PROTECTION, ENC.ARCANUM_FEROCITY}, name="Arcanum of Protector / Ferocity" },
    [3]  = { ids={ENC.GREATER_INS_WARDING, ENC.GREATER_INS_KNIGHT, ENC.GREATER_INS_VENGEANCE, ENC.GREATER_INS_BLADE}, name="Greater Inscription (Tank or Threat)" },
    [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS, ENC.ENCHANT_CHEST_EXCEPTIONAL_HEALTH}, name="+6 All Stats / +150 Health" },
    [8]  = { ids={ENC.ENCHANT_BOOTS_BOARS_SPEED, ENC.ENCHANT_BOOTS_CATS_SWIFTNESS}, name="Boar's Speed / Cat's Swiftness" },
    [9]  = { ids={ENC.ENCHANT_BRACER_FORTITUDE, ENC.ENCHANT_BRACER_STRENGTH, ENC.ENCHANT_BRACER_STATS}, name="+12 Stamina / +12 Strength / +4 Stats" },
    [10] = { ids={ENC.ENCHANT_GLOVES_THREAT, ENC.ENCHANT_GLOVES_MAJOR_STRENGTH, ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY}, name="+2% Threat / +15 Strength / +15 Agility" },
    [15] = { ids={ENC.ENCHANT_CLOAK_DODGE, ENC.ENCHANT_CLOAK_GREATER_AGILITY}, name="Dodge / +12 Agility" },
}

-- ── WARRIOR (Sweat) ──────────────────────────────────────────────────────────
-- Warriors benefit more from Strength than Agility (1 Str = 2 AP, scales with Kings)
B.SWEAT_ENCHANTS["WARRIOR"] = {
    [1] = { -- Arms (2H)
        [1]  = sweatPhysDps[1],
        [3]  = sweatPhysDps[3],
        [5]  = sweatPhysDps[5],
        [7]  = sweatPhysDps[7],
        [8]  = sweatPhysDps[8],
        [9]  = { ids={ENC.ENCHANT_BRACER_STRENGTH},      name="+12 Strength" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_STRENGTH}, name="+15 Strength" },
        [15] = sweatPhysDps[15],
        [16] = { ids={ENC.ENCHANT_2H_SAVAGERY, ENC.ENCHANT_WEAPON_EXECUTIONER}, name="Savagery / Executioner" },
    },
    [2] = { -- Fury (DW)
        [1]  = sweatPhysDps[1],
        [3]  = sweatPhysDps[3],
        [5]  = sweatPhysDps[5],
        [7]  = sweatPhysDps[7],
        [8]  = sweatPhysDps[8],
        [9]  = { ids={ENC.ENCHANT_BRACER_STRENGTH},      name="+12 Strength" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_STRENGTH}, name="+15 Strength" },
        [15] = sweatPhysDps[15],
        [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE},     name="Mongoose" },
        [17] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE},     name="Mongoose" },
    },
    [3] = { -- Protection (avoidance/EHP + threat sets)
        [1]  = sweatTank[1],
        [3]  = sweatTank[3],
        [5]  = sweatTank[5],
        [7]  = { ids={ENC.NETHERCLEFT_LEG_ARMOR, ENC.NETHERCOBRA_LEG_ARMOR}, name="Nethercleft / Nethercobra" },
        [8]  = sweatTank[8],
        [9]  = sweatTank[9],
        [10] = sweatTank[10],
        [15] = sweatTank[15],
        [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE},     name="Mongoose" },
        [17] = { ids={ENC.ENCHANT_SHIELD_MAJOR_STAMINA, ENC.ENCHANT_SHIELD_BLOCK}, name="+18 Stamina / +15 Block Rating" },
    },
}

-- ── PALADIN (Sweat) ──────────────────────────────────────────────────────────
B.SWEAT_ENCHANTS["PALADIN"] = {
    [1] = { -- Holy
        [1]  = sweatHealer[1],
        [3]  = sweatHealer[3],
        [5]  = sweatHealer[5],
        [7]  = sweatHealer[7],
        [8]  = sweatHealer[8],
        [9]  = sweatHealer[9],
        [10] = sweatHealer[10],
        [15] = sweatHealer[15],
        [16] = sweatHealer[16],
        [17] = { ids={ENC.ENCHANT_SHIELD_INTELLECT},    name="+12 Intellect (Shield)" },
    },
    [2] = { -- Protection (spell power tank — avoidance/EHP + spell threat sets)
        [1]  = { ids={ENC.ARCANUM_PROTECTION, ENC.ARCANUM_POWER}, name="Arcanum of Protector / Power" },
        [3]  = { ids={ENC.GREATER_INS_WARDING, ENC.GREATER_INS_KNIGHT, ENC.GREATER_INS_DISCIPLINE, ENC.GREATER_INS_ORBS}, name="Greater Inscription (Tank or Caster)" },
        [5]  = sweatTank[5],
        [7]  = { ids={ENC.NETHERCLEFT_LEG_ARMOR, ENC.RUNIC_SPELLTHREAD}, name="Nethercleft / Runic Spellthread" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_FORTITUDE, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="+12 Stamina / Boar's Speed" },
        [9]  = { ids={ENC.ENCHANT_BRACER_SPELLPOWER, ENC.ENCHANT_BRACER_FORTITUDE}, name="+15 Spell Damage / +12 Stamina" },
        [10] = { ids={ENC.ENCHANT_GLOVES_THREAT, ENC.ENCHANT_GLOVES_MAJOR_SPELLPOWER}, name="+2% Threat / +20 Spell Damage" },
        [15] = { ids={ENC.ENCHANT_CLOAK_DODGE, ENC.ENCHANT_CLOAK_GREATER_AGILITY}, name="Dodge / +12 Agility" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER}, name="+40 Spell Damage" },
        [17] = { ids={ENC.ENCHANT_SHIELD_MAJOR_STAMINA, ENC.ENCHANT_SHIELD_BLOCK}, name="+18 Stamina / +15 Block Rating" },
    },
    [3] = { -- Retribution (2H — Str scales with Kings)
        [1]  = sweatPhysDps[1],
        [3]  = sweatPhysDps[3],
        [5]  = sweatPhysDps[5],
        [7]  = sweatPhysDps[7],
        [8]  = sweatPhysDps[8],
        [9]  = { ids={ENC.ENCHANT_BRACER_STRENGTH},      name="+12 Strength" },
        [10] = { ids={ENC.ENCHANT_GLOVES_MAJOR_STRENGTH}, name="+15 Strength" },
        [15] = sweatPhysDps[15],
        [16] = { ids={ENC.ENCHANT_2H_SAVAGERY, ENC.ENCHANT_WEAPON_EXECUTIONER}, name="Savagery / Executioner" },
    },
}

-- ── HUNTER (Sweat) ───────────────────────────────────────────────────────────
local sweatHunter = {
    [1]  = sweatPhysDps[1],
    [3]  = sweatPhysDps[3],
    [5]  = sweatPhysDps[5],
    [7]  = sweatPhysDps[7],
    [8]  = sweatPhysDps[8],
    [9]  = sweatPhysDps[9],
    [10] = sweatPhysDps[10],
    [15] = sweatPhysDps[15],
    [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_2H_MAJOR_AGILITY}, name="Mongoose / +35 Agility" },
    [18] = { ids={ENC.STABILIZED_ETERNIUM_SCOPE},       name="Stabilized Eternium Scope" },
}
B.SWEAT_ENCHANTS["HUNTER"] = { [1]=sweatHunter, [2]=sweatHunter, [3]=sweatHunter }

-- ── ROGUE (Sweat) ────────────────────────────────────────────────────────────
local sweatRogue = {
    [1]  = sweatPhysDps[1],
    [3]  = sweatPhysDps[3],
    [5]  = sweatPhysDps[5],
    [7]  = sweatPhysDps[7],
    [8]  = sweatPhysDps[8],
    [9]  = sweatPhysDps[9],
    [10] = sweatPhysDps[10],
    [15] = sweatPhysDps[15],
    [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE},         name="Mongoose" },
    [17] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE},         name="Mongoose" },
}
B.SWEAT_ENCHANTS["ROGUE"] = { [1]=sweatRogue, [2]=sweatRogue, [3]=sweatRogue }

-- ── PRIEST (Sweat) ───────────────────────────────────────────────────────────
local sweatPriestHeal = {
    [1]  = sweatHealer[1],
    [3]  = sweatHealer[3],
    [5]  = sweatHealer[5],
    [7]  = sweatHealer[7],
    [8]  = sweatHealer[8],
    [9]  = sweatHealer[9],
    [10] = sweatHealer[10],
    [15] = sweatHealer[15],
    [16] = sweatHealer[16],
}
local sweatShadow = {
    [1]  = sweatCasterDps[1],
    [3]  = sweatCasterDps[3],
    [5]  = sweatCasterDps[5],
    [7]  = sweatCasterDps[7],
    [8]  = sweatCasterDps[8],
    [9]  = sweatCasterDps[9],
    [10] = sweatCasterDps[10],
    [15] = sweatCasterDps[15],
    [16] = { ids={ENC.ENCHANT_WEAPON_SOULFROST},        name="Soulfrost" },
}
B.SWEAT_ENCHANTS["PRIEST"] = { [1]=sweatPriestHeal, [2]=sweatPriestHeal, [3]=sweatShadow }

-- ── SHAMAN (Sweat) ───────────────────────────────────────────────────────────
B.SWEAT_ENCHANTS["SHAMAN"] = {
    [1] = { -- Elemental
        [1]  = sweatCasterDps[1],
        [3]  = sweatCasterDps[3],
        [5]  = sweatCasterDps[5],
        [7]  = sweatCasterDps[7],
        [8]  = sweatCasterDps[8],
        [9]  = sweatCasterDps[9],
        [10] = sweatCasterDps[10],
        [15] = sweatCasterDps[15],
        [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER}, name="+40 Spell Damage" },
        [17] = { ids={ENC.ENCHANT_SHIELD_INTELLECT},    name="+12 Intellect (Shield)" },
    },
    [2] = { -- Enhancement (DW)
        [1]  = sweatPhysDps[1],
        [3]  = sweatPhysDps[3],
        [5]  = sweatPhysDps[5],
        [7]  = sweatPhysDps[7],
        [8]  = sweatPhysDps[8],
        [9]  = sweatPhysDps[9],
        [10] = sweatPhysDps[10],
        [15] = sweatPhysDps[15],
        [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE},     name="Mongoose" },
        [17] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE},     name="Mongoose" },
    },
    [3] = { -- Restoration
        [1]  = sweatHealer[1],
        [3]  = sweatHealer[3],
        [5]  = sweatHealer[5],
        [7]  = sweatHealer[7],
        [8]  = sweatHealer[8],
        [9]  = sweatHealer[9],
        [10] = sweatHealer[10],
        [15] = sweatHealer[15],
        [16] = sweatHealer[16],
        [17] = { ids={ENC.ENCHANT_SHIELD_INTELLECT},    name="+12 Intellect (Shield)" },
    },
}

-- ── MAGE (Sweat) ─────────────────────────────────────────────────────────────
B.SWEAT_ENCHANTS["MAGE"] = {
    [1] = { -- Arcane
        [1]  = sweatCasterDps[1],
        [3]  = sweatCasterDps[3],
        [5]  = sweatCasterDps[5],
        [7]  = sweatCasterDps[7],
        [8]  = sweatCasterDps[8],
        [9]  = sweatCasterDps[9],
        [10] = sweatCasterDps[10],
        [15] = sweatCasterDps[15],
        [16] = { ids={ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER, ENC.ENCHANT_WEAPON_SUNFIRE}, name="+40 Spell Damage / Sunfire" },
    },
    [2] = { -- Fire
        [1]  = sweatCasterDps[1],
        [3]  = sweatCasterDps[3],
        [5]  = sweatCasterDps[5],
        [7]  = sweatCasterDps[7],
        [8]  = sweatCasterDps[8],
        [9]  = sweatCasterDps[9],
        [10] = sweatCasterDps[10],
        [15] = sweatCasterDps[15],
        [16] = { ids={ENC.ENCHANT_WEAPON_SUNFIRE},      name="Sunfire" },
    },
    [3] = { -- Frost
        [1]  = sweatCasterDps[1],
        [3]  = sweatCasterDps[3],
        [5]  = sweatCasterDps[5],
        [7]  = sweatCasterDps[7],
        [8]  = sweatCasterDps[8],
        [9]  = sweatCasterDps[9],
        [10] = sweatCasterDps[10],
        [15] = sweatCasterDps[15],
        [16] = { ids={ENC.ENCHANT_WEAPON_SOULFROST},    name="Soulfrost" },
    },
}

-- ── WARLOCK (Sweat) ──────────────────────────────────────────────────────────
local sweatWarlock = {
    [1]  = sweatCasterDps[1],
    [3]  = sweatCasterDps[3],
    [5]  = sweatCasterDps[5],
    [7]  = sweatCasterDps[7],
    [8]  = sweatCasterDps[8],
    [9]  = sweatCasterDps[9],
    [10] = sweatCasterDps[10],
    [15] = sweatCasterDps[15],
    [16] = { ids={ENC.ENCHANT_WEAPON_SOULFROST},        name="Soulfrost" },
}
B.SWEAT_ENCHANTS["WARLOCK"] = { [1]=sweatWarlock, [2]=sweatWarlock, [3]=sweatWarlock }

-- ── DRUID (Sweat) ────────────────────────────────────────────────────────────
B.SWEAT_ENCHANTS["DRUID"] = {
    [1] = { -- Balance
        [1]  = sweatCasterDps[1],
        [3]  = sweatCasterDps[3],
        [5]  = sweatCasterDps[5],
        [7]  = sweatCasterDps[7],
        [8]  = sweatCasterDps[8],
        [9]  = sweatCasterDps[9],
        [10] = sweatCasterDps[10],
        [15] = sweatCasterDps[15],
        [16] = { ids={ENC.ENCHANT_WEAPON_SUNFIRE, ENC.ENCHANT_WEAPON_MAJOR_SPELLPOWER}, name="Sunfire / +40 Spell Damage" },
    },
    [2] = { -- Feral (cat DPS + bear tank sets)
        [1]  = { ids={ENC.ARCANUM_FEROCITY, ENC.ARCANUM_PROTECTION}, name="Arcanum of Ferocity / Protector" },
        [3]  = { ids={ENC.GREATER_INS_VENGEANCE, ENC.GREATER_INS_BLADE, ENC.GREATER_INS_WARDING, ENC.GREATER_INS_KNIGHT}, name="Greater Inscription (DPS or Tank)" },
        [5]  = { ids={ENC.ENCHANT_CHEST_EXCEPTIONAL_STATS, ENC.ENCHANT_CHEST_EXCEPTIONAL_HEALTH}, name="+6 All Stats / +150 Health" },
        [7]  = { ids={ENC.NETHERCOBRA_LEG_ARMOR, ENC.NETHERCLEFT_LEG_ARMOR}, name="Nethercobra / Nethercleft" },
        [8]  = { ids={ENC.ENCHANT_BOOTS_CATS_SWIFTNESS, ENC.ENCHANT_BOOTS_BOARS_SPEED}, name="Cat's Swiftness / Boar's Speed" },
        [9]  = { ids={ENC.ENCHANT_BRACER_ASSAULT, ENC.ENCHANT_BRACER_FORTITUDE, ENC.ENCHANT_BRACER_STATS}, name="+24 AP / +12 Stamina / +4 Stats" },
        [10] = { ids={ENC.ENCHANT_GLOVES_SUPERIOR_AGILITY, ENC.ENCHANT_GLOVES_THREAT}, name="+15 Agility / +2% Threat" },
        [15] = { ids={ENC.ENCHANT_CLOAK_DODGE, ENC.ENCHANT_CLOAK_GREATER_AGILITY}, name="Dodge / +12 Agility" },
        [16] = { ids={ENC.ENCHANT_WEAPON_MONGOOSE, ENC.ENCHANT_2H_MAJOR_AGILITY}, name="Mongoose / +35 Agility" },
    },
    [3] = { -- Restoration
        [1]  = sweatHealer[1],
        [3]  = sweatHealer[3],
        [5]  = sweatHealer[5],
        [7]  = sweatHealer[7],
        [8]  = sweatHealer[8],
        [9]  = sweatHealer[9],
        [10] = sweatHealer[10],
        [15] = sweatHealer[15],
        [16] = sweatHealer[16],
    },
}

-- ── BiS Gem Recommendations ───────────────────────────────────────────────────
-- Per spec: what color gems to use per socket type.
-- Structure: B.GEMS[class][specTab] = { meta=..., red=..., blue=..., yellow=..., prismatic=... }

B.GEMS = {}

local physDpsGems = {
    meta      = { color="META",   name="Relentless Earthstorm Diamond" },
    red       = { color="RED",    name="Bold Living Ruby / Stone of Blades" },
    yellow    = { color="YELLOW", name="Rigid Dawnstone (hit cap) / Bold" },
    blue      = { color="BLUE",   name="1x Shifting Nightseye for meta; else Bold" },
    prismatic = { color="RED",    name="Bold Living Ruby" },
}
local casterDpsGems = {
    meta      = { color="META",   name="Chaotic Skyfire Diamond" },
    red       = { color="RED",    name="Runed Living Ruby" },
    yellow    = { color="YELLOW", name="Veiled Noble Topaz (hit) / Potent (crit)" },
    blue      = { color="BLUE",   name="Glowing Nightseye (spell dmg+sta)" },
    prismatic = { color="RED",    name="Runed Living Ruby" },
}
local healerGems = {
    meta      = { color="META",   name="Insightful Earthstorm Diamond (mana) / Brute Force" },
    red       = { color="RED",    name="Teardrop Living Ruby (+18 healing)" },
    yellow    = { color="YELLOW", name="Brilliant Dawnstone (+8 int) / Smooth (crit)" },
    blue      = { color="BLUE",   name="Royal Nightseye (+9 healing / +2 mp5)" },
    prismatic = { color="RED",    name="Teardrop Living Ruby" },
}
local tankGems = {
    meta      = { color="META",   name="Brute Force / Relentless Earthstorm Diamond" },
    red       = { color="RED",    name="Shifting Nightseye (str+sta) / Bold" },
    yellow    = { color="YELLOW", name="Thick Dawnstone (+6 defense) / Rigid (hit)" },
    blue      = { color="BLUE",   name="Solid Star of Elune (+12 stamina)" },
    prismatic = { color="BLUE",   name="Solid Star of Elune" },
}

B.GEMS["WARRIOR"]  = { [1]=physDpsGems,   [2]=physDpsGems,   [3]=tankGems    }
B.GEMS["PALADIN"]  = { [1]=healerGems,    [2]=tankGems,      [3]=physDpsGems }
B.GEMS["HUNTER"]   = { [1]=physDpsGems,   [2]=physDpsGems,   [3]=physDpsGems }
B.GEMS["ROGUE"]    = { [1]=physDpsGems,   [2]=physDpsGems,   [3]=physDpsGems }
B.GEMS["PRIEST"]   = { [1]=healerGems,    [2]=healerGems,    [3]=casterDpsGems }
B.GEMS["SHAMAN"]   = { [1]=casterDpsGems, [2]=physDpsGems,   [3]=healerGems  }
B.GEMS["MAGE"]     = { [1]=casterDpsGems, [2]=casterDpsGems, [3]=casterDpsGems }
B.GEMS["WARLOCK"]  = { [1]=casterDpsGems, [2]=casterDpsGems, [3]=casterDpsGems }
B.GEMS["DRUID"]    = { [1]=casterDpsGems, [2]=physDpsGems,   [3]=healerGems  }

-- ── Query API ─────────────────────────────────────────────────────────────────

-- Returns user override entry for a class/spec/slot, or nil
function B.GetOverridesForSlot(class, specTab, slotId)
    local db = RaidInspectorDB and RaidInspectorDB.enchantOverrides
    if not db then return nil end
    local ct = db[class]
    if not ct then return nil end
    local st = ct[specTab]
    if not st then return nil end
    return st[slotId]
end

-- Returns the active enchant database table (sweat or normal)
local function GetActiveEnchantTable()
    if RaidInspectorDB and RaidInspectorDB.sweatMode then
        return B.SWEAT_ENCHANTS
    end
    return B.ENCHANTS
end

-- Returns: true (matches), false (wrong enchant), nil (no recommendation for this slot/spec)
-- Checks BOTH user overrides and the active enchant table (union).
-- In sweat mode, uses SWEAT_ENCHANTS instead of ENCHANTS.
function B.IsRecommendedEnchant(class, specTab, slotId, actualEnchantId)
    if not class or specTab == 0 or not slotId then return nil end

    -- Check user overrides first
    local override = B.GetOverridesForSlot(class, specTab, slotId)
    if override then
        for _, id in ipairs(override.ids) do
            if id == actualEnchantId then return true end
        end
    end

    -- Check active table (sweat or normal)
    local enchTable = GetActiveEnchantTable()
    local classTbl = enchTable[class]
    if not classTbl then return (override and false) or nil end
    local specTbl = classTbl[specTab]
    if not specTbl then return (override and false) or nil end
    local rec = specTbl[slotId]
    if not rec then return (override and false) or nil end

    for _, id in ipairs(rec.ids) do
        if id == actualEnchantId then return true end
    end
    return false
end

-- Returns the recommended enchant name string, or nil
function B.GetRecommendedEnchantName(class, specTab, slotId)
    if not class or specTab == 0 or not slotId then return nil end

    local parts = {}

    -- Active table name
    local enchTable = GetActiveEnchantTable()
    local classTbl = enchTable[class]
    if classTbl then
        local specTbl = classTbl[specTab]
        if specTbl and specTbl[slotId] then
            table.insert(parts, specTbl[slotId].name)
        end
    end

    -- Override name
    local override = B.GetOverridesForSlot(class, specTab, slotId)
    if override and override.name then
        table.insert(parts, override.name)
    end

    if #parts == 0 then return nil end
    return table.concat(parts, " / ")
end

-- Returns merged list of all recommended enchant IDs (active table + overrides)
function B.GetAllRecommendedIds(class, specTab, slotId)
    local result = {}
    local seen = {}

    -- Active table
    local enchTable = GetActiveEnchantTable()
    local classTbl = enchTable[class]
    if classTbl then
        local specTbl = classTbl[specTab]
        if specTbl and specTbl[slotId] then
            for _, id in ipairs(specTbl[slotId].ids) do
                if not seen[id] then
                    table.insert(result, id)
                    seen[id] = true
                end
            end
        end
    end

    -- Overrides
    local override = B.GetOverridesForSlot(class, specTab, slotId)
    if override then
        for _, id in ipairs(override.ids) do
            if not seen[id] then
                table.insert(result, id)
                seen[id] = true
            end
        end
    end

    return result
end

-- ── Enchant Override Management ───────────────────────────────────────────────

function B.AddEnchantOverride(class, specTab, slotId, enchantId, name)
    if not RaidInspectorDB then return end
    local db = RaidInspectorDB.enchantOverrides
    if not db then return end

    db[class] = db[class] or {}
    db[class][specTab] = db[class][specTab] or {}

    local existing = db[class][specTab][slotId]
    if existing then
        for _, id in ipairs(existing.ids) do
            if id == enchantId then return end  -- already present
        end
        table.insert(existing.ids, enchantId)
        existing.name = existing.name .. " / " .. (name or tostring(enchantId))
    else
        db[class][specTab][slotId] = {
            ids = { enchantId },
            name = name or ("Enchant #" .. enchantId),
        }
    end
end

function B.RemoveEnchantOverride(class, specTab, slotId, enchantId)
    if not RaidInspectorDB then return end
    local db = RaidInspectorDB.enchantOverrides
    if not db or not db[class] or not db[class][specTab] or not db[class][specTab][slotId] then return end

    local rec = db[class][specTab][slotId]
    for i, id in ipairs(rec.ids) do
        if id == enchantId then
            table.remove(rec.ids, i)
            break
        end
    end

    -- Rebuild name from remaining IDs
    if #rec.ids == 0 then
        db[class][specTab][slotId] = nil
    else
        local names = {}
        for _, id in ipairs(rec.ids) do
            table.insert(names, B.GetEnchantName(id) or ("Enchant #" .. id))
        end
        rec.name = table.concat(names, " / ")
    end
end

-- ── Enchant Name Lookup ───────────────────────────────────────────────────────
-- Comprehensive mapping of enchant effect IDs → display names.
-- Used to show human-readable enchant names in the UI for ANY enchant,
-- not just the ones in the BiS recommendation tables.

B.ENCHANT_NAMES = {
    -- Head (TBC Glyphs/Arcanums)
    [3003] = "Glyph of Ferocity",
    [3001] = "Glyph of Renewal",
    [3002] = "Glyph of Power",
    [2999] = "Glyph of the Defender",
    [3004] = "Glyph of the Gladiator",
    [3006] = "Glyph of Arcane Warding",
    [3007] = "Glyph of Fire Warding",
    [3008] = "Glyph of Frost Warding",
    [3009] = "Glyph of Shadow Warding",
    [3005] = "Glyph of Nature Warding",
    [3096] = "Glyph of the Outcast",

    -- Shoulder (Aldor Greater)
    [2986] = "Greater Inscription of Vengeance",
    [2982] = "Greater Inscription of Discipline",
    [2980] = "Greater Inscription of Faith",
    [2978] = "Greater Inscription of Warding",
    -- Shoulder (Scryers Greater)
    [2995] = "Greater Inscription of the Orb",
    [2997] = "Greater Inscription of the Blade",
    [2991] = "Greater Inscription of the Knight",
    [2993] = "Greater Inscription of the Oracle",
    -- Shoulder (Aldor Lesser)
    [2983] = "Inscription of Vengeance",
    [2981] = "Inscription of Discipline",
    [2979] = "Inscription of Faith",
    [2977] = "Inscription of Warding",
    -- Shoulder (Scryers Lesser)
    [2996] = "Inscription of the Blade",
    [2994] = "Inscription of the Orb",
    [2990] = "Inscription of the Knight",
    [2992] = "Inscription of the Oracle",
    -- Shoulder (Naxxramas — Sapphiron)
    [2717] = "Might of the Scourge",
    [2721] = "Power of the Scourge",
    [2715] = "Resilience of the Scourge",
    [2716] = "Fortitude of the Scourge",
    -- Shoulder (Zul'Gurub — Zandalar Signets)
    [2604] = "Zandalar Signet of Serenity",
    [2605] = "Zandalar Signet of Mojo",
    [2606] = "Zandalar Signet of Might",
    -- Shoulder (Violet Eye)
    [2998] = "Inscription of Endurance",

    -- Chest
    [2661] = "+6 All Stats",
    [2659] = "+150 Health",
    [2933] = "+15 Resilience",
    [1950] = "+15 Defense Rating",
    [3150] = "+6 Mana per 5 sec",
    [1144] = "+15 Spirit",
    [2503] = "+4 All Stats",
    [1891] = "+4 All Stats",  -- also used on bracers

    -- Legs (Leatherworking)
    [3012] = "Nethercobra Leg Armor",
    [3010] = "Cobrahide Leg Armor",
    [3013] = "Nethercleft Leg Armor",
    [3011] = "Clefthide Leg Armor",
    -- Legs (Tailoring)
    [2748] = "Runic Spellthread",
    [2747] = "Mystic Spellthread",
    [2746] = "Golden Spellthread",
    [2745] = "Silver Spellthread",

    -- Feet
    [2939] = "Cat's Swiftness",
    [2940] = "Boar's Speed",
    [2657] = "+12 Agility",
    [2649] = "+12 Stamina",
    [2658] = "Surefooted",
    [2656] = "Vitality",
    [851]  = "+7 Stamina",
    [911]  = "Minor Speed",
    [2544] = "+7 Agility",

    -- Wrists
    [2650] = "+15 Spell Damage",
    [2617] = "+30 Healing",
    [1593] = "+24 Attack Power",
    [2647] = "+12 Strength",
    [2679] = "+6 Mana per 5 sec",
    [369]  = "+12 Intellect",
    [2648] = "+12 Defense Rating",
    [1147] = "+9 Stamina",
    [2566] = "+7 Strength",

    -- Hands
    [2564] = "+15 Agility",
    [2937] = "+20 Spell Damage",
    [2613] = "+2% Threat",
    [684]  = "+15 Strength",
    [1594] = "+26 Attack Power",
    [2935] = "+15 Spell Hit Rating",
    [2934] = "+10 Spell Crit Rating",
    [2322] = "+35 Healing",
    [3260] = "+240 Armor",
    [2614] = "+15 Hit Rating",
    [2615] = "+15 Agility",
    [930]  = "+7 Attack Power",

    -- Back
    [368]  = "+12 Agility",
    [2621] = "Subtlety",
    [2938] = "+20 Spell Penetration",
    [2662] = "+120 Armor",
    [2648] = "+12 Defense Rating",
    [2664] = "+7 All Resistances",
    [1257] = "+15 Arcane Resistance",
    [1441] = "+15 Shadow Resistance",
    [849]  = "+3 All Resistances",
    [247]  = "+70 Armor",

    -- Weapons (1H)
    [2673] = "Mongoose",
    [2669] = "+40 Spell Damage",
    [2671] = "Sunfire",
    [2672] = "Soulfrost",
    [2674] = "Spellsurge",
    [2675] = "Battlemaster",
    [1900] = "Crusader",
    [2666] = "+30 Intellect",
    [3222] = "+20 Agility",
    [2668] = "+20 Strength",
    [2343] = "+81 Healing",
    [3225] = "Executioner",
    [3273] = "Deathfrost",
    [3223] = "Adamantite Weapon Chain",
    [1897] = "+5 Weapon Damage",
    [963]  = "+7 Weapon Damage",
    [2667] = "+70 Attack Power",
    [2670] = "+35 Agility",
    [1903] = "Lifestealing",
    [1898] = "Fiery Weapon",
    [1899] = "Icy Chill",
    [2504] = "+30 Spell Damage (Spell Power)",
    [2505] = "+55 Healing Power",
    [1894] = "Unholy Weapon",
    [1896] = "Superior Impact",
    [1606] = "Demonslaying",
    [803]  = "Fiery Blaze",
    [2563] = "+15 Strength",
    [2443] = "+3 Agility",
    [2567] = "+20 Spirit",
    [2568] = "+22 Intellect",

    -- Shields
    [2653] = "+18 Block Value",
    [3229] = "+12 Resilience",
    [1071] = "+18 Stamina",
    [2655] = "+15 Block Rating",
    [2654] = "+12 Intellect",
    [1888] = "+10 Shield Block",
    [1704] = "+7 Stamina",
    [926]  = "+10 Spirit",

    -- Ranged (Scopes)
    [2724] = "Stabilized Eternium Scope",
    [2723] = "Khorium Scope",
    [2523] = "Biznicks 247x128 Accurascope",
    [32]   = "+7 Scope Damage",
    [33]   = "+3 Scope Damage",

    -- Ring enchants (Enchanter-only)
    [2930] = "+20 Healing (Ring)",
    [2928] = "+12 Spell Damage (Ring)",
    [2931] = "+4 All Stats (Ring)",
    [2929] = "+2 Weapon Damage (Ring)",

    -- Classic/Vanilla enchants that may still be seen
    [241]  = "+3 Intellect",
    [242]  = "+5 Spirit",
    [243]  = "+5 Stamina",
    [246]  = "+3 Agility",
    [248]  = "+3 Strength",
    [254]  = "+5 Stamina",
    [255]  = "+5 Intellect",
    [256]  = "+5 Strength",
    [15]   = "+1 All Resistances",
    [66]   = "+3 Stamina",
    [247]  = "+70 Armor",
    [843]  = "+3 Spirit",
    [847]  = "+1 All Stats",
    [848]  = "+3 All Stats",
    [850]  = "+5 Stamina",
    [856]  = "+5 Intellect",
    [857]  = "+5 Spirit",
    [863]  = "+7 Strength",
    [866]  = "+7 Agility",
    [907]  = "+7 Stamina",
    [908]  = "+7 Intellect",
    [909]  = "+7 Spirit",
    [910]  = "+5 All Resistances",
    [912]  = "+9 Agility",
    [913]  = "+9 Strength",
    [929]  = "+2% Threat",
    [931]  = "+5 Fire Resistance",
    [2523] = "+30 Hit Rating",
    [2543] = "+7 Agility",
    [2545] = "+7 Intellect",
    [2603] = "+100 Attack Power vs Undead",
    [2616] = "+20 Agility",
    [2619] = "+30 Attack Power",
    [2620] = "+15 Spell Damage / +14 Spell Crit",
    [2622] = "+12 Dodge Rating",

    -- Additional commonly seen enchants
    [2660] = "+150 Mana",
    [2679] = "+6 Mana per 5 sec",
    [3273] = "Deathfrost",
    [3223] = "Adamantite Weapon Chain",
    [1883] = "+100 Health",
    [1884] = "+7 All Stats (Legacy)",
    [1885] = "+9 Intellect",
    [1886] = "+9 Spirit",
    [1887] = "+9 Stamina",
    [1889] = "+9 Strength",
    [1890] = "+9 Agility",
    [1892] = "+3 All Stats",
    [1893] = "+5 All Stats",
    [1895] = "Icy Chill",
    [1896] = "+9 Weapon Damage",
    [1897] = "+5 Weapon Damage",
    [1898] = "Fiery Weapon",
    [1899] = "Icy Chill",
    [1901] = "Minor Haste (1%)",
    [1903] = "Lifestealing",
    [1904] = "+15 Agility",
    [2523] = "+30 Hit Rating (Scope)",
    [2646] = "+25 Agility (2H)",
    [2647] = "+12 Strength",
    [2663] = "+18 Spell Damage",
    [2665] = "+12 Resilience (Chest)",
    [2681] = "+6 All Stats",
    [2682] = "+3 Agility",
    [2683] = "+15 Nature Resistance",
    [2684] = "+15 Fire Resistance",
    [2685] = "+15 Frost Resistance",
    -- [2721] removed — was incorrectly mapped; 2721 = Power of the Scourge (Naxx shoulder), Khorium Scope is 2723
    [2722] = "+10 Damage (Scope)",
    [2928] = "+12 Spell Damage (Ring)",
    [2929] = "+2 Weapon Damage (Ring)",
    [2930] = "+20 Healing (Ring)",
    [2931] = "+4 All Stats (Ring)",
    [2932] = "+12 Healing",
    [2936] = "+15 Spell Hit",
    [2945] = "+3% Haste",
    [2946] = "+12 Crit Rating",
    [3150] = "+6 Mana per 5 sec (Chest)",
    [3222] = "+20 Agility",
    [3225] = "Executioner",
    [3229] = "+12 Resilience (Shield)",
    [3231] = "+15 Haste Rating",
    [3232] = "+20 Hit Rating",
    [3233] = "+24 Spell Damage",
    [3234] = "+35 Spell Damage",
    [3236] = "+20 Resilience",
    [3238] = "+150 Health (2H)",
    [3239] = "+12 Hit Rating",
    [3241] = "+10 Spell Damage",
    [3243] = "+20 Stamina",
    [3244] = "+5 Stamina",
    [3245] = "+150 Health",
    [3249] = "+16 Spell Damage",
    [3253] = "+2% Threat (Gloves)",
}

-- Returns the enchant display name for any enchant effect ID, or nil
function B.GetEnchantName(enchantId)
    if not enchantId or enchantId == 0 then return nil end
    return B.ENCHANT_NAMES[enchantId]
end

-- Returns gem guidance table { meta, red, blue, yellow, prismatic } or nil
function B.GetGemGuidance(class, specTab)
    if not class or specTab == 0 then return nil end
    local classTbl = B.GEMS[class]
    if not classTbl then return nil end
    return classTbl[specTab]
end
