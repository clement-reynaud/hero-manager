extends GenericEntityUI

var skill_list_item = preload("res://Scenes/UI/skill_list_item.tscn")
var initialized = false

func _ready():
	super._ready()

func _process(delta):
	super._process(delta)

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
	_draw_skills(attached_entity.stats)

func _on_skill_button_pressed(skill_clicked):
	#TODO better skill selection
	
	var current_skill = null
	if skill_clicked.current_skill in attached_entity.stats.skills:
		current_skill = skill_clicked.current_skill
		attached_entity.stats.skills.erase(skill_clicked.current_skill)


	var true_available_skills = attached_entity.stats.available_skills.filter(func(skill): return not attached_entity.stats.skills.has(skill) and not skill == current_skill)


	var new_skill = true_available_skills[randi() % true_available_skills.size()]

	attached_entity.stats.skills.append(new_skill)
	skill_clicked.set_skill(new_skill, attached_entity.stats)

