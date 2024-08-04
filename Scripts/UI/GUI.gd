extends CanvasLayer

var global_inventory = {}

var tokenCpt
var inventory_list_container 
var inventory_list_box

func _ready():
	tokenCpt = %TokenCptText
	inventory_list_container = $InventoryListTexture/InventoryListContainer
	inventory_list_box = $InventoryListTexture/InventoryListContainer/InventoryListBox

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tokenCptText = str(Global_Variables.summoned_entity,"/",Global_Variables.max_summoned_entity)
	$TokenCpt/TokenCptText.text = tokenCptText


func _on_open_inventory_button_pressed():
		$InventoryListTexture.visible = !$InventoryListTexture.visible

		update_global_inventory_display()

func update_global_inventory_display():
	if $InventoryListTexture.visible:
		for item in inventory_list_box.get_children():
			inventory_list_box.remove_child(item)
			item.queue_free()

		var keys = global_inventory.keys()
		keys.sort()

		for itemKey in keys:
			var item = global_inventory[itemKey].item
			var amount = global_inventory[itemKey].amount

			var inventory_list_item = load("res://Scenes/UI/inventory_list_item.tscn").instantiate()
			inventory_list_item.set_item(item, amount)

			inventory_list_box.add_child(inventory_list_item)

func add_item_to_global_inventory(item:Item):
	if item.name in global_inventory:
		global_inventory[item.name].amount += 1
	else:
		global_inventory[item.name] = {}
		global_inventory[item.name].item = item 
		global_inventory[item.name].amount = 1
	update_global_inventory_display()

func remove_item_from_global_inventory(item:Item):
	if item.name in global_inventory:
		global_inventory[item.name].amount -= 1
	#if global_inventory[item.name].amount == 0:
	update_global_inventory_display()
