class_name GenericEntityUI
extends Control

var is_open = false
var attached_entity = null


func _ready():  
	attached_entity = get_parent()

func _process(delta):
	if is_open and attached_entity.is_selected():
		visible = true
	else:
		visible = false

func toggle_is_open():
	is_open = !is_open