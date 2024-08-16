extends Node

var summoned_entity = 0;
var max_summoned_entity = 5;

var balance_damage_dealt_multiplier = 1
var balance_damage_reduction_multiplier = 1

enum DamageType {
    Phyisical,
    Magic,
    True
}

var DamageTypeColor = {
    DamageType.Phyisical: "#c96800",
    DamageType.Magic: "#00a8ff",
    DamageType.True: "white"
}
