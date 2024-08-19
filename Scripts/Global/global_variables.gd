extends Node

var summoned_entity = 0;
var max_summoned_entity = 5;

var balance_damage_dealt_multiplier = 1
var balance_damage_reduction_multiplier = 1

enum EffectType {
    Attack,
    Magic,
    True,
    Heal
}

var EffectTypeColor = {
    EffectType.Attack: "#c96800",
    EffectType.Magic: "#006da6",
    EffectType.True: "white",
    EffectType.Heal: "green"
}
