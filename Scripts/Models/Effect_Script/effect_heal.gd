extends Effect

static func can_cast(caster:Stats, skill:Skill) -> bool:
	if caster.mana >= skill.mana_cost:
		return true
	else:
		return false

static func get_target(caster:Stats, allies: Array, enemies: Array):
	var instance_allies = allies.duplicate()
	var instance_enemies = enemies.duplicate()
	handleTargetingStatus(caster, instance_allies, instance_enemies)

	var alive_allies = instance_allies.filter(Global_Functions._is_entity_alive)
	return alive_allies[randi() % alive_allies.size()]

static func cast(caster:Stats,target, skill:Skill) -> String:
	handlePreSkillStatus(caster, target, skill)

	caster.mana = max(caster.mana - skill.mana_cost,0)

	var critical = 1
	var variance = randf_range(0.5,1.5)

	if(randi() % 100 <= caster._current_luck):
		critical = 2

	var heal_value = ceil(caster._current_magic/10 * variance) * critical

	target.health = min(target.health + heal_value, target.max_health)

	handlePostSkillStatus(caster, target, skill)

	var combat_log_string = "[color={color}]{heal}[/color] health healed"
	combat_log_string = combat_log_string.format({"color": Global_Variables.StatsTypeColor[Global_Variables.StatsType.Heal], "heal": heal_value})
	combat_log_string += " [b][Critical][/b]" if critical == 2 else ""

	return combat_log_string
