extends Effect

static func can_cast(caster:Stats, allies: Array, enemies: Array ,skill:Skill) -> bool:
	if caster._cooldowns.has("poison_dart") and caster._cooldowns["poison_dart"] > 0:
		return false

	if caster.mana < skill.mana_cost:
		return false

	return true

static func get_target(caster:Stats, allies: Array, enemies: Array):
	var instance_allies = allies.duplicate()
	var instance_enemies = enemies.duplicate()
	handleTargetingStatus(caster, instance_allies, instance_enemies)

	var alive_enemies = instance_enemies.filter(Global_Functions._is_entity_alive)
	return alive_enemies[randi() % alive_enemies.size()]

static func cast(caster:Stats,target:Stats, skill:Skill) -> String:
	var status_poison = load("res://Scripts/Models/Status/status_poison.gd").new()

	handlePreSkillStatus(caster, target, skill)

	var critical = 1
	var variance = randf_range(0.6,1.4)

	if(randi() % 100 <= caster._current_luck):
		critical = 2

	#Inflicts [70%|speed|speed|0.4varia|floor] magic damage and has a [100%|speed|speed|0varia|ceil]% chance to Poison the target
	var speed_ratio = 0.7
	var poison_ratio = 1

	var damage = floor(calc_damage(caster._current_speed, speed_ratio, variance, critical)) - calc_resist(target._current_resistance)

	if damage < 0:
		damage = 0

	target.health = max(target.health - damage,0)

	var poison = false
	if true: #randi() % 100 <= ceil(caster._current_speed * poison_ratio):
		poison = true
		target.set_status(status_poison.get_status_name(), status_poison.get_status_dict(caster, target))


	handlePostSkillStatus(caster, target, skill)

	var combat_log_string = "[color={color}]{damage}[/color] damage dealt"
	combat_log_string = combat_log_string.format({
		"color": caster.get_stat_color('speed'),
		"damage":damage,
	})


	combat_log_string += " and the target is [color=#204f2a]poisoned[/color] " if poison else ""
	combat_log_string += " [b][Critical][/b]" if critical == 2 else ""

	caster._cooldowns["poison_dart"] = skill.cooldown

	return combat_log_string
