extends Node

func blink_label(labels:Array[Label],  duration:float, color:Color, default_color = null) -> void:
	for label in labels:
		if default_color == null:
			label.set("theme_override_colors/font_color",default_color)

		label.set_meta("original_color",label.get("theme_override_colors/font_color")) # Store the original color
		label.set("theme_override_colors/font_color",color)			


	await get_tree().create_timer(duration).timeout

	for label in labels:
		# Create a coroutine to revert the color after a delay
		label.set("theme_override_colors/font_color",label.get_meta("original_color")) # Revert to the original color

func _is_entity_dead(entity:Stats):
	return entity.has_status("dead")

func _is_entity_alive(entity:Stats):
	return not _is_entity_dead(entity)

func format_skill_description(stat: Stats, string: String, detailed: bool = false) -> String:
	var parts = string.split(" [")
	var description = parts[0]
	var data = parts[1].split("]")
	var formula = data[0].split("|")
	var suffix = data[1]

	var ratio = float(formula[0].trim_suffix("%")) / 100.0
	var stat_value = stat.get(formula[1])
	var color_stat = formula[2]
	var variation = float(formula[3])
	var rounding = formula[4]

	var min_damage = stat_value * ratio
	if variation != 0:
		min_damage *= 1 - variation
	else:
		min_damage = round(min_damage)

	var max_damage = stat_value * ratio
	if variation != 0:
		max_damage *= 1 + variation
	else:
		max_damage = round(max_damage)

	if rounding == "floor":
		min_damage = floor(min_damage)
		max_damage = floor(max_damage)
	elif rounding == "ceil":
		min_damage = ceil(min_damage)
		max_damage = ceil(max_damage)

	var damage_range = ""
	if min_damage == max_damage:
		damage_range = " " + str(min_damage)
	else:
		damage_range = " " + str(min_damage) + " - " + str(max_damage)

	var color = ""
	if stat.get_stats_dict().keys().has(color_stat):
		color = stat.get_stat_color(color_stat)
	elif color_stat == "heal":
		color = Global_Variables.EffectTypeColor[Global_Variables.EffectType.Heal]
	elif color_stat == "true":
		color = Global_Variables.EffectTypeColor[Global_Variables.EffectType.True]

	if not detailed:
		damage_range = "[color=" + color + "]" + damage_range + "[/color]"
	else:
		damage_range = "[color=" + color + "]" + damage_range + " (" + formula[0] + " " + formula[1] + ", " + formula[3] + ", " + formula[4] + ")[/color]"

	return description + damage_range + suffix
