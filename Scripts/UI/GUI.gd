extends CanvasLayer

var tokenCpt

func _ready():
	tokenCpt = get_node("TokenCptText")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tokenCptText = str(Global.summoned_entity,"/",Global.max_summoned_entity)
	$TokenCpt/TokenCptText.text = tokenCptText
