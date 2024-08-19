extends Control

var current_skill

var skill_description:String = ""
var skill_detailed_description:String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("skill_details"):
		$SkillDetailedText.visible = true
		$SkillText.visible = false
	else:
		$SkillDetailedText.visible = false
		$SkillText.visible = true


func set_skill(skill:Skill, stats:Stats):
	var skill_name = skill.name 

	current_skill = skill

	skill_description = Global_Functions.format_skill_description(stats, skill.description)
	skill_detailed_description = Global_Functions.format_skill_description(stats, skill.description, true)

	$SkillText.text = "[b]{name}:[/b]\n{description}".format({"name": skill_name, "description": skill_description})
	$SkillDetailedText.text = "[b]{name}:[/b]\n{description}".format({"name": skill_name, "description": skill_detailed_description})	
	$SkillIconBackgroundButton/SkillIcon.texture = skill.icon_texture
 
