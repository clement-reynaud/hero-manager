extends CanvasLayer


var tokenCpt
var inventory_list_container 
var inventory_list_box

func _ready():
	tokenCpt = $TokenCpt/TokenCptText
	inventory_list_container = $InventoryList/InventoryListContainer
	inventory_list_box = $InventoryList/InventoryListContainer/InventoryListBox

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tokenCptText = str(Global_Variables.summoned_entity,"/",Global_Variables.max_summoned_entity)
	$TokenCpt/TokenCptText.text = tokenCptText

# GLOBAL INVENTORY

# {itemName: {item: MaterialItem, amount: int}}
var global_inventory = {}


func update_global_inventory_display():
	if $InventoryList.visible:
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

func has_ressources(ressources:Array[MaterialItem]):
	var compare_dict = {}
	var has = true

	for item in ressources:
		if item.name in compare_dict:
			compare_dict[item.name].amount += 1
		else:
			compare_dict[item.name] = {}
			compare_dict[item.name].item = item
			compare_dict[item.name].amount = 1

	if global_inventory.size() < compare_dict.size():
		return false

	for item in global_inventory:
		if item in compare_dict:
			if compare_dict[item].amount <= global_inventory[item].amount:
				print("has")
				continue
			else:
				print("no")
				has = false
		else:
			print("no")
			has =  false
	
	return has

# BUILD MENU

#TODO Gestion des technologies
@export var techtree: Array[Building_Blueprint]

func update_build_window_display():
	if $BuildMenu.visible:
		for item in $BuildMenu/BuildMenuGrid.get_children():
			$BuildMenu/BuildMenuGrid.remove_child(item)
			item.queue_free()

		for building in techtree:
			var building_menu_item = load("res://Scenes/UI/building_menu_item.tscn").instantiate()
			building_menu_item.set_item(building)

			$BuildMenu/BuildMenuGrid.add_child(building_menu_item)



# SIGNALS

func _toggle_gui_window(node):
		node.visible = !node.visible

func _on_open_inventory_button_pressed():
	_toggle_gui_window($InventoryList)
	update_global_inventory_display()

func _on_open_build_button_pressed():
	_toggle_gui_window($BuildMenu)
	update_build_window_display()
