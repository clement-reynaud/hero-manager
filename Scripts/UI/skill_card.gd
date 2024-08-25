extends Control

signal skill_chosen(skill)

func set_skill(skill:Skill):
	$SkillCardButton/SkillCardName.text = skill.name
	$SkillCardButton/SkillCardDescription.text = Global_Functions.format_skill_description(Stats.new(), skill.description,true)
	$SkillCardButton/SkillCardIcon.texture = skill.icon_texture

	$SkillCardButton.connect("pressed", _pressed.bind(skill))

func unset_skill():
	$SkillCardButton.disconnect("pressed", _pressed)

func _pressed(skill:Skill):
	Global_Variables.current_entity.stats.add_available_skill(skill)
	Global_Variables.current_entity.skill_to_learn -= 1
	get_tree().get_root().get_node("World/GUI").close_skill_obtention_window()
	emit_signal("skill_chosen", skill)
