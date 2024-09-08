extends Effect

static func can_cast(caster:Stats, allies: Array, enemies: Array ,skill:Skill) -> bool:
	return true

static func get_target(caster:Stats, allies: Array, enemies: Array):
	return allies[0]

static func cast(caster:Stats,target, skill:Skill) -> String:
	var combat_log_string = " due to the lack of options" 
	return combat_log_string
