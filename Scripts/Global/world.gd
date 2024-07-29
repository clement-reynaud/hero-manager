extends Node2D

var TARGET_POSITION = Vector2.ZERO


var dragging = false  # Are we currently dragging?

var drag_start = Vector2.ZERO  # Location where drag began.
var select_rect = RectangleShape2D.new()  # Collision shape for drag box.
var selected = []  # Array of selected units.

# Called when the node enters the scene tree for the first time
func _ready():
	pass
	
# Called every frame
func _process(delta):
	if Input.is_action_just_pressed("move"):
		move_handler()

	if Input.is_action_just_pressed("stop"):
		TARGET_POSITION = Vector2.ZERO
		set_units_target_positions()	

	

func move_handler():
	TARGET_POSITION = get_global_mouse_position()
	set_units_target_positions()

# For each selected unit, move towards the target position
func set_units_target_positions():
	for unit in get_tree().get_nodes_in_group("unit"):
		if unit.is_selected():
			unit.set_target_position(TARGET_POSITION)

func _unhandled_input(event):
	if event.is_action_pressed("select"):
		dragging = true
		drag_start = get_local_mouse_position()
	elif event.is_action_released("select"):
		dragging = false
		queue_redraw()
		var drag_end = get_local_mouse_position()

		var calc_extents = (drag_end - drag_start) / 2
		calc_extents = calc_extents.abs()

		select_rect.extents = calc_extents
		var space = get_world_2d().direct_space_state
		var query = PhysicsShapeQueryParameters2D.new()
		query.collide_with_areas = true
		query.set_shape(select_rect)
		query.transform = Transform2D(0, (drag_end + drag_start) / 2)
		selected = space.intersect_shape(query)

		deselect_all()

		var has_unit = false

		for item in selected:
			if item.collider.is_in_group("unit"):
				has_unit = true

		for item in selected:
			if item.collider.is_in_group("selectable"):
				if has_unit and item.collider.is_in_group("unit"):
					item.collider.select()
				elif not has_unit:
					item.collider.select()


			


	if event is InputEventMouseMotion and dragging:
		queue_redraw()
		

func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),
				Color(0, 0, 1), false)

func deselect_all():
	for unit in get_tree().get_nodes_in_group("selectable"):
		unit.deselect()
