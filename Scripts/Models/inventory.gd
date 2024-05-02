class_name Inventory

var max_items:int = 10
var _content:Array[Item] = []

func add_item(item:Item, amount:int = 1):
    if _content.size() <= max_items:
        for i in range(amount):
            _content.append(item)

func remove_item(item:Item, amount:int = 1):
    for i in range(amount):
        _content.erase(item)

func is_inventory_full() -> bool:
    return _content.size() >= max_items

func get_items() -> Array[Item]:
    return _content