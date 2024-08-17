extends Stats
class_name PlayerStats

@export var level: int = 0
@export var experience: int = 0
@export var experience_to_next_level: int = 0

@export var health_growth: int = 50
@export var energy_growth: int = 50
@export var mana_growth: int = 50
@export var attack_growth: int = 50
@export var defense_growth: int = 50
@export var magic_growth: int = 50
@export var resistance_growth: int = 50
@export var speed_growth: int = 50
@export var luck_growth: int = 50

func duplicate() -> PlayerStats:
	var new_stat = PlayerStats.new()

	new_stat.level = level
	new_stat.experience = experience
	new_stat.experience_to_next_level = experience_to_next_level

	new_stat.health_growth = health_growth
	new_stat.energy_growth = energy_growth
	new_stat.mana_growth = mana_growth
	new_stat.attack_growth = attack_growth
	new_stat.defense_growth = defense_growth
	new_stat.magic_growth = magic_growth
	new_stat.resistance_growth = resistance_growth
	new_stat.speed_growth = speed_growth
	new_stat.luck_growth = luck_growth

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

func init():
	setup_stats()
	randomize_growth()
	level_up()

func setup_stats():
	name = "Adventurer"
	max_health = 10
	health = 10
	max_energy = 5
	energy = 5
	max_mana = 5
	mana = 5
	attack = 5
	defense = 5
	magic = 5
	resistance = 5
	speed = 5
	luck = 5

	skills = [
		load("res://Data/Skills/basic_attack.tres"),
		load("res://Data/Skills/magic_missile.tres")
	]

func randomize_growth():
	while true:
		health_growth = randi() % 18 * 5 + 10
		energy_growth = randi() % 18 * 5 + 10
		mana_growth = randi() % 18 * 5 + 10
		attack_growth = randi() % 18 * 5 + 10
		defense_growth = randi() % 18 * 5 + 10
		magic_growth = randi() % 18 * 5 + 10
		resistance_growth = randi() % 18 * 5 + 10
		speed_growth = randi() % 18 * 5 + 10
		luck_growth = randi() % 18 * 5 + 10

		var total = health_growth + energy_growth + mana_growth + attack_growth + defense_growth + magic_growth + resistance_growth + speed_growth + luck_growth

		if total == 450:
			break

func level_up():
	level += 1
	experience = 0
	experience_to_next_level = level * 100

	max_health += 1 if randi() % 100 <= health_growth else 0
	max_energy += 1 if randi() % 100 <= energy_growth else 0
	max_mana += 1 if randi() % 100 <= mana_growth else 0

	attack += 1 if randi() % 100 <= attack_growth else 0
	defense += 1 if randi() % 100 <= defense_growth else 0
	magic += 1 if randi() % 100 <= magic_growth else 0
	resistance += 1 if randi() % 100 <= resistance_growth else 0
	speed += 1 if randi() % 100 <= speed_growth else 0
	luck += 1 if randi() % 100 <= luck_growth else 0
