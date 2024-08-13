extends Stats
class_name PlayerStats

@export var level: int
@export var experience: int
@export var experience_to_next_level: int

func duplicate() -> PlayerStats:
	var new_stat = PlayerStats.new()

	new_stat.level = level
	new_stat.experience = experience
	new_stat.experience_to_next_level = experience_to_next_level

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
