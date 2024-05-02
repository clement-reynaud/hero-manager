extends Area2D

var timers = {}

enum TransferState {
	PUSH,
	POP
}

@export var transfer_time = 5
@export var inventory_capacity = 10

var transfer_state:TransferState = TransferState.PUSH

var selection_handler:SelectionHandler = preload("res://Scripts/Composition/selection_handler.gd").new()
var inventory_handler:InventoryHandler = preload("res://Scripts/Composition/inventory_handler.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_handler.set_inventory_ui($InventoryUI)
	inventory_handler.inventory.max_items = inventory_capacity
	selection_handler.nodeToDisplay.append($StorageButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	selection_handler.handleSelection($StorageBorder)
	selection_handler.handleSelectedNodeDisplay()

func _on_timer_timeout(unit):
	if transfer_state == TransferState.PUSH:
		unit.transfer_items(unit.get_items()[0], 1, inventory_handler)
	elif transfer_state == TransferState.POP:
		inventory_handler.transfer_items(inventory_handler.get_items()[0], 1, unit)

	if get_overlapping_bodies().has(unit):
		if timers.has(unit.get_instance_id()) and timers[unit.get_instance_id()].is_stopped() and unit.inventory_handler.get_items().size() > 0:
			timers[unit.get_instance_id()].start()
		else:
			timers[unit.get_instance_id()].queue_free()
			timers.erase(unit.get_instance_id())
	else:
		# Destroy timer node
		timers[unit.get_instance_id()].queue_free()
		timers.erase(unit.get_instance_id())	

func _on_body_entered(body):
	if body.is_in_group("unit") and not timers.has(body.get_instance_id()) and body.inventory_handler.get_items().size() > 0:
		var new_timer = Timer.new()
		if new_timer:
			new_timer.name = "TimerProgress"
			new_timer.one_shot = true
			new_timer.wait_time = transfer_time
			new_timer.timeout.connect(_on_timer_timeout.bind(body))
			body.add_child(new_timer)
			new_timer.start()
			timers[body.get_instance_id()] = new_timer


func _on_body_exited(body):
	if body.is_in_group("unit") and timers.has(body.get_instance_id()):
		var unit = timers[body.get_instance_id()].get_parent()
		timers[unit.get_instance_id()].queue_free()
		timers.erase(unit.get_instance_id())	

# INVENTORY FUNCTIONS
func add_item(item:Item, amount:int = 1):
	inventory_handler.add_item(item, amount)

func is_inventory_full():
	return inventory_handler.is_inventory_full()

func transfer_items(item:Item, amount:int, target_inventory_handler:InventoryHandler):
	inventory_handler.transfer_items(item, amount, target_inventory_handler)

func get_items():
	return inventory_handler.get_items()


# SELECTION FUNCTIONS

# Function to select the unit
func select():
	selection_handler.select()
		
# Function to deselect the unit
func deselect():
	selection_handler.deselect()

func is_selected():
	return selection_handler.is_selected()


func _on_input_event(viewport, event, shape_idx):
	if event.is_action_released("select"):
		selection_handler.clear_select($"..")
