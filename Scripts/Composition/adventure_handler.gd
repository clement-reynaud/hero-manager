extends Node
class_name AdventureHandler

var rooms: Array[Array] = []
var party: Array = []
var combat_log: Array = []
var is_exploring: bool = false
var total_execution_time: int = 0

var attached_dungeon: Building

var room_cpt = 1

func test_rooms():
	var temp_enemy = EnemyStats.new()
	temp_enemy.name = "Slime"
	temp_enemy.description = "Slime"
	#temp_enemy.sprite = load("res://Ressources/Sprites/Enemies/Slime.png")

	temp_enemy.max_health = 10
	temp_enemy.health = 10
	temp_enemy.max_energy = 1
	temp_enemy.energy = 1
	temp_enemy.max_mana = 1
	temp_enemy.mana = 1
	temp_enemy.attack = 1
	temp_enemy.defense = 1
	temp_enemy.magic = 1
	temp_enemy.resistance = 1
	temp_enemy.speed = 1
	temp_enemy.luck = 1

	temp_enemy.skills.append(
		load("res://Data/Skills/basic_attack.tres")
	)

	rooms = [
		[temp_enemy],
		[temp_enemy, temp_enemy]
	]

func _init_variables():
	test_rooms()
	room_cpt = 1
	total_execution_time = 0
	is_exploring = true
	combat_log = []

func adventure(dungeon: Building):
	attached_dungeon = dungeon
	_init_variables()
	_set_party_unselectable()
	_start_exploration()

func _start_exploration():
	for room in rooms:
		if is_exploring:
			_explore_room(room)
		else:
			break
	_end_adventure()

func _explore_room(room: Array):

	var party_copy = _duplicate_party()
	var enemies = _duplicate_enemies(room)

	var log_string = "Room " + str(room_cpt) + ": ["
	var separator = ""
	for enemy in enemies:
		log_string += separator + enemy.name 
		separator = ", "

	log_string += "]"

	combat_log.append(log_string)
	room_cpt += 1
	
	while party_copy.size() > 0 and enemies.size() > 0:
		var turn_order = _determine_turn_order(party_copy, enemies)
		for entity in turn_order:
			if party_copy.size() == 0 or enemies.size() == 0:
				break
			_execute_turn(entity, party_copy, enemies)
	if party_copy.size() == 0:
		is_exploring = false

func _duplicate_party() -> Array:
	var new_party = []
	for member in party:
		new_party.append(_clone_stats(member.stats,false))
	return new_party

func _duplicate_enemies(room: Array) -> Array:
	var new_enemies = []
	for enemy in room:
		new_enemies.append(_clone_stats(enemy,true))
	return new_enemies

func _determine_turn_order(party_copy: Array, enemies: Array) -> Array:
	var all_entities = party_copy + enemies
	all_entities.sort_custom(Callable(self, "_compare_speed"))
	return all_entities

func _compare_speed(a, b):
	return a.speed - b.speed

func _execute_turn(entity, party_copy: Array, enemies: Array):
	if entity in party_copy:
		var skill_idx = randi() % entity.skills.size()
		var skill = entity.skills[skill_idx]
		_apply_skill(entity, skill, party_copy, enemies)
	else:
		var skill_idx = randi() % entity.skills.size()
		var skill = entity.skills[skill_idx]
		_apply_skill(entity, skill, enemies, party_copy)

	_check_for_death(party_copy, enemies)

func _apply_skill(user, skill, allies: Array, enemies: Array):
	var skill_effect = skill.effect.new()

	var target = skill_effect.get_target(allies,enemies)
	var execution_time = randi() % int(skill.action_max_time - skill.action_min_time) + int(skill.action_min_time)
	var combat_log_string = skill_effect.cast(user, target)

	combat_log.append(user.name + " uses " + skill.name + " on " + target.name + ", " + combat_log_string + ".")
	total_execution_time += execution_time

	await attached_dungeon.get_tree().create_timer(execution_time).timeout

func _end_adventure():
	if party.size() == 0:
		print("All party members are dead. The adventure is over.")
	else:
		print("All rooms explored. The adventure is a success.")
	is_exploring = false

func _check_for_death(party_copy: Array, enemies: Array):
	for entity in party_copy:
		if entity.health <= 0:
			party_copy.erase(entity)

	for entity in enemies:
		if entity.health <= 0:
			enemies.erase(entity)


func _set_party_unselectable():
	for member in party:
		member.set_unselectable()

func _set_party_selectable():
	for member in party:
		member.set_selectable()

func _clone_stats(stats: Stats,is_enemy: bool) -> Stats:
	var new_stats = stats.duplicate()
	return new_stats
