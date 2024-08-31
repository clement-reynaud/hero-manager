extends Node

var current_entity = null

var summoned_entity = 0;
var max_summoned_entity = 5;

var balance_damage_dealt_multiplier = 1
var balance_damage_reduction_multiplier = 1

enum StatsType {
    Attack,
    Magic,
    Defence,
    Resistance,
    Speed,
    Luck,
    Health,
    Mana,
    True,
    Heal
}

var StatsTypeColor = {
    StatsType.Attack: "#c96800",
    StatsType.Magic: "#006da6",
    StatsType.Defence: "white",
    StatsType.Resistance: "white",
    StatsType.Speed: "white",
    StatsType.Luck: "white",
    StatsType.Health: "white",
    StatsType.Mana: "white",
    StatsType.True: "white",
    StatsType.Heal: "green"
}
