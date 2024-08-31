extends Effect

static func can_cast(caster:Stats, skill:Skill) -> bool:
	return true

static func get_target(caster:Stats, allies: Array, enemies: Array):
	return allies[0]

static func cast(caster:Stats,target, skill:Skill) -> String:
	return " due to the lack of options"
