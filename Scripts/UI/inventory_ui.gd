extends Control

var grid = null

var is_open = false

func _ready():
	grid = $NinePatchRect/GridContainer
	
func _process(delta):
	if is_open:
		visible = true
	else:
		visible = false

func toggle_is_open():
	is_open = !is_open

func draw_inventory(inventory):
	# Clear grid
	for child in grid.get_children():
		child.queue_free()

	# Add all items
	for item in inventory.get_items():		
		var new_item = TextureRect.new()
		new_item.texture = item.icon_sprite
		grid.add_child(new_item)

func _on_inventory_button_toggled(toggled_on):
	toggle_is_open()

