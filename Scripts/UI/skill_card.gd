extends TextureButton

signal skill_chosen(skill)

func _process(delta):
	$SkillCardDescription.size.x = $SkillCardName.size.x * 5
	# var scaled_text = "[font_size={size}]{text}[/font_size]".format({"size": floor($SkillCardDescription.size.x * 0.055), "text": $SkillCardDescription.text})
	# $SkillCardDescription.text = scaled_text

func set_skill(skill:Skill):
	$SkillCardName.text = skill.name

	var text = Global_Functions.format_skill_description(Stats.new(), skill.description,true)
	$SkillCardDescription.text = text 
	$SkillCardIcon.texture = skill.icon_texture

	connect("pressed", _skill_card_pressed.bind(skill))

func unset_skill():
	disconnect("pressed", _skill_card_pressed)

func _skill_card_pressed(skill:Skill):
	Global_Variables.current_entity.stats.add_available_skill(skill)
	Global_Variables.current_entity.skill_to_learn -= 1
	get_tree().get_root().get_node("World/GUI").close_skill_obtention_window()
	emit_signal("skill_chosen", skill)
