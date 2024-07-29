extends CharacterBody2D

# Variables
var speed = 300
var target_position = Vector2.ZERO

@export var unit_type: UnitType

var timer_progress_bar = null

var selection_handler:SelectionHandler = preload("res://Scripts/Composition/selection_handler.gd").new()
var inventory_handler:InventoryHandler = preload("res://Scripts/Composition/inventory_handler.gd").new()


# Called when the node enters the scene tree for the first time
func _ready():
	if unit_type == null:
		unit_type = UnitType.new()
		print("Unit type not set for unit " + name)

	timer_progress_bar = $TimerProgressBar
	$TokenBackground.modulate = unit_type.background_color
	$TokenIcon.texture = unit_type.icon_sprite

	selection_handler.nodeToDisplay.append($EntityButtonContainer)
	
	inventory_handler.set_inventory_ui($InventoryUI)

# Called every frame
func _process(delta):
	# If the unit is selected, change its color to indicate selection
	selection_handler.handleSelection($TokenBorder)
	selection_handler.handleSelectedNodeDisplay()

	# If the unit has a timer child store it
	var timer = get_node_or_null("TimerProgress")
	if timer:
		# Set timer visible
		timer_progress_bar.visible = true
		timer_progress_bar.value = (timer.time_left / timer.wait_time) * 100
	else:
		# Set timer invisible
		timer_progress_bar.visible = false

# Called every physics frame
func _physics_process(delta):
	# Move towards the target position if it's set
	if target_position != Vector2.ZERO:
		move_to_target()

# Function to handle movement towards target position
func move_to_target():
	velocity = (target_position - position).normalized() * speed
	move_and_slide()

	# If the unit is close enough to the target position, stop moving
	if position.distance_to(target_position) < 5:
		target_position = Vector2.ZERO

	# If coliding with another unit, stop moving
	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			if collision.get_collider().is_in_group("unit") and collision.get_collider().target_position == Vector2.ZERO:
				target_position = Vector2.ZERO

# Function to set the target position for the unit to move towards
func set_target_position(new_target):
	target_position = new_target

# INVENTORY FUNCTIONS
func add_item(item:Item, amount:int = 1):
	inventory_handler.add_item(item, amount)

func transfer_item(item:Item, amount:int, target_inventory_handler:InventoryHandler):
	inventory_handler.transfer_item(item, amount, target_inventory_handler)

func get_items():
	return inventory_handler.get_items()

func is_inventory_full():
	return inventory_handler.is_inventory_full()

# SELECTION FUNCTIONS

# Function to select the unit
func select():
	selection_handler.select()
		
# Function to deselect the unit
func deselect():
	selection_handler.deselect()
	target_position = Vector2.ZERO

func is_selected():
	return selection_handler.is_selected()

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_released("select"):
		selection_handler.clear_select($"..")
