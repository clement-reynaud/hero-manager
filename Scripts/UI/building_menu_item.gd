extends VBoxContainer

var scene

func _ready():
	pass


func set_item(building:Building_Blueprint):
	var button = $BuildingButton
	button.texture_normal = building.button_texture 
	button.connect("pressed",Callable(self,"prepare_building_placement").bind(building))
	$BuildingLabel.text = building.name 
	scene = building.scene
	set_cost(building.cost)

func prepare_building_placement(building:Building_Blueprint):
	if has_ressources(building):
		var preview = load("res://Scenes/Components/construction_site.tscn").instantiate()
		preview.set_building_blueprint(building)
		
		get_node("../..").visible = false
		get_node("../../..").get_node("GUIBottomRightButtons/OpenBuildMenuButton").button_pressed = false
		
		# Add the preview to the root
		get_tree().get_root().get_node("World").add_child(preview)
	else:
		print("Not enough resources")
		#TODO visual indication of not enough ressources

func has_ressources(building:Building_Blueprint):
	return get_tree().get_root().get_node("World/GUI").has_ressources(building.cost)
	
func set_cost(ressources:Array[MaterialItem]):
	var container = $BuildingCostContainer

	var item_ammount_count = {}

	for item in ressources:
		if item.name in item_ammount_count:
			item_ammount_count[item.name].amount += 1
		else:
			item_ammount_count[item.name] = {}
			item_ammount_count[item.name].item = item
			item_ammount_count[item.name].amount = 1

	for item in item_ammount_count:
		var img = TextureRect.new()
		var label = Label.new()

		img.texture = item_ammount_count[item].item.icon_sprite
		label.text = str(item_ammount_count[item].amount)

		container.add_child(img)
		container.add_child(label)
