extends GenericEntityUI

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)

func _draw_stats(stats:Stats):
	$StatsNinePatchRect/NameInputBorder/EntityName.text = stats.name

	var stats_dict = stats.get_stats_dict()

	for child in stats_dict:
		$StatsNinePatchRect/StatList.get_node(child + "/StatIcon").texture = stats.get_icon(child)
		$StatsNinePatchRect/StatList.get_node(child + "/StatValue").text = str(stats_dict[child])
		
func _on_stats_button_toggled(toggled_on):
	toggle_is_open()
	_draw_stats(attached_entity.stats)

func _on_name_input_changed(new_text):
	attached_entity.stats.name = new_text
