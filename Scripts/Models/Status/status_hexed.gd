extends Status

func get_status_name() -> String:
	return "Hexed"

func get_status_dict(caster, target, ratio = 0) -> Dictionary: 
	return {
		"name": get_status_name(),
		"turn_cpt": 3,
		"apply_skill": func (entity_applied: Stats):
			entity_applied._current_defence -= ceil(caster.resistance * ratio),
		"end_skill": func (entity_ending: Stats):
			entity_ending._current_defence += ceil(caster.resistance * ratio)
	}
