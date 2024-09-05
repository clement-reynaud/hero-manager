extends Effect

static func can_cast(caster:Stats, allies: Array, enemies: Array ,skill:Skill) -> bool:
	if caster._current_mana < skill.mana_cost:
		return false
	
	if enemies.filter(func (entity:Stats) -> bool: return not entity.has_status("Hexed")).size() == 0:
		return false

	return true

static func get_target(caster:Stats, allies: Array, enemies: Array):
	var instance_allies = allies.duplicate()
	var instance_enemies = enemies.duplicate()
	handleTargetingStatus(caster, instance_allies, instance_enemies)

	var alive_enemies = instance_enemies.filter(Global_Functions._is_entity_alive)
	var non_hexed_enemies = alive_enemies.filter(func (entity:Stats) -> bool: return not entity.has_status("Hexed"))

	if non_hexed_enemies.size() == 0:
		return alive_enemies[randi() % alive_enemies.size()]
	else:
		return non_hexed_enemies[randi() % non_hexed_enemies.size()]

static func cast(caster:Stats,target:Stats, skill:Skill) -> String:
	var combat_log_string = ""
	var status_hex = load("res://Scripts/Models/Status/status_hexed.gd").new()

	handlePreSkillStatus(caster, target, skill)

	#[10%|resistance|resistance|0varia|ceil]
	var ratio = 0.1

	caster.mana = max(caster.mana - skill.mana_cost,0)
	target.set_status(status_hex.get_status_name(), status_hex.get_status_dict(caster, target, ratio))

	combat_log_string = " they are hexed and loose [color={resistance_color}]{bonus_resistance}[/color] resistance."
	combat_log_string = combat_log_string.format({
		"resistance_color": caster.get_stat_color('resistance'),
		"bonus_resistance": ceil(caster.resistance * ratio)
	})

	handlePostSkillStatus(caster, target, skill)

	return combat_log_string
