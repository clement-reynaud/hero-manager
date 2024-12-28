extends Building

@export var evolve_target: UnitType
@export var evolve_level_required: int = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	ready_selection_handler($TrainingButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($TrainingBorder)
	
func _on_body_entered(body):
	handle_timer_on_enter(body)
	mark_entity(body, "training")

	print(evolve_target != null)
	print(body.unit_type != evolve_target)
	print(not body._prev_evolution.has(evolve_target))
	if evolve_target != null and body.unit_type != evolve_target and not body._prev_evolution.has(evolve_target):
		print("huh")
		body.possible_evolve = evolve_target
		body.possible_evolve_level = evolve_level_required

func _on_body_exited(body):
	handle_timer_on_exit(body)
	unmark_entity(body, "training")

	body.possible_evolve = null
	body.possible_evolve_level = 0
