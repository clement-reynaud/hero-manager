extends Node
class_name InventoryHandler

var inventory = Inventory.new()
var inventory_ui = null

func set_inventory_ui(ui):
	inventory_ui = ui

func draw_inventory():
	inventory_ui.draw_inventory(inventory)

func add_item(item:Item, amount:int = 1):
	inventory.add_item(item, amount)
	draw_inventory()

func remove_item(item:Item, amount:int = 1):
	inventory.remove_item(item, amount)
	draw_inventory()

func get_items() -> Array[Item]:
	return inventory.get_items()

func transfer_item(item:Item, amount:int, target_inventory_handler:InventoryHandler):
	if not target_inventory_handler.is_inventory_full() and inventory._content.has(item):
		remove_item(item, amount)
		target_inventory_handler.add_item(item, amount)
		draw_inventory()
		target_inventory_handler.draw_inventory()


func merge_to_inventory(target_inventory_handler:InventoryHandler):
	target_inventory_handler.inventory.merge_inventory(inventory, true)
	target_inventory_handler.draw_inventory()
	

func is_inventory_full():
	return inventory.is_inventory_full()
