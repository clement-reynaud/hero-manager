extends Building

@export var summonableUnits: Array[UnitType] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($AltarButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($AltarBorder)

func add_entity_to_field(offset = false):
	if offset:
		print("should move entity farther away")
		#TODO should move entity farther away
	else:
		var unit_type = summonableUnits[randi() % summonableUnits.size()]
		var unit = load("res://Scenes/Components/entity.tscn").instantiate()
		print("Summoning " + unit_type.name)
		unit.unit_type = unit_type
		unit.position = self.position
		$"..".add_child(unit)
		Global.summoned_entity += 1

func summon():
	if summonableUnits.size() > 0:
		if Global.summoned_entity < Global.max_summoned_entity:
			if get_overlapping_bodies().size() == 0:
				add_entity_to_field()
			else:
				add_entity_to_field(true)
		else:
			print("max entity reached")
			#TODO add visual feedback when reaching max entity
