extends Building

@export var max_entities: int = 3

var _participating_entities = []

var adventure_handler = load("res://Scripts/Composition/adventure_handler.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($DungeonButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($DungeonBorder)

	$DungeonParticipantCount.text = str(_participating_entities.size()) + "/" + str(max_entities)

	for body in get_overlapping_bodies():
		if body.is_in_group("unit") and not _participating_entities.has(body):
			if not body.is_moving():
				move_body_in_to_position(body,get_node("DungeonCollisionShape2D"), 200)
			

func _on_body_entered(body):
	handle_timer_on_enter(body)
	#move_all_body_in_to_position(get_node("DungeonCollisionShape2D"), 200)
	if _participating_entities.size() < max_entities and body.is_in_group("unit") and body.unit_type in allowed_unit_types:
		_participating_entities.append(body)


func _on_body_exited(body):
	handle_timer_on_exit(body)
	if _participating_entities.has(body):
		_participating_entities.remove_at(_participating_entities.find(body))

func _on_explore_button_pressed():
	adventure_handler.party = _participating_entities
	#adventure_handler.enemies = ennemies
	adventure_handler.adventure(self)
	for entity in _participating_entities:
		update_timer(entity,adventure_handler.total_execution_time)

func _on_timer_timeout(unit):
	unit.set_selectable()
