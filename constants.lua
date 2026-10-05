--ringGlyphDistances = {}
poo = {
    nauvis = 1,
    gleba = 5,
    aquilo = 2,
    vulcanus = 4,
    fulgora = 3,
}
sgNames = {
    placement = "kj_stargate_placement",
    placementSignaled = "kj_stargate_signaled_placement",
    placementSignaledIris = "kj_stargate_signaled_iris_placement",

    base = "kj_stargate_base",
    sound = "kj_stargate_ambientSound",
    lights = "kj_stargate_lamps",
    rings = "kj_stargate_ring",
    pole = "kj_stargate_pole_",
    entity = "kj_stargate_entity",
    entitySignaled = "kj_stargate_entity_signaled",
    tpArea = "kj_stargate_transferArea",
    ringSound = "kj_stargate_ringSound",
    iris = "kj_stargate_iris",

    colliderV = "kj_stargate_colliderVert",
    colliderHL = "kj_stargate_colliderHoriLong",
    colliderHLL = "kj_stargate_colliderHoriLonger",
    colliderHB = "kj_stargate_colliderHoriBig",
    colliderHS = "kj_stargate_colliderHoriShort",
    colliderD = "kj_stargate_colliderDiag",

    dhdName = "kj_dhd"
}
qualities = {
    "normal",
    "uncommon",
    "rare",
    "epic",
    "legendary",
}
entOffY = {
    base = -1.9,
    baseBck = -2.5,
    entS = -1.8-0.33,
    ent = -1.8-0.33,
    w = 0.8,
    wg = 0.55,
    sg = 1.3,
    eff1 = 2.5,
    eff2 = 5.5,
    eF = 1.925,
}
direction = {
    "left",
    "straight",
    "right",
}
strToBool = {
    ["true"] = true,
    ["false"] = false,
}
onDamagedEntities = {
    kj_stargate_entity = true,
    kj_stargate_entity_signaled = true,

    kj_dhd = true,

    kj_stargate_auto_gen = true,
    kj_dhd_auto_gen = true,

    kj_stargate_pole_visible_left = true,
    kj_stargate_pole_visible_right = true,
}

--full list of chevrons without poos - order is trivial
chevronChars = {}
for i = string.byte("A"), string.byte("S") do
    table.insert(chevronChars, string.char(i))
end
for i = string.byte("a"), string.byte("s") do
    table.insert(chevronChars, string.char(i))
end

--full list of chevrons - order = animation_offset for dhd
charLookup = {}
for i, char in ipairs(chevronChars) do
    charLookup[char] = i
end
for i = 1, 5, 1 do
    charLookup["poo_"..i] = 1
end

--full list of chevrons with 1 poo - order = ring chevron order
ringChars = {
"poo","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S",
      "a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s"
}

ringCharPos = {}
for i, char in ipairs(ringChars) do
    ringCharPos[char] = i
end
