extends Effect

static func can_cast(caster:Stats, skill:Skill) -> bool:
	if caster.mana >= skill.mana_cost:
		return true
	else:
		return false

static func get_target(allies: Array, enemies: Array):
	var alive_allies = allies.filter(Global_Functions._is_entity_alive)
	return alive_allies[randi() % alive_allies.size()]

static func cast(caster:Stats,target, skill:Skill) -> String:
	caster.mana = max(caster.mana - skill.mana_cost,0)

	var critical = 1
	var variance = randf_range(0.5,1.5)

	if(randi() % 100 <= caster.luck):
		critical = 2

	var heal_value = ceil(caster.magic/10 * variance) * critical

	target.health = min(target.health + heal_value, target.max_health)
	
	var combat_log_string = "[color={color}]{heal}[/color] health healed"
	combat_log_string = combat_log_string.format({"color": Global_Variables.EffectTypeColor[Global_Variables.EffectType.Heal], "heal": heal_value})
	combat_log_string += " [b][Critical][/b]" if critical == 2 else ""

	return combat_log_string
