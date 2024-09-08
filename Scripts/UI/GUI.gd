extends CanvasLayer

signal skill_obtained(skill)

var tokenCpt
var inventory_list_container 
var inventory_list_box

func _ready():
	tokenCpt = $TokenCpt/TokenCptText
	inventory_list_container = $InventoryList/InventoryListContainer
	inventory_list_box = $InventoryList/InventoryListContainer/InventoryListBox

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tokenCptText = str(Global_Variables.summoned_entity,"/",Global_Variables.max_summoned_entity)
	$TokenCpt/TokenCptText.text = tokenCptText

# GLOBAL INVENTORY

# {itemName: {item: MaterialItem, amount: int}}
var global_inventory = {}


func update_global_inventory_display():
	if $InventoryList.visible:
		for item in inventory_list_box.get_children():
			inventory_list_box.remove_child(item)
			item.queue_free()

		var keys = global_inventory.keys()
		keys.sort()

		for itemKey in keys:
			var item = global_inventory[itemKey].item
			var amount = global_inventory[itemKey].amount

			var inventory_list_item = load("res://Scenes/UI/inventory_list_item.tscn").instantiate()
			inventory_list_item.set_item(item, amount)

			inventory_list_box.add_child(inventory_list_item)

func add_item_to_global_inventory(item:Item):
	if item.name in global_inventory:
		global_inventory[item.name].amount += 1
	else:
		global_inventory[item.name] = {}
		global_inventory[item.name].item = item 
		global_inventory[item.name].amount = 1
	update_global_inventory_display()

func remove_item_from_global_inventory(item:Item):
	if item.name in global_inventory:
		global_inventory[item.name].amount -= 1
	#if global_inventory[item.name].amount == 0:
	update_global_inventory_display()

func has_ressources(ressources:Array[MaterialItem]):
	var compare_dict = {}
	var has = true

	for item in ressources:
		if item.name in compare_dict:
			compare_dict[item.name].amount += 1
		else:
			compare_dict[item.name] = {}
			compare_dict[item.name].item = item
			compare_dict[item.name].amount = 1

	if global_inventory.size() < compare_dict.size():
		return false

	for item in global_inventory:
		if item in compare_dict:
			if compare_dict[item].amount <= global_inventory[item].amount:
				continue
			else:
				has = false
		else:
			has =  false
	
	return has

# BUILD MENU

#TODO Gestion des technologies
@export var techtree: Array[Building_Blueprint]

func update_build_window_display():
	if $BuildMenu.visible:
		for item in $BuildMenu/BuildMenuGrid.get_children():
			$BuildMenu/BuildMenuGrid.remove_child(item)
			item.queue_free()

		for building in techtree:
			var building_menu_item = load("res://Scenes/UI/building_menu_item.tscn").instantiate()
			building_menu_item.set_item(building)

			$BuildMenu/BuildMenuGrid.add_child(building_menu_item)

# CENTER WINDOW

func _open_center_window():
	$CenterGUIWindow.visible = true

func _close_center_window():
	$CenterGUIWindow.visible = false

# SKILL OBTENTION

func open_skill_obtention_window(entity:Entity):
	_open_center_window()
	Global_Variables.current_entity = entity

	var window = $CenterGUIWindow/SkillObtention
	window.visible = true
	
	var string = "{name} has levelled up to level {level} !\nChoose a skill to learn :"
	string = string.format({"name": entity.stats.name, "level": entity.stats.level})
	window.get_node("SkillObtentionLabel").text = string 

	var shown_skill=[]
	for card in window.get_node("SkillObtentionHBox").get_children():
		var learnable_skills = entity.unit_type.learnable_skills.filter(func(skill:Skill): return not entity.stats.available_skills.has(skill) and not shown_skill.has(skill))
		
		if learnable_skills.size() <= 0:
			card.visible = false
		else:
			var new_skill = learnable_skills[randi() % learnable_skills.size()]
			card.visible = true
			card.connect("skill_chosen", func(skill): emit_signal("skill_obtained", skill))
			shown_skill.append(new_skill)
			card.set_skill(new_skill)
			learnable_skills.remove_at(randi() % learnable_skills.size())

	return self

func close_skill_obtention_window():
	_close_center_window()
	Global_Variables.current_entity = null

	var window = $CenterGUIWindow/SkillObtention
	window.visible = false

	for card in window.get_node("SkillObtentionHBox").get_children():
		card.unset_skill()


# SIGNALS

func _toggle_gui_window(node):
		node.visible = !node.visible

func _on_open_inventory_button_pressed():
	_toggle_gui_window($InventoryList)
	update_global_inventory_display()

func _on_open_build_button_pressed():
	_toggle_gui_window($BuildMenu)
	update_build_window_display()
