extends GenericEntityUI

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)

func _draw_stats(stats:PlayerStats):
	$StatsNinePatchRect/NameInputBorder/EntityName.text = stats.name

	var stats_dict = stats.get_stats_dict()

	for child in stats_dict:
		$StatsNinePatchRect/StatList.get_node(child + "/StatIcon").texture = stats.get_icon(child)
		$StatsNinePatchRect/StatList.get_node(child + "/StatValue").text = str(stats_dict[child])

	$LevelNinePatchRect/LevelUpControl/KnowledgeCost.text = str(stats.level_up_data["function"].call(stats.level))
	$EvolveNinePatchRect/EvolveControl/KnowledgeCost.text = str(stats.level_up_data["function"].call(stats.level))
	$EvolveNinePatchRect/EvolveControl/LevelReq.text = str(stats.level) + "/" + str(stats.attached_entity.possible_evolve_level)
	if stats.level < stats.attached_entity.possible_evolve_level:
		$EvolveNinePatchRect/EvolveControl/LevelReq.set("theme_override_colors/font_color", Color.RED)
	else:
		$EvolveNinePatchRect/EvolveControl/LevelReq.set("theme_override_colors/font_color", Color.GREEN)

func handle_level_up_blink(growths:Array):
	var blink_label:Array[Label] = []

	for stat in growths:
		var label = $StatsNinePatchRect/StatList.get_node(stat + "/StatValue")
		blink_label.append(label)
		label.set("theme_override_colors/font_color",Color.GREEN)

	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1
	timer.timeout.connect(_blink_label_timeout.bind(blink_label, timer))
	timer.start()

func _blink_label_timeout(blink_label:Array[Label], timer):
	for label in blink_label:
		label.set("theme_override_colors/font_color",Color.BLACK)

	timer.queue_free()

func _on_stats_button_toggled(toggled_on):
	toggle_is_open()
	_draw_stats(attached_entity.stats)

func _on_name_input_changed(new_text):
	attached_entity.stats.name = new_text

func _on_level_up_button_pressed():
	attached_entity.level_up()
	_draw_stats(attached_entity.stats)
