class_name Effect

static func calc_damage(damaging_stat:int,ratio:float,variance:float,critical:int) -> float:
	return ((damaging_stat * ratio * variance * Global_Variables.balance_damage_dealt_multiplier) * critical)

static func calc_resist(resist_stat:int) -> float:
	return (resist_stat * Global_Variables.balance_damage_reduction_multiplier)

static func base_damage_formula(damaging_stat:int,ratio:float,variance:float,critical:int,resist_stat:int) -> float:
	return  calc_damage(damaging_stat,ratio,variance,critical) - calc_resist(resist_stat)

static func can_cast(caster:Stats, skill:Skill) -> bool:
	push_error("Effect.can_cast() should be overridden")
	return false

static func get_target(caster:Stats, allies: Array, enemies: Array):
	push_error("Effect.get_target() should be overridden")
	return null

static func cast(caster:Stats,target, skill:Skill) -> String:
	push_error("Effect.cast() should be overridden")
	return ""

static func handleTargetingStatus(caster:Stats, allies: Array, enemies: Array):
	caster.apply_targeting_status(allies, enemies)
	return true

static func handlePreSkillStatus(caster:Stats, target, skill:Skill):
	caster.apply_pre_skill_cast_status(caster, target, skill)
	if typeof(target) == TYPE_ARRAY:
		for t in target:
			t.apply_pre_skill_target_status(caster, target, skill)
	return true

static func handlePostSkillStatus(caster:Stats, target, skill:Skill):
	caster.apply_post_skill_cast_status(caster, target, skill)
	if typeof(target) == TYPE_ARRAY:
		for t in target:
			t.apply_post_skill_target_status(caster, target, skill)
	return true

static func handleLogManipulationStatus(log_string:String, caster:Stats, target, skill:Skill):
	var combat_log_string = caster.apply_log_manipulation_status(log_string, caster, target, skill)

	if combat_log_string == null:
		combat_log_string = log_string
		
	return combat_log_string
