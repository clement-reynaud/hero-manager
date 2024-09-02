extends Building

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($HealButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($HealBorder)
	process_participant_count(true, $HealCollisionShape2D)
	
func _on_body_entered(body):
	handle_timer_on_enter(body)
	add_participating_entity(body)

func _on_body_exited(body):
	handle_timer_on_exit(body)
	remove_participating_entity(body)

func heal_all_participating_entities():
	for entity in _participating_entities:
		var stat = entity.stats
		var total_time = 0

		total_time += (stat.max_health - stat.health) * 4
		total_time += (stat.max_mana - stat.mana) * 4

		update_timer(entity,total_time,true)

func _on_timer_timeout(unit):
	unit.stats.full_restore()


func _on_heal_button_pressed():
	heal_all_participating_entities()
