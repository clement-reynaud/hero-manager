extends Building

@export var summonableUnits: Array[SummonableUnit] = []

var collision_shape = null 

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($AltarButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($AltarBorder)

func add_entity_to_field(offset = false):
	var total_weight = 0
	for unit in summonableUnits:
		total_weight += unit.weight

	var random_value = randi() % total_weight
	var cumulative_weight = 0.0
	var unit_type = null

	for unit in summonableUnits:
		cumulative_weight += unit.weight
		if random_value < cumulative_weight:
			unit_type = unit.unit_type
			break

	var unit = load("res://Scenes/Components/entity.tscn").instantiate()
	unit.unit_type = unit_type

	var extents = $AltarCollisionShape2D.shape.radius
	var x = randf_range(-extents, extents)
	var y = randf_range(-extents, extents)

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
			#TODO visual notification of max entity
