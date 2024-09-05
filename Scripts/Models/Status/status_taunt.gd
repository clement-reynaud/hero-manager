extends Status

func get_status_name() -> String:
	return "Taunt"

func get_status_dict(caster, target, ratio = 0) -> Dictionary: 
	return {
		"name": "Taunt",
		"turn_cpt": 3,
		"targeting": func (allies: Array, enemies: Array, combat_log_queue = null):
			if Global_Functions._is_entity_alive(caster):
				enemies.clear()
				enemies.append(caster)}
