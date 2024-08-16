class_name Stats

@export var name: String

@export var max_health: int
@export var health: int
@export var max_energy: int
@export var energy: int
@export var max_mana: int
@export var mana: int
@export var attack: int
@export var defense: int
@export var magic: int
@export var resistance: int
@export var speed: int
@export var luck: int

@export var skills: Array[Skill]

func get_stats_dict() -> Dictionary:
	return {
		"max_health": max_health,
		"health": health,
		"max_energy": max_energy,
		"energy": energy,
		"max_mana": max_mana,
		"mana": mana,
		"attack": attack,
		"defense": defense,
		"magic": magic,
		"resistance": resistance,
		"speed": speed,
		"luck": luck
	}

func get_icon(stat_name) -> Texture2D:
	var texture = load("res://Ressources/Sprite/UI/Stats/" + stat_name + ".png")
	if texture == null:
		return load("res://Ressources/Sprite/UI/Stats/default.png")
	else:
		return texture

