extends Building

var collision_shape = null 

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($HouseButtonContainer)
	Global_Variables.max_summoned_entity += 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($HouseBorder)

func on_destroy():
	Global_Variables.max_summoned_entity -= 2
