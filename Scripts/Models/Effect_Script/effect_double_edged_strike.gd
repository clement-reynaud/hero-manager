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
	return alive_enemies[randi() % alive_enemies.size()]

static func cast(caster:Stats,target:Stats, skill:Skill) -> String:
	handlePreSkillStatus(caster, target, skill)

	var coin_toss = randi() % 100
	coin_toss -= ceil(caster._current_luck / 2)

	caster.mana = max(caster.mana - skill.mana_cost,0)

	var damage = caster._current_attack
	var combat_log = ""

	handlePreSkillStatus(caster, target, skill)

	if coin_toss < 50:
		damage = ceil(damage * 2)
		target.health = max(target.health - damage,0)

		combat_log = " [color={color}]{damage}[/color] damage dealt"

	else:
		caster.health = max(caster.health - ceil(damage),0)

		combat_log = " but inflicted [color={color}]{damage}[/color] damage to self"

	return combat_log.format({"color": Global_Variables.StatsTypeColor[Global_Variables.StatsType.True], "damage": damage})