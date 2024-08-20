extends Resource
class_name Stats

@export var name: String

@export var max_health: int
@export var health: int
@export var max_mana: int
@export var mana: int
@export var attack: int
@export var defense: int
@export var magic: int
@export var resistance: int
@export var speed: int
@export var luck: int
@export var wisdom: int

@export var _status: Array[String]

@export var skills: Array[Skill]

func get_stats_dict() -> Dictionary:
	return {
		"max_health": max_health,
		"health": health,
		"max_mana": max_mana,
		"mana": mana,
		"attack": attack,
		"defense": defense,
		"magic": magic,
		"resistance": resistance,
		"speed": speed,
		"luck": luck,
		"wisdom": wisdom
	}

func get_stat_color(stat):
	if stat == "max_health" or stat == "health":
		return "red"
	elif stat == "max_mana" or stat == "mana":
		return "blue"
	elif stat == "attack":
		return "#c96800"
	elif stat == "defense":
		return "yellow"
	elif stat == "magic":
		return "#006da6"
	elif stat == "resistance":
		return "lightblue"
	elif stat == "speed":
		return "gold"
	elif stat == "luck":
		return "purple"
	elif stat == "wisdom":
		return "green"
	else:
		return "white"


func get_icon(stat_name) -> Texture2D:
	var texture = load("res://Ressources/Sprite/UI/Stats/" + stat_name + ".png")
	if texture == null:
		return load("res://Ressources/Sprite/UI/Stats/default.png")
	else:
		return texture

func set_status(new_status: String):
	_status.append(new_status)

func remove_status(status_to_remove: String):
	_status.erase(status_to_remove)

func has_status(status_to_check: String) -> bool:
	return _status.has(status_to_check)
