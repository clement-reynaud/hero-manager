extends Building

@export var summonableUnits: Array[UnitType] = []

var collision_shape = null 

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($AltarButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($AltarBorder)

func add_entity_to_field(offset = false):
	var unit_type = summonableUnits[randi() % summonableUnits.size()]
	var unit = load("res://Scenes/Components/entity.tscn").instantiate()
	unit.unit_type = unit_type

	var extents = $AltarCollisionShape2D.shape.extents
	var x = randf_range(-extents.x, extents.x)
	var y = randf_range(-extents.y, extents.y)

	unit.position = $AltarCollisionShape2D.global_position + Vector2(x, y)
	unit.rank = 1
	$"..".add_child(unit)
	Global_Variables.summoned_entity += 1

func summon():
	if summonableUnits.size() > 0:
		if Global_Variables.summoned_entity < Global_Variables.max_summoned_entity:
				add_entity_to_field()
		else:
			print("max entity reached")
			Global_Functions.blink_label([get_tree().get_root().get_node("World/GUI").get_node("TokenCpt/TokenCptText")], 1, Color.DARK_RED, Color.BLACK)
