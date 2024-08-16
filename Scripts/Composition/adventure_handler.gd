extends Node
class_name AdventureHandler

var rooms: Array[Array] = []
var is_exploring: bool = false
var total_execution_time: int = 0


var party: Array = []
var party_copy: Array = []
var copy_party_stats: Array = []

var enemies: Array = []

var combat_log_queue: Array = []
var combat_log: Array = []

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
	temp_enemy.attack = 6
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
	combat_log_queue = []
	combat_log = []

func adventure(dungeon: Building):
	attached_dungeon = dungeon
	_init_variables()
	_set_party_unselectable()
	_start_exploration()

func _start_exploration():
	party_copy = _duplicate_party()

	for room in rooms:
		if is_exploring:
			_explore_room(room)
		else:
			break
	_end_adventure()

func _explore_room(room: Array):
	enemies = _duplicate_enemies(room)

	var log_string = "Room " + str(room_cpt) + ": ["
	var separator = ""
	for enemy in enemies:
		log_string += separator + enemy.name 
		separator = ", "

	log_string += "]"

	combat_log_queue.append({"type": "announcement", "text": log_string, "ressource_snapshot": _make_ressource_snapshot()})
	room_cpt += 1
	
	while party_copy.size() > 0 and enemies.size() > 0:
		var turn_order = _determine_turn_order()
		for entity in turn_order:
			if party_copy.size() == 0 or enemies.size() == 0:
				break
			_execute_turn(entity)
	if party_copy.size() == 0:
		is_exploring = false

func _duplicate_party() -> Array:
	var new_party = []
	copy_party_stats = []
	for member in party:
		var copy = _clone_stats(member.stats, false)
		new_party.append(copy)
		copy_party_stats.append(copy)
	return new_party

func _duplicate_enemies(room: Array) -> Array:
	var new_enemies = []
	var new_enemies_names = []

	for enemy in room:
		var new_enemy = _clone_stats(enemy, false, enemy.name + "#" + str(new_enemies_names.count(enemy.name) + 1))
		new_enemies.append(new_enemy)
		new_enemies_names.append(enemy.name)
	return new_enemies

func _determine_turn_order() -> Array:
	var all_entities = party_copy + enemies
	all_entities.sort_custom(Callable(self, "_compare_speed"))
	return all_entities

func _compare_speed(a, b):
	return a.speed - b.speed

func _execute_turn(entity):
	if entity in party_copy:
		var skill_idx = randi() % entity.skills.size()
		var skill = entity.skills[skill_idx]
		_apply_skill(entity, skill, party_copy, enemies)
	else:
		var skill_idx = randi() % entity.skills.size()
		var skill = entity.skills[skill_idx]
		_apply_skill(entity, skill, enemies, party_copy)

func _apply_skill(user, skill, skill_allies: Array, skill_enemies: Array):
	var skill_effect = skill.effect.new()

	var target = skill_effect.get_target(skill_allies,skill_enemies)
	var execution_time = randi() % int(skill.action_max_time - skill.action_min_time) + int(skill.action_min_time)
	var combat_log_string = skill_effect.cast(user, target)
	var linked_message = _check_for_death()

	var log_line = "[color={caster_string_color}]{caster}[/color] uses [u]{skill}[/u] on [color={target_string_color}]{target}[/color], {log_string}."

	var target_string_color = "blue" if target in copy_party_stats else "red"
	var caster_string_color = "blue" if user in copy_party_stats else "red"
	
	log_line = log_line.format(
		{
			"caster": user.name,
			"skill": skill.name,
			"target": target.name,
			"caster_string_color": caster_string_color,
			"target_string_color": target_string_color,
			"log_string": combat_log_string
		}
	)

	combat_log_queue.append({"type": "combat", "text": log_line, "execution_time": execution_time, "ressource_snapshot": _make_ressource_snapshot(), "linked_message": linked_message})

	total_execution_time += execution_time

	if combat_log.size() == 0:
		_initalize_combat_log()

func _end_adventure():
	if party_copy.size() == 0:
		combat_log_queue.append({"type":"announcement","text":"[color=red]All party members are dead. The adventure is over.[/color]", "ressource_snapshot": _make_ressource_snapshot(),"alignement":"center"})
	else:
		combat_log_queue.append({"type":"announcement","text":"[color=green]All rooms explored. The adventure is a success.[/color]", "ressource_snapshot": _make_ressource_snapshot(),"alignement":"center"})
	is_exploring = false

func _check_for_death():
	var ret = []
	for entity in party_copy:
		if entity.health <= 0:
			party_copy.erase(entity)
			var log_string = "[color=blue]" + entity.name + "[/color] died."
			ret.append({"type": "death", "text": log_string, "ressource_snapshot": _make_ressource_snapshot()})


	for entity in enemies:
		if entity.health <= 0:
			enemies.erase(entity)
			var log_string = "[color=red]" + entity.name + "[/color] died."
			ret.append({"type": "death", "text": log_string, "ressource_snapshot": _make_ressource_snapshot()})

	return ret


func _set_party_unselectable():
	for member in party:
		member.set_unselectable()

func _set_party_selectable():
	for member in party:
		member.set_selectable()

func _clone_stats(stats: Stats,is_enemy: bool, new_name: String = "") -> Stats:
	var new_stats = stats.duplicate()

	if new_name != "":
		new_stats.name = new_name

	return new_stats

func _initalize_combat_log():
	var log_line = combat_log_queue[0]
	combat_log_queue.remove_at(0)
	combat_log.append(log_line)
	
	if combat_log_queue.size() > 0:
		var combat_log_timer = Timer.new()
		combat_log_timer.one_shot = true
		combat_log_timer.wait_time = 1
		combat_log_timer.timeout.connect(attached_dungeon._process_combat_log_queue.bind(combat_log_timer))
		attached_dungeon.add_child(combat_log_timer)
		combat_log_timer.start()

func _make_ressource_snapshot():
	var ressource_snapshot = {}
	for entity in copy_party_stats:
		ressource_snapshot[entity.name + str(entity.get_reference_count())] = {"name": entity.name, "health": entity.health, "max_health": entity.max_health, "energy": entity.energy, "max_energy": entity.max_energy, "mana": entity.mana, "max_mana": entity.max_mana, "is_player": true}
	for entity in enemies:
		ressource_snapshot[entity.name + str(entity.get_reference_count())] = {"name": entity.name, "health": entity.health, "max_health": entity.max_health, "energy": entity.energy, "max_energy": entity.max_energy, "mana": entity.mana, "max_mana": entity.max_mana, "is_player": false}
	return ressource_snapshot
