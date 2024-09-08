extends Status

func get_status_name() -> String:
	return "Poisoned"

func get_status_dict(caster, target, ratio = 0) -> Dictionary: 
	return {
		"name": get_status_name(),
		"turn_cpt": 3,
		"post_skill_cast": func (c, t, s, combat_log):
			if c.health > 0:
				c.health -= 1,
		"caster_log_manipulation": func (entity, message, t, s, combat_log_queue):
			var text = "[color=#204f2a]{entity} took {poison_damage} poison damage[/color]"
			if message.linked_message != null and typeof(message.linked_message) == TYPE_ARRAY:
				#Search if linked_message already has poison
				var found_poison = null
				for m in message.linked_message:
					if m.has("is_poison") and m.is_poison:
						found_poison = m
						break
				
				if found_poison == null:
					text = text.format({"entity": entity.name, "poison_damage": 1})
					message.linked_message.insert(0,{"type": "combat", "is_poison": true, "text": text,"damage": 1})
				else:
					found_poison.damage += 1
					text = text.format({"entity": entity.name, "poison_damage": found_poison.damage})
					found_poison.text = text
	}
