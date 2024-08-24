extends Area2D
class_name Building

@export var allowed_unit_types: Array[UnitType] = []

func get_random_position_outside_area(area: Area2D, collision_shape: CollisionShape2D, lower_bound: float, upper_bound: float) -> Vector2:
	var area_rect = collision_shape.shape.get_rect() # Assuming the Area2D has a rectangular collision shape
	var area_position = area.global_position
	var area_size = area_rect.size
	
	var new_position = Vector2()
	var angle = randf() * 2 * PI
	var distance = lower_bound + randf() * (upper_bound - lower_bound)
	
	new_position.x = cos(angle) * distance
	new_position.y = sin(angle) * distance

	# Determine the side on which to place the position
	if randi() % 2 == 0:
		new_position.x += area_position.x + (area_size.x / 2 + ((randi() % 2) * 2 - 1) * (area_size.x / 2))
		new_position.y += area_position.y + ((randi() % 2) * 2 - 1) * (area_size.y / 2)
	else:
		new_position.x += area_position.x + ((randi() % 2) * 2 - 1) * (area_size.x / 2)
		new_position.y += area_position.y + (area_size.y / 2 + ((randi() % 2) * 2 - 1) * (area_size.y / 2))

	return new_position

func move_all_body_in_to_position(collision_shape:CollisionShape2D = null, lower_bound: float = 100, upper_bound: float = 200):
	for body in get_overlapping_bodies():
		if body.is_in_group("unit"):
			body.set_target_position(get_random_position_outside_area(self, collision_shape , lower_bound, upper_bound))

func move_body_in_to_position(body:Node2D, collision_shape:CollisionShape2D = null, lower_bound: float = 100, upper_bound: float = 200):
	body.set_target_position(get_random_position_outside_area(self, collision_shape , lower_bound, upper_bound))

# MARKING

func mark_entity(entity:Node2D,mark_name:String):
	if not entity.marks.has(mark_name) and allowed_unit_types.has(entity.unit_type):
		entity.marks.append(mark_name)

func unmark_entity(entity:Node2D,mark_name:String):
	if entity.marks.has(mark_name) and allowed_unit_types.has(entity.unit_type):
		entity.marks.erase(mark_name)

# SELECTION
var selection_handler:SelectionHandler = preload("res://Scripts/Composition/selection_handler.gd").new()

func ready_selection_handler(nodeToAppend:Node = null):
	if nodeToAppend != null:
		selection_handler.nodeToDisplay.append(nodeToAppend)

func process_selection_handler(borderSprite:Sprite2D):
	selection_handler.handleSelection(borderSprite)
	selection_handler.handleSelectedNodeDisplay()

func select():
	selection_handler.select()
		
func deselect():
	selection_handler.deselect()

func is_selected():
	return selection_handler.is_selected()

# INVENTORY
var inventory_handler:InventoryHandler = preload("res://Scripts/Composition/inventory_handler.gd").new()

func ready_inventory_handler(inventoryUi:Node, inventory_capacity:int):
	inventory_handler.set_inventory_ui(inventoryUi)
	inventory_handler.inventory.max_items = inventory_capacity

func add_item(item:Item, amount:int = 1):
	inventory_handler.add_item(item, amount)

func is_inventory_full():
	return inventory_handler.is_inventory_full()

func transfer_item(item:Item, amount:int, target_inventory_handler:InventoryHandler):
	inventory_handler.transfer_item(item, amount, target_inventory_handler)

func get_items():
	return inventory_handler.get_items()


#TIMERS
# WARNING To use timers, the child object MUST have a _on_timer_timeout() function 

var timers = {}

func update_timer(unit, base_wait_time, use_rank_modifier = true):
	var timer = _get_or_create_timer(unit)
	
	if use_rank_modifier:
		timer.wait_time = base_wait_time / unit.rank
	else:
		timer.wait_time = base_wait_time
	
	timer.start()
	timers[unit.get_instance_id()] = timer


func _get_or_create_timer(unit):
	if unit.get_node_or_null("TimerProgress") != null:
		var timer = unit.get_node_or_null("TimerProgress")
		timer.stop()
		timer.disconnect("timeout",timer.get_meta("timer_callable"))
		timer.timeout.connect(self._on_timer_timeout.bind(unit))
		timer.set_meta("timer_callable", Callable(self, "_on_timer_timeout"))
		return timer
	else:
		var timer = _create_timer(unit)
		return timer

func _create_timer(unit):
	var timer = Timer.new()
	timer.name = "TimerProgress"
	timer.one_shot = true
	timer.timeout.connect(self._on_timer_timeout.bind(unit))
	timer.set_meta("timer_callable", Callable(self, "_on_timer_timeout"))
	unit.add_child(timer)
	return timer


func stop_unit_timer(unit):
	if timers.has(unit.get_instance_id()):
		var timer = timers[unit.get_instance_id()]
		timer.stop()

func reset_timer():
	for timer in timers.values():
		timer.stop()
	timers = {}

func handle_timer_on_enter(body):
	if body.is_in_group("unit") and not timers.has(body.get_instance_id()):
		for building in body.overlapping_buildings:
			building.stop_unit_timer(body)
		
		body.overlapping_buildings.append(self)

func handle_timer_on_exit(body):
	if body.is_in_group("unit"):
		var unit = body
		
		body.overlapping_buildings.remove_at(body.overlapping_buildings.find(self))
		if body.overlapping_buildings.size() == 0:
			stop_unit_timer(unit)

		timers.erase(unit.get_instance_id())
