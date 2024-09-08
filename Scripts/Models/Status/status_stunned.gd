extends Status

func get_status_name() -> String:
	return "Stunned"

func get_status_dict(caster, target, ratio = 0) -> Dictionary: 
	return {
		"name": get_status_name(),
		"turn_cpt": 1,
		"turn_manipulation": func (entity: Stats, can_play: Array, combat_log_queue = null):
			can_play[0] = false
			combat_log_queue.append({"type": "combat", "text": "[color=black]{entity_name}[/color] is [color=#a88732]stunned[/color], they can't act this turn.".format({"entity_name": entity.name}), "execution_time": 1, "ressource_snapshot": null})
	}
