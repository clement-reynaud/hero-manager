extends Building

var timers = {}

enum TransferState {
	PUSH,
	POP
}

@export var transfer_time = 5
@export var inventory_capacity = 10

var transfer_state:TransferState = TransferState.PUSH

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_inventory_handler($InventoryUI, inventory_capacity)
	ready_selection_handler($StorageButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($StorageBorder)

func _on_timer_timeout(unit):
	if transfer_state == TransferState.PUSH:
		unit.transfer_item(unit.get_items()[0], 1, inventory_handler)
	elif transfer_state == TransferState.POP:
		transfer_item(get_items()[0], 1, unit.inventory_handler)

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
	if body.is_in_group("unit") and not timers.has(body.get_instance_id()):
		if (body.inventory_handler.get_items().size() > 0 and transfer_state == TransferState.PUSH and is_inventory_full() == false) or (inventory_handler.get_items().size() > 0 and transfer_state == TransferState.POP and body.is_inventory_full() == false):
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

func reset_timer():
	for timer in timers.values():
		timer.queue_free()
	timers.clear()


func _on_inventory_mode_button_toggled(toggled_on):
	if toggled_on:
		transfer_state = TransferState.POP
	else:
		transfer_state = TransferState.PUSH
	reset_timer()
