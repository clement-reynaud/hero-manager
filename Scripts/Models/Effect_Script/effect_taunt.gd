extends Effect

static func can_cast(caster:Stats, skill:Skill) -> bool:
	if caster.has_status("Reinforced"):
		return false

	return true

static func get_target(caster:Stats, allies: Array, enemies: Array):
	var instance_allies = allies.duplicate()
	var instance_enemies = enemies.duplicate()
	handleTargetingStatus(caster, instance_allies, instance_enemies)

	var alive_enemies = instance_enemies.filter(Global_Functions._is_entity_alive)
	return alive_enemies[randi() % alive_enemies.size()]

static func cast(caster:Stats,target:Stats, skill:Skill) -> String:
	var status_reinforced = load("res://Scripts/Models/Status/status_reinforced.gd")
	var status_taunt = load("res://Scripts/Models/Status/status_taunt.gd")

	handlePreSkillStatus(caster, target, skill)

	var ratio = 0.1

	target.set_status(status_taunt.get_status_name(), status_taunt.get_status_dict(caster, target))

	#[10%|defence|defence|0varia|ceil] and [10%|resistance|resistance|0varia|ceil]
	caster.set_status(status_reinforced.get_status_name(), status_reinforced.get_status_dict(caster, target, ratio))

	var bonus_defence = ceil(caster.defence * ratio)
	var bonus_resistance = ceil(caster.resistance * ratio)
	handlePostSkillStatus(caster, target, skill)


	var combat_log_string = " they are taunted. {name} gains [color={defence_color}]{bonus_defence}[/color] defence and [color={resistance_color}]{bonus_resistance}[/color] resistance."
	combat_log_string = combat_log_string.format({
		"name": caster.name,
		"bonus_defence": bonus_defence, 
		"defence_color": caster.get_stat_color('defence'),
		"bonus_resistance": bonus_resistance,
		"resistance_color": caster.get_stat_color('resistance')
	})

	combat_log_string = handleLogManipulationStatus(combat_log_string, caster, target, skill)

	return combat_log_string
