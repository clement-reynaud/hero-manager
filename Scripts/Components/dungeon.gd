extends Building

@export var dungeon_layout: DungeonLayout

var _log_ui_displayed = false

var adventure_handler = load("res://Scripts/Composition/adventure_handler.gd").new()
var root_camera 


var entity_ressource_item = load("res://Scenes/UI/entity_ressource_item.tscn")

var cumulative_wait_time = 0
var font_size = 60

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($DungeonButtonContainer)
	root_camera = get_tree().get_root().get_node("World/Camera2D")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($DungeonBorder)

	process_participant_count(true, $DungeonCollisionShape2D)

	if _log_ui_displayed and selection_handler.is_selected():
		$LogUI.visible = true
	else:
		$LogUI.visible = false


			

func _on_body_entered(body):
	handle_timer_on_enter(body)
	#move_all_body_in_to_position(get_node("DungeonCollisionShape2D"), 200)
	add_participating_entity(body)


func _on_body_exited(body):
	handle_timer_on_exit(body)
	remove_participating_entity(body)

func _on_explore_button_pressed():
	if _participating_entities.size() > 0:
		cumulative_wait_time = 0

		for item in $LogUI/AllyStateUI/AllyStateScroll/AllyStateVBox.get_children():
			item.queue_free()
			

		$DungeonButtonContainer/ExploreButton.disabled = true
		adventure_handler.party = _participating_entities
		#adventure_handler.enemies = ennemies
		adventure_handler.adventure(self,dungeon_layout)

		var total_rank_sum = 0

		for entity in _participating_entities:
			total_rank_sum += entity.rank

		var actual_execution_time = adventure_handler.total_execution_time

		for entity in _participating_entities:
			update_timer(entity,adventure_handler.total_execution_time,false)

		_draw_log()

func _draw_log():
	if adventure_handler.combat_log.size() > 0:
		_clear_log()

		for log_line in adventure_handler.combat_log:
			$LogUI/LogScroll/LogVBox.add_child(_parse_log_line(log_line))

			if log_line.has("linked_message"):
				for linked_message in log_line.linked_message:
					$LogUI/LogScroll/LogVBox.add_child(_parse_log_line(linked_message,true))


		for entity_ressource in adventure_handler.combat_log[0].ressource_snapshot:
			var entity_ressource_item_instance = entity_ressource_item.instantiate()
			var entity_ressource_dict = adventure_handler.combat_log[0].ressource_snapshot[entity_ressource]
			entity_ressource_item_instance.init_with_dict(entity_ressource_dict)

			if entity_ressource_dict.is_player:
				$LogUI/AllyStateUI/AllyStateScroll/AllyStateVBox.add_child(entity_ressource_item_instance)
			else:
				$LogUI/EnemyStateUI/EnemyStateScroll/EnemyStateVBox.add_child(entity_ressource_item_instance)

func _clear_log():
	for child in $LogUI/LogScroll/LogVBox.get_children():
		child.queue_free()

	for child in $LogUI/AllyStateUI/AllyStateScroll/AllyStateVBox.get_children():
		child.queue_free()

	for child in $LogUI/EnemyStateUI/EnemyStateScroll/EnemyStateVBox.get_children():
		child.queue_free()

func _process_combat_log_queue(timer: Timer):
	cumulative_wait_time += timer.wait_time
	timer.queue_free()

	var log_line = adventure_handler.combat_log_queue[0]
	adventure_handler.combat_log_queue.remove_at(0)

	if log_line.type != "announcement":
		log_line.text = "[center]" + _format_time(cumulative_wait_time) + ":[/center]\n " + log_line.text

	log_line.text = log_line.text + "\n"

	adventure_handler.combat_log.insert(0,log_line)
	
	if adventure_handler.combat_log_queue.size() > 0:
		var combat_log_timer = Timer.new()
		combat_log_timer.one_shot = true

		if log_line.has("execution_time"):
			combat_log_timer.wait_time = log_line.execution_time 
			combat_log_timer.timeout.connect(self._process_combat_log_queue.bind(combat_log_timer))
			add_child(combat_log_timer)
			combat_log_timer.start()
		else:
			_process_combat_log_queue(combat_log_timer)
	
	_draw_log()


func _parse_log_line(log_line:Dictionary, linked_message:bool = false):
	var label = RichTextLabel.new()
	var text = log_line.text
	label.fit_content = true
	label.bbcode_enabled = true

	var current_font_size = font_size

	if linked_message:
		text = " | " + text

	if log_line.type == "announcement":	
		text = "[color=black][b]" + text + "[/b][/color]"
		current_font_size += current_font_size * 0.3

	elif log_line.type == "combat":
		text = "[color=black]" + text + "[/color]"
		current_font_size += current_font_size * 0.1

	elif log_line.type == "death":
		text = "[color=#661c16]" + text + "[/color]"
		current_font_size += current_font_size * 0.1

	if log_line.has("alignement"):
		text = "[{alignement}]" + text + "[/{alignement}]"
		text = text.format({"alignement":log_line.alignement})

	text = "[font_size={font_size}]" + text + "[/font_size]"
	text = text.format({"font_size":current_font_size})	

	label.append_text(text)
	return label

func _on_timer_timeout(unit):
	unit.set_selectable()
	$DungeonButtonContainer/ExploreButton.disabled = false

func _format_time(seconds:int) -> String:
	var m = floor(seconds / 60)
	var s = floor(seconds % 60)
	var h = floor(m / 60)
	return "%02d:%02d:%02d" % [h,m,s]


func _on_log_button_toggled(toggled_on):
	if toggled_on:
		_log_ui_displayed = true
		_draw_log()
	else:
		_log_ui_displayed = false
