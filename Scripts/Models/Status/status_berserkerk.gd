extends Status

func get_status_name() -> String:
	return "Berserker"

func get_status_dict(caster, target, ratio = 0) -> Dictionary: 
	return {
		"name": get_status_name(),
		"turn_cpt": 1,
		"targeting": func (allies: Array, enemies: Array, combat_log_queue = null):
			if Global_Functions._is_entity_alive(caster):
				var tmp_enemies = enemies.duplicate()
				var tmp_allies = allies.duplicate()
				
				enemies.append_array(tmp_allies)
				allies.append_array(tmp_enemies)
	}
