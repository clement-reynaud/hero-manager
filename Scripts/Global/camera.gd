extends Camera2D

var sensitivity = 1 # Mouse sensitivity.
var last_mouse_position = Vector2.ZERO

# Sensitivity of zooming
var zoom_speed = 0.1
var min_zoom = 0.5  # Adjust as needed
var max_zoom = 2.0  # Adjust as needed

func _process(_delta):
	# Check for mouse input
	if Input.is_action_pressed("camera_move"):
		var current_mouse_position = get_viewport().get_mouse_position()
		var mouse_delta = current_mouse_position - last_mouse_position
		
		mouse_delta *= sensitivity / get_zoom().x
		
		translate(-mouse_delta)
		
		last_mouse_position = current_mouse_position
	else:
		last_mouse_position = get_viewport().get_mouse_position()

func zoom():
	if Input.is_action_just_released('camera_zoom_down'):
		set_zoom(get_zoom() - Vector2(zoom_speed, zoom_speed))
	if Input.is_action_just_released('camera_zoom_up'): #and get_zoom() > Vector2.ONE:
		set_zoom(get_zoom() + Vector2(zoom_speed, zoom_speed))

func _physics_process(delta):
	zoom()
