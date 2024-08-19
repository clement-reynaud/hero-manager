extends Effect

static func can_cast(caster:Stats, skill:Skill) -> bool:
	if caster.mana >= 1:
		return true
	else:
		return false

static func get_target(allies: Array, enemies: Array):
	var alive_enemies = enemies.filter(Global_Functions._is_entity_alive)
	return alive_enemies[randi() % alive_enemies.size()]

static func cast(caster:Stats,target:Stats, skill:Skill) -> String:
	var critical = 1
	var variance = randf_range(0.9,1.1)

	if(randi() % 100 <= caster.luck):
		critical = 2

	var damage = floor(((caster.magic * variance * Global_Variables.balance_damage_dealt_multiplier) * critical)  - (target.resistance * Global_Variables.balance_damage_reduction_multiplier))
	
	if damage < 0:
		damage = 0

	caster.mana = max(caster.mana - skill.mana_cost,0)
	target.health = max(target.health - damage,0)

	var combat_log_string = "[color={color}]{damage}[/color] damage dealt"
	combat_log_string = combat_log_string.format({"color": Global_Variables.EffectTypeColor[Global_Variables.EffectType.Magic], "damage": damage})
	combat_log_string += " [b][Critical][/b]" if critical == 2 else ""

	return combat_log_string
