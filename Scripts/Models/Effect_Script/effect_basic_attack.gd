static func can_cast(caster:Stats) -> bool:
	return true

static func get_target(allies: Array, enemies: Array) -> Stats:
	return enemies[randi() % enemies.size()]

static func cast(caster:Stats,target:Stats) -> String:
	var critical = 1
	var variance = randf_range(0.9,1.1)

	if(randi() % 100 <= caster.luck):
		critical = 2

	var damage = floor(((caster.attack * variance * Global_Variables.balance_damage_dealt_multiplier) * critical)  - (target.defense * Global_Variables.balance_damage_reduction_multiplier))
	
	if damage < 0:
		damage = 0

	target.health = max(target.health - damage,0)

	var combat_log_string = "[color={color}]{damage}[/color] damage dealt"
	combat_log_string = combat_log_string.format({"color": Global_Variables.DamageTypeColor[Global_Variables.DamageType.Phyisical], "damage": damage})
	combat_log_string += " [Critical]" if critical == 2 else ""

	return combat_log_string
