extends GenericEntityUI

var skill_list_item = preload("res://Scenes/UI/skill_list_item.tscn")
var available_skill_list_item = preload("res://Scenes/UI/availllable_skill_list_item.tscn")
var initialized = false

var currently_selected_skill_slot = null
var available_skills_button = []

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)

	for child in $SkillsNinePatchRect/SkillsList/SkillListVBox.get_children():
		if Input.is_action_pressed("skill_details"):
			child.custom_minimum_size.y = child.get_node("SkillDetailedText").size.y * child.get_node("SkillDetailedText").scale.y
		else:
			child.custom_minimum_size.y = child.get_node("SkillText").size.y * child.get_node("SkillText").scale.y


	$AvailableSkillsNinePatchRect.visible = currently_selected_skill_slot != null

	$LearnSkillButton.visible = attached_entity.skill_to_learn > 0


func initialize(stats:Stats):
	var skill_list = $SkillsNinePatchRect/SkillsList/SkillListVBox
	for child in skill_list.get_children():
		skill_list.remove_child(child)
		child.queue_free()

	for i in stats.wisdom:
		var new_skill_slot = skill_list_item.instantiate()
		skill_list.add_child(new_skill_slot)
		new_skill_slot.get_node("SkillIconBackgroundButton").connect("pressed", _on_skill_button_pressed.bind(new_skill_slot))

func _draw_skills(stats:Stats):
	var skill_list = $SkillsNinePatchRect/SkillsList/SkillListVBox
	#TODO If wisdom has changed, add new skill slot

	if not initialized:
		initialized = true
		initialize(stats)

	for i in stats.skills.size():
		skill_list.get_children()[i].set_skill(stats.skills[i], stats)
		

func _on_skills_button_toggled(toggled_on):
	toggle_is_open()
	if toggled_on:
		_draw_skills(attached_entity.stats)
		_draw_available_skills()
	else:
		currently_selected_skill_slot = null
		for child in $SkillsNinePatchRect/SkillsList/SkillListVBox.get_children():
			child.get_node("SkillIconBackgroundButton").set_pressed(false)

func _on_skill_button_pressed(skill_clicked):	
	for child in $SkillsNinePatchRect/SkillsList/SkillListVBox.get_children():
		if child != skill_clicked:
			child.get_node("SkillIconBackgroundButton").set_pressed(false)

	currently_selected_skill_slot = skill_clicked
	var current_skill = currently_selected_skill_slot.current_skill

	for availlable_skill in available_skills_button:
		# if attached_entity.stats.skills.has(availlable_skill.get_meta("skill")):
		# 	availlable_skill.disabled = true
		#el
		if current_skill != null and availlable_skill.get_meta("skill") == current_skill:
			availlable_skill.disabled = true
		else:
			availlable_skill.disabled = false
			

func _draw_available_skills():
	available_skills_button.clear()
	var stats = attached_entity.stats
	var list_node = $AvailableSkillsNinePatchRect/AvailableSkillsList/AvailableSkillListVBox
	for child in list_node.get_children():
		list_node.remove_child(child)
		child.queue_free()
	
	for available_skill in stats.available_skills:
		var skill_button = available_skill_list_item.instantiate()
		skill_button.get_node("AvailableSkillListItemLabel").text = "[center]" + available_skill.name + "[/center]"
		skill_button.set_meta("skill", available_skill)
		skill_button.connect("pressed", _on_availlable_skills_button_pressed.bind(skill_button))
		list_node.add_child(skill_button)
		available_skills_button.append(skill_button)

func _on_availlable_skills_button_pressed(pressed):
	if not pressed.disabled:
		if attached_entity.stats.skills.has(pressed.get_meta("skill")) and attached_entity.stats.skills.has(currently_selected_skill_slot.current_skill):
			attached_entity.stats.swap_skills(pressed.get_meta("skill"), currently_selected_skill_slot.current_skill)
			
			var old_skill = currently_selected_skill_slot.current_skill
			for child in $SkillsNinePatchRect/SkillsList/SkillListVBox.get_children():
				if child.current_skill == pressed.get_meta("skill"):
					child.set_skill(old_skill, attached_entity.stats)	
			currently_selected_skill_slot.set_skill(pressed.get_meta("skill"), attached_entity.stats)

		else:
			if currently_selected_skill_slot != null and currently_selected_skill_slot.current_skill != null:
				attached_entity.stats.remove_skill(currently_selected_skill_slot.current_skill)

			var new_skill = pressed.get_meta("skill")
			currently_selected_skill_slot.set_skill(new_skill, attached_entity.stats)
			attached_entity.stats.add_skill(new_skill)

		for availlable_skill in available_skills_button:
			availlable_skill.disabled = false

		pressed.disabled = true

func _on_learn_skill_button_pressed():
	var window = get_tree().get_root().get_node("World/GUI").open_skill_obtention_window(attached_entity)
	window.connect("skill_obtained",func (skill:Skill): 
		_draw_skills(attached_entity.stats) 
		_draw_available_skills()

		if attached_entity.skill_to_learn == 0:
			attached_entity.get_node("EntityButtonContainer/SkillsButton").notified = false
	)

