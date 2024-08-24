extends Stats
class_name PlayerStats

@export var level = 1
@export var knowledge: int = 0

@export var health_growth: int = 50
@export var mana_growth: int = 50
@export var attack_growth: int = 50
@export var defense_growth: int = 50
@export var magic_growth: int = 50
@export var resistance_growth: int = 50
@export var speed_growth: int = 50
@export var luck_growth: int = 50

@export var available_skills: Array[Skill]

var attached_entity = null
var level_up_data = null
var growth_total = 0

func init(node: Node):
	setup_stats()
	randomize_growth()
	upgrade_stats(2)
	full_restore()

	if growth_total >= 350 and growth_total <= 399:
		level_up_data = Global_Functions.level_up_function["fast"]

	if growth_total >= 400 and growth_total <= 449:
		level_up_data = Global_Functions.level_up_function["medium"]

	if growth_total >= 450 and growth_total <= 499:
		level_up_data = Global_Functions.level_up_function["medium"]

	if growth_total >= 500 and growth_total <= 549:
		level_up_data = Global_Functions.level_up_function["slow"]

	if growth_total == 550:
		level_up_data = Global_Functions.level_up_function["fast"]

	var true_available_skills = available_skills.filter(func(skill): return not skills.has(skill))
	if skills.size() < wisdom:
		skills.append(true_available_skills[randi() % true_available_skills.size()])

	attached_entity = node

func level_up():
	level += 1
	full_restore()
	return upgrade_stats()

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
		"wisdom": wisdom,
		"knowledge": knowledge
	}

func get_growth_dict() -> Dictionary:
	return {
		"health": health_growth,
		"mana": mana_growth,
		"attack": attack_growth,
		"defense": defense_growth,
		"magic": magic_growth,
		"resistance": resistance_growth,
		"speed": speed_growth,
		"luck": luck_growth
	}

func setup_stats():
	name = "Adventurer " + str(randi() % 100)
	max_health = 10
	health = 10
	max_mana = 5
	mana = 5
	attack = 5
	defense = 5
	magic = 5
	resistance = 5
	speed = 5
	luck = 5
	wisdom = 2

	available_skills = [
		load("res://Data/Skills/basic_attack.tres"),
		load("res://Data/Skills/magic_missile.tres"),
		load("res://Data/Skills/flame_wave.tres"),
		load("res://Data/Skills/heal.tres"),
	]

	skills = [
		load("res://Data/Skills/basic_attack.tres"),
	]

func randomize_growth():
	while true:
		health_growth = randi_range(20,80)
		mana_growth = randi_range(20,80)
		attack_growth = randi_range(20,80)
		defense_growth = randi_range(20,80)
		magic_growth = randi_range(20,80)
		resistance_growth = randi_range(20,80)
		speed_growth = randi_range(20,80)
		luck_growth = randi_range(20,80)

		var total = health_growth + mana_growth + attack_growth + defense_growth + magic_growth + resistance_growth + speed_growth + luck_growth

		if total > 350 and total <= 550:
			growth_total = total
			break

func upgrade_stats(time:int = 1):
	var growths = []

	for i in time:
		if randi() % 100 <= health_growth:
			max_health += 1
			growths.append("health")
			growths.append("max_health")

		if randi() % 100 <= mana_growth:
			max_mana += 1
			growths.append("mana")
			growths.append("max_mana")

		if randi() % 100 <= attack_growth:
			attack += 1
			growths.append("attack")

		if randi() % 100 <= defense_growth:
			defense += 1
			growths.append("defense")

		if randi() % 100 <= magic_growth:
			magic += 1
			growths.append("magic")

		if randi() % 100 <= resistance_growth:
			resistance += 1
			growths.append("resistance")

		if randi() % 100 <= speed_growth:
			speed += 1
			growths.append("speed")

		if randi() % 100 <= luck_growth:
			luck += 1
			growths.append("luck")

	return growths

func full_restore():
	health = max_health
	mana = max_mana

func update_stats(stats:PlayerStats):
	health = stats.health
	mana = stats.mana
