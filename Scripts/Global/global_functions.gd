extends Node

var blink_timers = []

func blink_label(labels:Array[Label],  duration:float, color:Color, default_color = null) -> void:
	for label in labels:
		if default_color == null:
			label.set("theme_override_colors/font_color",default_color)

		label.set_meta("original_color",label.get("theme_override_colors/font_color")) # Store the original color
		label.set("theme_override_colors/font_color",color)			

	for timer in blink_timers:
		timer.emit_signal("timeout")

	var timer = get_tree().create_timer(duration)
	blink_timers.append(timer)
	await timer.timeout

	for label in labels:
		# Create a coroutine to revert the color after a delay
		label.set("theme_override_colors/font_color",label.get_meta("original_color")) # Revert to the original color

	blink_timers.remove_at(blink_timers.find(timer))

func _is_entity_dead(entity:Stats):
	return entity.has_status("dead")

func _is_entity_alive(entity:Stats):
	return not _is_entity_dead(entity)

func format_skill_description(stat: Stats, string: String, detailed: bool = false) -> String:
	var regex = RegEx.new()
	regex.compile("\\[(.*?)\\]")
	var matches = regex.search_all(string)
	for match in matches:
		var formula = match.get_string().substr(1, match.get_string().length() - 2).split("|")
		var ratio = float(formula[0].rstrip("%")) / 100.0
		var stat_value = stat.get(formula[1])

		var color = ""
		if stat.get_stats_dict().keys().has(formula[2]):
			color = stat.get_stat_color(formula[2])
		elif formula[2] == "heal":
			color = Global_Variables.StatsTypeColor[Global_Variables.StatsType.Heal]
		elif formula[2] == "true":
			color = Global_Variables.StatsTypeColor[Global_Variables.StatsType.True]

		var min_variance = 1.0
		var max_variance = 1.0

		if formula[3].ends_with("varia"):
			var variance_amount = float(formula[3].rstrip("varia"))
			min_variance = 1.0 - variance_amount
			max_variance = 1.0 + variance_amount
		else:
			min_variance = 1.0
			max_variance = 1.0

		var min_result = stat_value * ratio * min_variance
		var max_result = stat_value * ratio * max_variance

		if formula[4] == "ceil":
			min_result = ceil(min_result)
			max_result = ceil(max_result)
		elif formula[4] == "floor":
			min_result = floor(min_result)
			max_result = floor(max_result)

		var replacement = ""
		if not detailed:
			if min_result == max_result:
				replacement = "[color=" + color + "]" + str(min_result) + "[/color]"
			else:
				replacement = "[color=" + color + "]" + str(min_result) + " - " + str(max_result) + "[/color]"
			string = string.replace("[" + match.get_string().substr(1, match.get_string().length() - 2) + "]", replacement)
		else:
			string = string.replace("[" + match.get_string().substr(1, match.get_string().length() - 2) + "]", "[color=" + color + "][" + match.get_string().substr(1, match.get_string().length() - 2) + "][/color]")
	return string


var level_up_function = {
	"slow":{"function":func (level): return ceil(5 * pow(level,3) / 4 + 16),"speed":"Slow"},
	"medium":{"function":func (level): return ceil(pow(level,3) + 12),"speed":"Medium"},
	"fast":{"function":func (level): return ceil(4 * pow(level,3) / 5 + 8),"speed":"Fast"},
}
