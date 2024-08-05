extends Building

@export var ressource: MaterialItem = null

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set the sprite based on the resource type   
	$RessourceIcon.texture = ressource.icon_sprite	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($ProductionBorder)

func create_production_timer(linked_body):
	update_timer(linked_body, ressource.seconds_to_produce / linked_body.rank)

func _on_timer_timeout(unit):
	unit.add_item(ressource, 1)
	
	#If unit still in contact with mine, restart timer
	if get_overlapping_bodies().has(unit) and not unit.is_inventory_full():
			create_production_timer(unit)

func _on_body_entered(body):
	handle_timer_on_enter(body)

	if body.is_in_group("unit") and body.unit_type in allowed_unit_types and not timers.has(body.get_instance_id()) and not body.is_inventory_full():
		create_production_timer(body)


func _on_body_exited(body):
	handle_timer_on_exit(body)
