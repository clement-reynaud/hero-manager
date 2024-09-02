extends Status

static func get_status_name() -> String:
	return "Reinforced"

static func get_status_dict(caster, target, ratio = 0) -> Dictionary: 
	return {
		"name": "Reinforced",
		"turn_cpt": 3,
		"apply_skill": func (caster_apply: Stats):
			caster._current_defence += ceil(caster.defence * ratio)
			caster._current_resistance += ceil(caster.resistance * ratio),
		"end_skill": func (caster_end: Stats):
			caster._current_defence -= ceil(caster.defence * ratio)
			caster._current_resistance -= ceil(caster.resistance * ratio)}
