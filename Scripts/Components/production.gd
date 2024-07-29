extends Building

@export var ressource: MaterialItem = null

var timers = {}

var allowed_unit_types: Array[UnitType] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Load resources and append them to the array
	allowed_unit_types.append(preload("res://Data/UnitType/Miner.tres"))

	# Set the sprite based on the resource type   
	$RessourceIcon.texture = ressource.icon_sprite	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($ProductionBorder)

func _on_timer_timeout(unit):
	unit.add_item(ressource, 1)

	#If unit still in contact with mine, restart timer
	if get_overlapping_bodies().has(unit):
		if timers.has(unit.get_instance_id()) and timers[unit.get_instance_id()].is_stopped() and not unit.is_inventory_full():
			timers[unit.get_instance_id()].start()
		else:
			timers[unit.get_instance_id()].queue_free()
			timers.erase(unit.get_instance_id())
	else:
		# Destroy timer node
		timers[unit.get_instance_id()].queue_free()
		timers.erase(unit.get_instance_id())

func _on_body_entered(body):
	if body.is_in_group("unit") and body.unit_type in allowed_unit_types and not timers.has(body.get_instance_id()) and not body.is_inventory_full():
		var new_timer = Timer.new()
		if new_timer:
			new_timer.name = "TimerProgress"
			new_timer.one_shot = true
			new_timer.wait_time = ressource.seconds_to_produce
			new_timer.timeout.connect(_on_timer_timeout.bind(body))
			body.add_child(new_timer)
			new_timer.start()
			timers[body.get_instance_id()] = new_timer


func _on_body_exited(body):
	if body.is_in_group("unit") and timers.has(body.get_instance_id()):
		var unit = timers[body.get_instance_id()].get_parent()
		timers[unit.get_instance_id()].queue_free()
		timers.erase(unit.get_instance_id())
