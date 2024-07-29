extends Node
class_name SelectionHandler

# Constants
const SELECT_COLOR = Color(0.2, 0.2, 1)  # Green color for selected unit
const DEFAULT_SELECT_COLOR = Color(0, 0, 0)  # Default color for unselected unit

var selected = false
var nodeToDisplay:Array[Node] = []

func handleSelection(borderSprite:Sprite2D):
	if selected:
		borderSprite.modulate = SELECT_COLOR
	else:
		borderSprite.modulate = DEFAULT_SELECT_COLOR


func handleSelectedNodeDisplay():
	for node in nodeToDisplay:
		if selected:
			node.visible = true
		else:
			node.visible = false

func clear_select(world_node):
	# Deselect all units
	world_node.deselect_all()
	selected = true

func select():
	selected = true

func deselect():
	selected = false


func is_selected():
	return selected
