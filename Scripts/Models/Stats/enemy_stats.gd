extends Stats
class_name EnemyStats

@export var description: String
@export var sprite: Texture2D

func duplicate() -> EnemyStats:
	var new_stat = EnemyStats.new()

	new_stat.description = description
	new_stat.sprite = sprite

	new_stat.name = name
	new_stat.max_health = max_health
	new_stat.health = health
	new_stat.max_energy = max_energy
	new_stat.energy = energy
	new_stat.max_mana = max_mana
	new_stat.mana = mana
	new_stat.attack = attack
	new_stat.defense = defense
	new_stat.magic = magic
	new_stat.resistance = resistance
	new_stat.speed = speed
	new_stat.luck = luck
	new_stat.skills = skills

	return new_stat
