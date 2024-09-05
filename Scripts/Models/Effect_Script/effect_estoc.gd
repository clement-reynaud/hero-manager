extends Effect

static func can_cast(caster:Stats, allies: Array, enemies: Array ,skill:Skill) -> bool:
	if caster.mana >= skill.mana_cost:
		return true
	else:
		return false

static func get_target(caster:Stats, allies: Array, enemies: Array):
	var instance_allies = allies.duplicate()
	var instance_enemies = enemies.duplicate()
	handleTargetingStatus(caster, instance_allies, instance_enemies)
	
	#Find lowest health enemy
	var list_enemies = Array(instance_enemies)
	list_enemies.sort_custom(func(a, b): return a.health < b.health)
	list_enemies = list_enemies.filter(Global_Functions._is_entity_alive)
	
	return list_enemies[0]

static func cast(caster:Stats,target, skill:Skill) -> String:
	handlePreSkillStatus(caster, target, skill)

	var critical = 1
	var variance = 1

	if(randi() % 100 <= caster._current_luck):
		critical = 2

	var ratio = 0.9
	var damage = ceil(calc_damage(caster._current_attack,ratio,variance,critical)  - ((target._current_defence * 0.9) * Global_Variables.balance_damage_reduction_multiplier))

	if damage < 0:
		damage = 0

	target.health = max(target.health - damage,0)
	caster.mana = max(caster.mana - skill.mana_cost,0)

	handlePostSkillStatus(caster, target, skill)

	var combat_log_string = "[color={color}]{damage}[/color] damage dealt"
	combat_log_string = combat_log_string.format({"color": Global_Variables.StatsTypeColor[Global_Variables.StatsType.Attack], "damage": damage})
	combat_log_string += " [b][Critical][/b]" if critical == 2 else ""

	return combat_log_string