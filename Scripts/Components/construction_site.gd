extends Building

var building_blueprint:Building_Blueprint
var placed = false
var placable = true

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($ConstructionSiteButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !placed:
		position = get_global_mouse_position()

		if Input.is_action_just_pressed("select") and placable:
			placed = true
	else:
		process_selection_handler($ConstructionSiteBorder)

func _on_timer_timeout(unit):
	var new_build = building_blueprint.scene.instantiate()
	get_tree().get_root().get_node("World").add_child(new_build)
	new_build.global_position = global_position
	self.queue_free()

func _on_body_entered(body):
	if placed:
		handle_timer_on_enter(body)

		if body.is_in_group("unit") and not timers.has(body.get_instance_id()):
			create_build_timer(body)

func create_build_timer(linked_body):
	update_timer(linked_body, building_blueprint.build_time / linked_body.rank)

func set_building_blueprint(building:Building_Blueprint):
	building_blueprint = building

func _on_body_exited(body):
	handle_timer_on_exit(body)


func _on_area_entered(area):
	$ConstructionSiteSprite.modulate = Color(1, 0, 0, 1)
	placable = false
	

func _on_area_exited(area):
	$ConstructionSiteSprite.modulate = Color(1, 1, 1, 1)
	placable = true
