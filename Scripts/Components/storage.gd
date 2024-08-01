extends Building

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

	if get_overlapping_bodies().has(unit) and unit.inventory_handler.get_items().size() > 0 and not inventory_handler.is_inventory_full():
			create_storage_timer(unit)

func _on_body_entered(body):
	handle_timer_on_enter(body)

	if body.is_in_group("unit") and not timers.has(body.get_instance_id()):
		if (body.inventory_handler.get_items().size() > 0 and transfer_state == TransferState.PUSH and not is_inventory_full()) or (inventory_handler.get_items().size() > 0 and transfer_state == TransferState.POP and body.is_inventory_full()):
			create_storage_timer(body)

func create_storage_timer(linked_body):
	update_timer(linked_body, transfer_time / linked_body.rank)

func _on_body_exited(body):
	handle_timer_on_exit(body)	

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
