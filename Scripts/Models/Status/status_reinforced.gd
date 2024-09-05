extends Status

func get_status_name() -> String:
	return "Reinforced"

func get_status_dict(caster, target, ratio = 0) -> Dictionary: 
	return {
		"name": get_status_name(),
		"turn_cpt": 3,
		"apply_skill": func (entity_applied: Stats):
			caster._current_defence += ceil(caster.defence * ratio)
			caster._current_resistance += ceil(caster.resistance * ratio),
		"end_skill": func (entity_ending: Stats):
			caster._current_defence -= ceil(caster.defence * ratio)
			caster._current_resistance -= ceil(caster.resistance * ratio)}
