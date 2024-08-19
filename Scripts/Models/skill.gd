class_name Skill
extends Resource

@export var name: String
@export var description: String
@export var icon_texture: Texture2D
@export var effect: Script

@export var mana_cost: int
@export var custom_ressource_cost: int

@export var cooldown: float

@export var action_min_time: float
@export var action_max_time: float