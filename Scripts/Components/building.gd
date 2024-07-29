extends Area2D
class_name Building


# SELECTION
var selection_handler:SelectionHandler = preload("res://Scripts/Composition/selection_handler.gd").new()

func ready_selection_handler(nodeToAppend:Node):
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