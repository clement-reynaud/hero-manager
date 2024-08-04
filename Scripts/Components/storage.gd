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
		%GUI.add_item_to_global_inventory(unit.get_items()[0])
		unit.transfer_item(unit.get_items()[0], 1, inventory_handler)
	elif transfer_state == TransferState.POP:
		%GUI.remove_item_from_global_inventory(get_items()[0])
		transfer_item(get_items()[0], 1, unit.inventory_handler)

	if get_overlapping_bodies().has(unit) and (unit.inventory_handler.get_items().size() > 0 and transfer_state == TransferState.PUSH and not is_inventory_full()) or (inventory_handler.get_items().size() > 0 and transfer_state == TransferState.POP and not unit.is_inventory_full()):
			create_storage_timer(unit)

func _on_body_entered(body):
	handle_timer_on_enter(body)

	if body.is_in_group("unit") and not timers.has(body.get_instance_id()):
		if (body.inventory_handler.get_items().size() > 0 and transfer_state == TransferState.PUSH and not is_inventory_full()) or (inventory_handler.get_items().size() > 0 and transfer_state == TransferState.POP and not body.is_inventory_full()):
			create_storage_timer(body)

func create_storage_timer(linked_body):
	update_timer(linked_body, transfer_time / linked_body.rank)

func _on_body_exited(body):
	handle_timer_on_exit(body)	


func _on_inventory_mode_button_toggled(toggled_on):
	if toggled_on:
		transfer_state = TransferState.POP
	else:
		transfer_state = TransferState.PUSH
	reset_timer()

	if get_overlapping_bodies().size() > 0:
		for body in get_overlapping_bodies():
			print(body.is_in_group("unit"))
			if body.is_in_group("unit"):
				create_storage_timer(body)
