extends CharacterBody2D
class_name Entity

@export var rank = 1

# Variables
var speed = 300
var target_position = Vector2.ZERO

var _prev_evolution:Array[UnitType] = []
@export var unit_type: UnitType

var timer_progress_bar = null

var selection_handler:SelectionHandler = preload("res://Scripts/Composition/selection_handler.gd").new()
var inventory_handler:InventoryHandler = preload("res://Scripts/Composition/inventory_handler.gd").new()
var stats:PlayerStats = PlayerStats.new()

var overlapping_buildings:Array[Building] = []
var marks:Array[String] = []

var movement_line: Line2D

var skill_to_learn = 0

# Called when the node enters the scene tree for the first time
func _ready():	
	if unit_type == null:
		unit_type = UnitType.new()
		print("Unit type not set for unit " + name)

	timer_progress_bar = $TimerProgressBar
	$TokenBackground.modulate = unit_type.background_color
	$TokenIcon.texture = unit_type.icon_sprite

	selection_handler.nodeToDisplay.append($EntityButtonContainer)
	
	inventory_handler.set_inventory_ui($InventoryUI)

	movement_line = Line2D.new()
	movement_line.name = "MovementLine"
	movement_line.z_index = -1
	add_child(movement_line)

	stats.init(self)
	speed = stats.speed * 60		

# Called every frame
func _process(delta):
	# If the unit is selected, change its color to indicate selection
	selection_handler.handleSelection($TokenBorder)
	selection_handler.handleSelectedNodeDisplay()

	# If the unit has a timer child store it
	var timer = get_node_or_null("TimerProgress")
	if timer and not timer.is_stopped():
		# Set timer visible
		timer_progress_bar.visible = true
		timer_progress_bar.value = (timer.time_left / timer.wait_time) * 100
	else:
		# Set timer invisible
		timer_progress_bar.visible = false

	if not unit_type.is_fighter:
		$EntityButtonContainer/SkillsButton.visible = false

	#Training
	if marks.has("training"):
		$EntityStatsUI/LevelNinePatchRect.visible = true
	else:
		$EntityStatsUI/LevelNinePatchRect.visible = false

	#Evolve
	if possible_evolve != null and possible_evolve_level != 0:
		$EntityStatsUI/EvolveNinePatchRect.visible = true
	else:
		$EntityStatsUI/EvolveNinePatchRect.visible = false

	var filename = "res://Ressources/Sprite/UI/EntityRank/rank_" + str(rank) + ".png"
	if ResourceLoader.exists(filename):
		$EntityRankSprite.texture = load(filename)
	else:
		$EntityRankSprite.texture = null

# Called every physics frame
func _physics_process(delta):
	# Move towards the target position if it's set
	if target_position != Vector2.ZERO:
		move_to_target()

func _draw_movement_line():
	if target_position != Vector2.ZERO:
		if get_node_or_null("MovementLine") == null:
			movement_line = Line2D.new()

		var start_position = 0
		var end_position = to_local(target_position)

		movement_line.points = [start_position, end_position]
		movement_line.default_color = unit_type.background_color
		movement_line.width = 2

func _delete_movement_line():
	movement_line.queue_free()
	movement_line = null

# Function to handle movement towards target position
func move_to_target():
	velocity = (target_position - position).normalized() * speed
	move_and_slide()
	_draw_movement_line()
	
	# If the unit is close enough to the target position, stop moving
	if position.distance_to(target_position) < 5:
		target_position = Vector2.ZERO

	# If coliding with another unit, stop moving
	if get_slide_collision_count() > 0:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("unit") and collider.target_position == Vector2.ZERO:
				if collider.unit_type == unit_type and collider.rank == rank and not unit_type.is_fighter:
					collider.rank_up()
					inventory_handler.merge_to_inventory(collider.inventory_handler)
					delete_self()


func delete_entity(entity:Entity):
	entity.delete_self()

func delete_self():
	queue_free()
	Global_Variables.summoned_entity -= 1

# STATS FUNCTIONS

func rank_up():
	rank += 1
	$EntityLevelUpParticle.emitting = true

func level_up():
	var knowledge_required = stats.level_up_data["function"].call(stats.level)
	
	if stats.knowledge >= knowledge_required:
		var growths = stats.level_up()
		
		if $EntityStatsUI.visible:
			$EntityStatsUI.handle_level_up_blink(growths)
		
		rank_up()
		stats.knowledge -= knowledge_required
		
		#skills level up if number finish by 2, 4, 6, 8 but not 10
		if stats.level % 2 == 0 and stats.level % 10 != 0:
			skill_to_learn += 1
			$"EntityButtonContainer/SkillsButton".notified = true
			
		speed = stats.speed * 60

var possible_evolve = null
var possible_evolve_level = 0

func evolve():
	if possible_evolve != null and possible_evolve_level != 0 and possible_evolve_level >= stats.level:
		_prev_evolution.append(unit_type)
		unit_type = possible_evolve
		possible_evolve = null
		possible_evolve_level = 0
	else: 
		#TODO Better evolved fail message
		print("Can't evolve, level insufficient")
	
# MOVEMENT FUNCTIONS

# Function to set the target position for the unit to move towards
func set_target_position(new_target):
	target_position = new_target

func is_moving():
	return target_position != Vector2.ZERO

# INVENTORY FUNCTIONS
func add_item(item:Item, amount:int = 1):
	inventory_handler.add_item(item, amount)

func transfer_item(item:Item, amount:int, target_inventory_handler:InventoryHandler):
	inventory_handler.transfer_item(item, amount, target_inventory_handler)

func get_items():
	return inventory_handler.get_items()

func is_inventory_full():
	return inventory_handler.is_inventory_full()

# SELECTION FUNCTIONS

# Function to select the unit
func select():
	selection_handler.select()
		
# Function to deselect the unit
func deselect():
	selection_handler.deselect()

func is_selected():
	return selection_handler.is_selected()

func set_selectable():
	selection_handler.selectable = true

func set_unselectable():
	selection_handler.selectable = false

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_released("select"):
		selection_handler.clear_select($"..")
