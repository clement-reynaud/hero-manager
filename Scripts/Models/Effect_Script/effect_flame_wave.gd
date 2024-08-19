extends Effect

static func can_cast(caster:Stats, skill:Skill) -> bool:
	if caster.mana >= skill.mana_cost:
		return true
	else:
		return false

static func get_target(allies: Array, enemies: Array):
	var alive_enemies = enemies.filter(Global_Functions._is_entity_alive)
	return alive_enemies

static func cast(caster:Stats,target:Array, skill:Skill) -> String:
	var critical = 1
	var variance = randf_range(0.9,1.1)

	if(randi() % 100 <= caster.luck):
		critical = 2

	var base_damage = ((caster.magic/2) * variance * Global_Variables.balance_damage_dealt_multiplier) * critical
	
	if base_damage < 0:
		base_damage = 0

	caster.mana = max(caster.mana - skill.mana_cost,0)

	var display_damage = []
	for t in target:
		var damage = floor(base_damage - (t.resistance * Global_Variables.balance_damage_reduction_multiplier))
		
		if damage < 0:
			damage = 0
		
		t.health = max(t.health - damage,0)
		display_damage.append(damage)

	var combat_log_string = "[color={color}]{damage}[/color] damage dealt"
	combat_log_string = combat_log_string.format({
		"color": Global_Variables.EffectTypeColor[Global_Variables.EffectType.Magic], 
		"damage": display_damage
	})
	combat_log_string += " [b][Critical][/b]" if critical == 2 else ""

	return combat_log_string
