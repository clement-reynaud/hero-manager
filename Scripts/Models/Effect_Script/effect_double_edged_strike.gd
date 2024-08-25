extends Effect

static func can_cast(caster:Stats, skill:Skill) -> bool:
	if caster.mana >= skill.mana_cost:
		return true
	else:
		return false

static func get_target(allies: Array, enemies: Array):
	var alive_enemies = enemies.filter(Global_Functions._is_entity_alive)
	return alive_enemies[randi() % alive_enemies.size()]

static func cast(caster:Stats,target:Stats, skill:Skill) -> String:
	var coin_toss = randi() % 100
	coin_toss -= ceil(caster.luck / 2)

	caster.mana = max(caster.mana - skill.mana_cost,0)

	var damage = caster.attack
	var combat_log = ""

	if coin_toss < 50:
		damage = ceil(damage * 2)
		target.health = max(target.health - damage,0)

		combat_log = " [color={color}]{damage}[/color] damage dealt"

	else:
		caster.health = max(caster.health - ceil(damage),0)

		combat_log = " but inflicted [color={color}]{damage}[/color] damage to self"

	return combat_log.format({"color": Global_Variables.EffectTypeColor[Global_Variables.EffectType.True], "damage": damage})