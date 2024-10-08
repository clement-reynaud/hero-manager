extends Resource
class_name Stats

@export var name: String

@export var max_health: int
@export var health: int
@export var max_mana: int
@export var mana: int
@export var attack: int
@export var defence: int
@export var magic: int
@export var resistance: int
@export var speed: int
@export var luck: int
@export var wisdom: int

var _current_attack = 0
var _current_defence = 0
var _current_magic = 0
var _current_resistance = 0
var _current_speed = 0
var _current_luck = 0

var _status: Array[Dictionary]
var _cooldowns = {}

@export var skills: Array[Skill]

func get_stats_dict() -> Dictionary:
	return {
		"max_health": max_health,
		"health": health,
		"max_mana": max_mana,
		"mana": mana,
		"attack": attack,
		"defence": defence,
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
	elif stat == "defence":
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


func add_skill(skill: Skill):
	if not skills.has(skill):
		skills.append(skill)
		
func remove_skill(skill: Skill):
	skills.erase(skill)

func swap_skills(skill1: Skill, skill2: Skill):
	var skill1_index = skills.find(skill1)
	var skill2_index = skills.find(skill2)

	skills[skill1_index] = skill2
	skills[skill2_index] = skill1

# Status
# Others: turn_cpt, apply_cpt

var status_arguments = {
	"targeting": ["allies", "enemies", "combat_log_queue"],
	"pre_skill_cast": ["caster", "target", "skill", "combat_log_queue"],
	"post_skill_cast": ["caster", "target", "skill", "combat_log_queue"],
	"pre_skill_target": ["caster", "target", "skill", "combat_log_queue"],
	"post_skill_target": ["caster", "target", "skill", "combat_log_queue"],
	"caster_log_manipulation": ["entity", "message", "target", "skill", "combat_log_queue"],
	"target_log_manipulation": ["entity", "message", "target", "skill", "combat_log_queue"],
	"turn_order_manipulation": ["entity", "turn_order", "combat_log_queue"],
	"turn_manipulation": ["entity", "can_play", "combat_log_queue"]
}


func init_current_stats():
	_current_attack = attack
	_current_defence = defence
	_current_magic = magic
	_current_resistance = resistance
	_current_speed = speed
	_current_luck = luck

func set_status(new_status: String, details: Dictionary = {}):
	var s = {}
	s.name = new_status
	s.status_id = generate_status_id()
	s.merge(details)
	_status.append(s)
	
	if s.has("apply_skill"):
		s.apply_skill.callv([self])
		
func generate_status_id() -> int:
	return Time.get_ticks_msec() + Time.get_ticks_usec()

func remove_precise_status(status_id_to_remove: int):
	var status = _status.filter(func(s): return s.status_id == status_id_to_remove)
	if status.size() == 1:
		_status.erase(status[0])
		if status[0].has("end_skill"):
			status[0].end_skill.callv([self])

func remove_status(status_to_remove: String):
	var status = _status.filter(func(s): return s.name == status_to_remove)
	if status.size() == 1:
		_status.erase(status[0])
		if status[0].has("end_skill"):
			status[0].end_skill.callv([self])
		

func has_status(status_to_check: String) -> bool:
	var status = _status.filter(func(s): return s.name == status_to_check)
	return status.size() > 0

func count_down_turn_status():
	var turn_status = _status.filter(func(s): return s.has("turn_cpt") and s.turn_cpt > 0)
	for status in turn_status:
		status.turn_cpt -= 1
		if status.turn_cpt == 0:
			remove_precise_status(status.status_id)

func _apply_status(status_name: String, args: Array):
	var statuses_to_run = _status.filter(func(s): return s.has(status_name))
	for status in statuses_to_run:
		status[status_name].callv(args)
		if status.has("apply_cpt") and status.apply_cpt > 0:
			status.apply_cpt -= 1
			if status.apply_cpt == 0:
				remove_precise_status(status.status_id)

func apply_targeting_status(allies: Array, enemies: Array, combat_log_queue = null):
	_apply_status("targeting", [allies, enemies, combat_log_queue])

func apply_pre_skill_cast_status(caster: Stats, target, skill: Skill, combat_log_queue = null):
	_apply_status("pre_skill_cast", [caster, target, skill, combat_log_queue])

func apply_post_skill_cast_status(caster: Stats, target, skill: Skill, combat_log_queue = null):
	_apply_status("post_skill_cast", [caster, target, skill, combat_log_queue])

func apply_pre_skill_target_status(caster: Stats, target, skill: Skill, combat_log_queue = null):
	_apply_status("pre_skill_target", [caster, target, skill, combat_log_queue])

func apply_post_skill_target_status(caster: Stats, target, skill: Skill, combat_log_queue = null):
	_apply_status("post_skill_target", [caster, target, skill, combat_log_queue])

func apply_caster_log_manipulation_status(entity: Stats, message: Dictionary, target: Stats, skill: Skill, combat_log_queue = null):
	_apply_status("caster_log_manipulation", [entity, message, target, skill, combat_log_queue])

func apply_target_log_manipulation_status(entity: Stats, message: Dictionary, target: Stats, skill: Skill, combat_log_queue = null):
	_apply_status("target_log_manipulation", [entity, message, target, skill, combat_log_queue])

func apply_turn_order_manipulation_status(entity: Stats, turn_order: Array, combat_log_queue = null):
	_apply_status("turn_order_manipulation", [entity, turn_order, combat_log_queue])

func apply_turn_manipulation_status(entity: Stats, can_play: Array, combat_log_queue = null):
	_apply_status("turn_manipulation", [entity, can_play, combat_log_queue])
