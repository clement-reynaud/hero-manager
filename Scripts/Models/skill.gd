class_name Skill
extends Resource

@export_group("Text")
@export var name: String
@export_multiline var description: String

@export_group("Appearance")
@export var icon_texture: Texture2D

@export_group("Effect")
@export var is_passive: bool = false
@export var effect: Script

@export_group("Cost")
#TODO Display cost in skill view
@export var mana_cost: int
@export var custom_ressource_cost: int
@export var cooldown: float
@export var action_min_time: float
@export var action_max_time: float