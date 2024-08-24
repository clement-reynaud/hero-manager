extends Building

var _analyzer_displayed = false

var _participating_entity = null
var max_entities: int = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($AnalyzerButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($AnalyzerBorder)
	
	for body in get_overlapping_bodies():
		if body.is_in_group("unit") and _participating_entity != body:
			if not body.is_moving():
				move_body_in_to_position(body,get_node("AnalyzerCollisionShape2D"), 200)

	if _analyzer_displayed and selection_handler.is_selected():
		$AnalyserDisplay.visible = true
	else:
		$AnalyserDisplay.visible = false

func _on_body_entered(body):
	if _participating_entity == null and body.is_in_group("unit") and body.unit_type in allowed_unit_types:
		_participating_entity = body
		_draw_analyze(body.stats)	


func _on_body_exited(body):
	if _participating_entity == body:
		_participating_entity = null

func _draw_analyze(stats:PlayerStats):
	var growth_dict = stats.get_growth_dict()
	var growth_total = 0

	for growth in growth_dict:
		$AnalyserDisplay/GrowthNinePatchRect/GrowthList.get_node(growth + "/StatIcon").texture = stats.get_icon(growth)
		$AnalyserDisplay/GrowthNinePatchRect/GrowthList.get_node(growth + "/StatValue").text = str(growth_dict[growth]) + "%"
		growth_total += growth_dict[growth]

	set_growth_rank_texture(growth_total)
	$AnalyserDisplay/GrowthNinePatchRect/GrowthTotalLabel.text = str(growth_total)
	
	$AnalyserDisplay/GrowthNinePatchRect/LevelUpSpeedLabel.text = stats.level_up_data["speed"]

func _on_display_button_toggled(toggled_on):
	if _participating_entity == null:
		return

	$AnalyserDisplay.visible = toggled_on
	_analyzer_displayed = toggled_on

	if toggled_on:
		_draw_analyze(_participating_entity.stats)

func set_growth_rank_texture(growth_total:int):
	if growth_total >= 350 and growth_total <= 399:
		$AnalyserDisplay/GrowthNinePatchRect/GrowthRank.texture = load("res://Ressources/Sprite/UI/RankLetter/c_rank.png")
	elif growth_total >= 400 and growth_total <= 449:
		$AnalyserDisplay/GrowthNinePatchRect/GrowthRank.texture = load("res://Ressources/Sprite/UI/RankLetter/b_rank.png")
	elif growth_total >= 450 and growth_total <= 499:
		$AnalyserDisplay/GrowthNinePatchRect/GrowthRank.texture = load("res://Ressources/Sprite/UI/RankLetter/a_rank.png")
	elif growth_total >= 500 and growth_total <= 549:
		$AnalyserDisplay/GrowthNinePatchRect/GrowthRank.texture = load("res://Ressources/Sprite/UI/RankLetter/s_rank.png")
	elif growth_total == 550:
		$AnalyserDisplay/GrowthNinePatchRect/GrowthRank.texture = load("res://Ressources/Sprite/UI/RankLetter/g_rank.png")
	else:
		$AnalyserDisplay/GrowthNinePatchRect/GrowthRank.texture = load("res://Ressources/Sprite/UI/RankLetter/c_rank.png")
