extends Effect

static func can_cast(caster:Stats, allies: Array, enemies: Array ,skill:Skill) -> bool:
	if caster._cooldowns.has("shield_bash") and caster._cooldowns["shield_bash"] > 0:
		return false

	return true

static func get_target(caster:Stats, allies: Array, enemies: Array):
	var instance_allies = allies.duplicate()
	var instance_enemies = enemies.duplicate()
	handleTargetingStatus(caster, instance_allies, instance_enemies)

	var alive_enemies = instance_enemies.filter(Global_Functions._is_entity_alive)
	return alive_enemies[randi() % alive_enemies.size()]

static func cast(caster:Stats,target:Stats, skill:Skill) -> String:
	var status_stun = load("res://Scripts/Models/Status/status_stunned.gd").new()

	handlePreSkillStatus(caster, target, skill)

	var critical = 1
	var variance = randf_range(0.8,1.2)

	if(randi() % 100 <= caster._current_luck):
		critical = 2

	#Inflicts [10%|attack|attack|0.2varia|floor] + [50%|defence|defence|0.2varia|floor] and has a [2%|defence|defence|0varia|ceil]% chance to Stun the target
	var attack_ratio = 0.1
	var defence_ratio = 0.5
	var stun_ratio = 0.02

	var attack_damage = floor(calc_damage(caster._current_attack, attack_ratio, variance, critical))
	var defence_damage = floor(calc_damage(caster._current_defence, defence_ratio, variance, critical))
	var damage = (attack_damage + defence_damage) - calc_resist(target._current_defence)

	if damage < 0:
		damage = 0

	target.health = max(target.health - damage,0)

	var stun = false
	if true: #randi() % 100 <= ceil(caster._current_defence * stun_ratio):
		stun = true
		target.set_status(status_stun.get_status_name(), status_stun.get_status_dict(caster, target))

	handlePostSkillStatus(caster, target, skill)

	var combat_log_string = "[color={attack_color}]{damage}[/color] ([color={attack_color}]{attack_damage}[/color],[color={defence_color}]{defence_damage}[/color]) damage dealt"
	combat_log_string = combat_log_string.format({
		"attack_color": caster.get_stat_color('attack'),
		"defence_color": caster.get_stat_color('defence'),
		"damage":damage,
		"attack_damage":attack_damage,
		"defence_damage":defence_damage
	})


	combat_log_string += " and the target is [color=#a88732]stunned[/color] " if stun else ""
	combat_log_string += " [b][Critical][/b]" if critical == 2 else ""

	caster._cooldowns["shield_bash"] = skill.cooldown

	return combat_log_string
