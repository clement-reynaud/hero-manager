extends Control

var grid = null
var ninepatch = null

var is_open = false

func _ready():
	grid = $InvNinePatchRect/GridContainer
	ninepatch = $InvNinePatchRect
	
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

	var width = 48
	var cpt = 0
	var base_height = 48
	var height = 0


	# Add all items
	for item in inventory.get_items():		
		var new_item = TextureRect.new()
		new_item.texture = item.icon_sprite
		grid.add_child(new_item)

		cpt += 1
		if cpt <= 5:
			width += new_item.texture.get_width()
		
		# If new row increase height
		if cpt > 5:
			height = base_height + floor((cpt - 1) / 5) * new_item.texture.get_height()
		else:
			height = base_height

	ninepatch.size.x = width
	ninepatch.size.y = height
		
		

func _on_inventory_button_toggled(toggled_on):
	toggle_is_open()

