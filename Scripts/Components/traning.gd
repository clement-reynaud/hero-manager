extends Building

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($TrainingButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($TrainingBorder)
	
func _on_body_entered(body):
	handle_timer_on_enter(body)
	mark_entity(body, "training")

func _on_body_exited(body):
	handle_timer_on_exit(body)
	unmark_entity(body, "training")
