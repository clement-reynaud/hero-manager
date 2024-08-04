extends HBoxContainer

func _ready():
	pass


func set_item(item, amount):
	$InventoryListIcon.texture = item.icon_sprite
	$InventoryListLabel.text = str(amount)
