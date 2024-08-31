extends Effect

static func can_cast(caster:Stats, skill:Skill) -> bool:
	return true

static func get_target(caster:Stats, allies: Array, enemies: Array):
	var instance_allies = allies.duplicate()
	var instance_enemies = enemies.duplicate()
	handleTargetingStatus(caster, instance_allies, instance_enemies)

	var alive_enemies = instance_enemies.filter(Global_Functions._is_entity_alive)
	return alive_enemies[randi() % alive_enemies.size()]

static func cast(caster:Stats,target:Stats, skill:Skill) -> String:
	handlePreSkillStatus(caster, target, skill)

	var ratio = 0.1

	target.set_status("Taunt", {
		"name": "Taunt",
		"turn_cpt": 3,
		"targeting": func (allies: Array, enemies: Array):
			if Global_Functions._is_entity_alive(caster):
				enemies.clear()
				enemies.append(caster)
	})

	#[10%|defense|defense|0varia|ceil] and [10%|resistance|resistance|0varia|ceil]
	caster.set_status("Reinforced", {
		"name": "Reinforced",
		"turn_cpt": 3,
		"apply_skill": func (caster_apply: Stats):
			caster._current_defense += ceil(caster.defense * ratio)
			caster._current_resistance += ceil(caster.resistance * ratio),
		"end_skill": func (caster_end: Stats):
			caster._current_defense -= ceil(caster.defense * ratio)
			caster._current_resistance -= ceil(caster.resistance * ratio)
	})

	var bonus_defense = ceil(caster.defense * ratio)
	var bonus_resistance = ceil(caster.resistance * ratio)
	handlePostSkillStatus(caster, target, skill)


	var combat_log_string = " they are taunted. {name} gains [color={defense_color}]{bonus_defense}[/color] defense and [color={resistance_color}]{bonus_resistance}[/color] resistance."
	combat_log_string = combat_log_string.format({
		"name": caster.name,
		"bonus_defense": bonus_defense, 
		"defense_color": caster.get_stat_color('defense'),
		"bonus_resistance": bonus_resistance,
		"resistance_color": caster.get_stat_color('resistance')
	})

	combat_log_string = handleLogManipulationStatus(combat_log_string, caster, target, skill)

	return combat_log_string
