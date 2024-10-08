extends Node
class_name AdventureHandler

var rooms: Array[Array] = []
var is_exploring: bool = false

var max_time = 10800
var corruption = false
var total_execution_time: int = 0

var party: Array = []
var party_copy: Array = []
var copy_party_stats: Array = []

var enemies: Array = []

var combat_log_queue: Array = []
var combat_log: Array = []

var attached_dungeon: Building

var room_cpt = 1

var party_wiped: bool = false
var enemies_wiped: bool = false

var loots: Array[Item] = []
var knowledge_reward = 0

var cowardice_skill = load("res://Data/Skills/cowardice.tres")

func _init_variables():
	rooms = []
	is_exploring = true
	corruption = false
	total_execution_time = 0
	party_copy = []
	copy_party_stats = []
	enemies = []
	combat_log_queue = []
	combat_log = []
	room_cpt = 1
	party_wiped = false
	enemies_wiped = false
	loots = []
	knowledge_reward = 0

func adventure(dungeon: Building, dungeon_layout: DungeonLayout):
	attached_dungeon = dungeon
	_init_variables()
	_init_rooms(dungeon_layout)
	_set_party_unselectable()
	_start_exploration()

func _start_exploration():
	party_copy = _duplicate_party()
	_init_current_stats(party_copy)

	for room in rooms:
		if is_exploring:
			_explore_room(room)
		else:
			break
	_end_adventure()

func _explore_room(room: Array):
	enemies_wiped = false
	enemies = _duplicate_enemies(room)
	_init_current_stats(enemies)

	var log_string = "Room " + str(room_cpt) + ": ["
	var separator = ""
	for enemy in enemies:
		log_string += separator + enemy.name 
		separator = ", "

	log_string += "]"

	combat_log_queue.append({"type": "announcement", "text": "-------------", "ressource_snapshot": _make_ressource_snapshot(), "alignement":"center"})
	combat_log_queue.append({"type": "announcement", "text": log_string, "ressource_snapshot": _make_ressource_snapshot(), "alignement":"right"})
	room_cpt += 1
	
	while not party_wiped and not enemies_wiped:
		var turn_order = _determine_turn_order()
		_apply_status("turn_order_manipulation", [turn_order,combat_log_queue], true)
		_count_down_turn_status()
		combat_log_queue.append({"type": "announcement", "text": "-------------", "ressource_snapshot": _make_ressource_snapshot(), "alignement":"center"})
		for entity in turn_order:
			var can_play = [true]
			#THIS IS FUCKED UP BUT I DONT SEE ANOTHER WAY TO DO IT
			_apply_status_to_one(entity, "turn_manipulation", [entity,can_play,combat_log_queue])
			if can_play[0]:
				if party_wiped or enemies_wiped:
					break
				_execute_turn(entity)
				turn_order = _determine_turn_order()
	
				
				if total_execution_time >= max_time:
					if not corruption:
						combat_log_queue.append({"type": "announcement", "text": "[color=purple]Corruption takes hold, all enemies offensive stats are multplied by 10[/color]", "ressource_snapshot": _make_ressource_snapshot(), "alignement":"center"})
						corruption = true
						
					for enemy in enemies:
						enemy._current_attack *= 10
						enemy._current_magic *= 10

				if total_execution_time >= max_time * 2:
					for member in party_copy:
						member.health -= ceil(member.max_health / 4)
						
				_check_for_death()
	if party_wiped:
		is_exploring = false

func _duplicate_party() -> Array:
	var new_party = []
	copy_party_stats = []
	for member in party:
		var copy = _clone_stats(member.stats, false)
		copy.set_meta("original_stats", member.stats)
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
	
	var turn_order = []
	for entity in all_entities:
		if entity.health > 0:
			turn_order.append(entity)

	turn_order.sort_custom(func(a, b): return a._current_speed > b._current_speed)
	
	return turn_order


func _execute_turn(entity:Stats):
	if entity.health > 0:
		var skill = _select_skill(entity)

		for cd in entity._cooldowns:
			if entity._cooldowns[cd] > 0:
				entity._cooldowns[cd] -= 1
				
		if entity in party_copy:
			_apply_skill(entity, skill, party_copy, enemies)
		else: 
			_apply_skill(entity, skill, enemies, party_copy)



func _apply_skill(user, skill, skill_allies: Array, skill_enemies: Array):
	# target can be either an enemy or an ally, in an array or not
	var target = skill.effect.get_target(user,skill_allies,skill_enemies)

	var execution_time = randi_range(skill.action_min_time,skill.action_max_time)

	var combat_log_string = skill.effect.cast(user, target, skill)
	var linked_message = _check_for_death()

	var log_line = "[color={caster_string_color}]{caster}[/color] uses [u]{skill}[/u] on [color={target_string_color}]{target}[/color], {log_string}."

	var target_string_color = "blue" if target in copy_party_stats else "red"
	var caster_string_color = "blue" if user in copy_party_stats else "red"

	var target_name = ""

	if typeof(target) == TYPE_ARRAY:
		var separator = ""
		for t in target:
			var is_last = t == target[target.size() - 1] and target.size() > 1
			target_name += (separator if not is_last else " and ") + t.name
			separator = ", " if not is_last else ""
	else:
		target_name = target.name

	
	log_line = log_line.format(
		{
			"caster": user.name,
			"skill": skill.name,
			"target": target_name,
			"caster_string_color": caster_string_color,
			"target_string_color": target_string_color,
			"log_string": combat_log_string
		}
	)

	var message = {"type": "combat", "text": log_line, "execution_time": execution_time, "ressource_snapshot": _make_ressource_snapshot(), "linked_message": linked_message}
	_apply_status_to_one(user, "caster_log_manipulation", [user, message, target, skill, combat_log_queue])
	
	if typeof(target) == TYPE_ARRAY:
		for t in target:
			_apply_status_to_one(t, "target_log_manipulation", [user, message, t, skill, combat_log_queue])

	combat_log_queue.append(message)

	total_execution_time += execution_time

	if combat_log.size() == 0:
		_initalize_combat_log()

func _select_skill(entity):
	var skill_idx = randi() % entity.skills.size()
	var skill = entity.skills[skill_idx]

	var ignored_skills = []
	while not skill.effect.can_cast(entity,party_copy,enemies,skill):
		ignored_skills.append(skill)
		
		var remaining_skills = entity.skills.filter(func(s): return not s in ignored_skills)

		if remaining_skills.size() == 0:
			skill = cowardice_skill
			break

		skill_idx = randi() % remaining_skills.size()
		skill = remaining_skills[skill_idx]

	return skill

func _end_adventure():
	#TODO Customize msg with loot and knowledge reward
	if party_wiped:
		combat_log_queue.append({"type":"announcement","text":"[color=red]All party members are dead. The adventure is over.[/color]", "ressource_snapshot": _make_ressource_snapshot(),"alignement":"center"})
	else:
		combat_log_queue.append({"type":"announcement","text":"[color=green]All rooms explored. The adventure is a success.[/color]", "ressource_snapshot": _make_ressource_snapshot(),"alignement":"center"})

	is_exploring = false
	_apply_stats_changes()

func _check_for_death():
	var ret = []

	for entity in party_copy:
		if entity.health <= 0 and not entity.has_status("dead"):
			var log_string = "[color=blue]" + entity.name + "[/color] died."
			ret.append({"type": "death", "text": log_string})
			entity.set_status("dead")

	for entity in enemies:
		if entity.health <= 0 and not entity.has_status("dead"):
			var log_string = "[color=red]" + entity.name + "[/color] died."
			ret.append({"type": "death", "text": log_string})
			entity.set_status("dead")

			loots.append_array(entity.process_loot())
			knowledge_reward += entity.knowledge_reward

	if party_copy.filter(Global_Functions._is_entity_dead).size() == party_copy.size():
		party_wiped = true
		return ret

	if enemies.filter(Global_Functions._is_entity_dead).size() == enemies.size():
		enemies_wiped = true
		return ret

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

	for entity in copy_party_stats + enemies:
		ressource_snapshot[entity.name + str(entity.get_reference_count())] = entity.get_stats_dict()
		ressource_snapshot[entity.name + str(entity.get_reference_count())].is_player = entity is PlayerStats
		ressource_snapshot[entity.name + str(entity.get_reference_count())].name = entity.name 
	return ressource_snapshot

func _apply_stats_changes():
	for entity in party_copy:
		entity.get_meta("original_stats").health = entity.health
		entity.get_meta("original_stats").mana = entity.mana
		entity.knowledge += ceil(knowledge_reward / party_copy.size())
		entity.get_meta("original_stats").knowledge = entity.knowledge

	for i in loots.size():
		var item = loots[i]
		party_copy[i % party_copy.size()].get_meta("original_stats").attached_entity.add_item(item,1)

func _count_down_turn_status():
	for entity in party_copy:
		entity.count_down_turn_status()
	for entity in enemies:
		entity.count_down_turn_status()

func _init_current_stats(group):
	for entity in group:
		entity.init_current_stats()

func _init_rooms(layout: DungeonLayout):
	for room:DungeonRoom in layout.rooms:
		rooms.append(room.enemies)

func _apply_status(status_type:String,args:Array, send_entity = false):
	var all_entities = party_copy + enemies
	
	for entity in all_entities:
		var tmp_args = args.duplicate()
		if send_entity:
			tmp_args.insert(0,entity)

		entity.callv("apply_"+status_type+"_status", tmp_args)

func _apply_status_to_one(entity: Stats, status_type:String,args:Array):
	entity.callv("apply_"+status_type+"_status", args)
