extends Effect

static func can_cast(caster:Stats, allies: Array, enemies: Array ,skill:Skill) -> bool:
	return true

static func get_target(caster:Stats, allies: Array, enemies: Array):
	var instance_allies = allies.duplicate()
	var instance_enemies = enemies.duplicate()
	handleTargetingStatus(caster, instance_allies, instance_enemies)

	var alive_enemies = instance_enemies.filter(Global_Functions._is_entity_alive)
	return alive_enemies[randi() % alive_enemies.size()]

static func cast(caster:Stats,target:Stats, skill:Skill) -> String:
	handlePreSkillStatus(caster, target, skill)

	var critical = 1
	var variance = randf_range(0.5,1.5)

	if(randi() % 100 <= caster._current_luck):
		critical = 2

	var ratio = 1

	var damage = floor(base_damage_formula(caster._current_attack,ratio,variance,critical,target._current_defence))
	
	if damage < 0:
		damage = 0

	target.health = max(target.health - damage,0)

	handlePostSkillStatus(caster, target, skill)

	var combat_log_string = "[color={color}]{damage}[/color] damage dealt"
	combat_log_string = combat_log_string.format({"color": Global_Variables.StatsTypeColor[Global_Variables.StatsType.Attack], "damage": damage})
	combat_log_string += " [b][Critical][/b]" if critical == 2 else ""

	return combat_log_string
