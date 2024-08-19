class_name Effect

static func can_cast(caster:Stats, skill:Skill) -> bool:
    push_error("Effect.can_cast() should be overridden")
    return false

static func get_target(allies: Array, enemies: Array):
    push_error("Effect.get_target() should be overridden")
    return null

static func cast(caster:Stats,target, skill:Skill) -> String:
    push_error("Effect.cast() should be overridden")
    return ""