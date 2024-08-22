extends Building

# Called when the node enters the scene tree for the first time.
func _ready():
	ready_selection_handler($AnalyzerButtonContainer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	process_selection_handler($AnalyzerBorder)
	
