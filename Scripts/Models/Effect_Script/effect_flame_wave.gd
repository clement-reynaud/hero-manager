extends Effect

static func can_cast(caster:Stats, allies: Array, enemies: Array ,skill:Skill) -> bool:
	if caster.mana >= skill.mana_cost:
		return true
	else:
		return false

static func get_target(caster:Stats, allies: Array, enemies: Array):
	var instance_allies = allies.duplicate()
	var instance_enemies = enemies.duplicate()
	handleTargetingStatus(caster, instance_allies, instance_enemies)

	var alive_enemies = instance_enemies.filter(Global_Functions._is_entity_alive)
	return alive_enemies

static func cast(caster:Stats,target:Array, skill:Skill) -> String:
	handlePreSkillStatus(caster, target, skill)

	var critical = 1
	var variance = randf_range(0.9,1.1)

	if(randi() % 100 <= caster._current_luck):
		critical = 2

	var ratio = 0.7

	var base_damage = calc_damage(caster._current_magic,ratio,variance,critical)
	
	if base_damage < 0:
		base_damage = 0

	caster.mana = max(caster.mana - skill.mana_cost,0)

	var display_damage = []
	for t in target:
		var damage = floor(base_damage - calc_resist(t._current_resistance))
		
		if damage < 0:
			damage = 0
		
		t.health = max(t.health - damage,0)
		display_damage.append(damage)

	handlePostSkillStatus(caster, target, skill)

	var combat_log_string = "[color={color}]{damage}[/color] damage dealt"
	combat_log_string = combat_log_string.format({
		"color": Global_Variables.StatsTypeColor[Global_Variables.StatsType.Magic], 
		"damage": display_damage
	})
	combat_log_string += " [b][Critical][/b]" if critical == 2 else ""

	return combat_log_string
