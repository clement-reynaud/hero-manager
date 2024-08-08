extends TileMap

var moisture = FastNoiseLite.new()
var temperature = FastNoiseLite.new()
var altitude = FastNoiseLite.new()

var width = 64
var height = 64

@onready var camera = $"../Camera2D"

# Called when the node enters the scene tree for the first time.
func _ready():
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	
	generate_chunk(camera.position - Vector2(width / 2, height / 2))

func generate_chunk(pos):
	var tile_pos = local_to_map(pos)
	for x in range(width):
		for y in range(height):
			var moist = moisture.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var temp = temperature.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			var alt = altitude.get_noise_2d(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y)*10
			
			# if alt < 2:
			# 	set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(3, round((temp+10)/5)))
			# else:
			set_cell(0, Vector2i(tile_pos.x-width/2 + x, tile_pos.y-height/2 + y), 0, Vector2(round((moist+10)/5), round((temp+10)/5)))
