class_name Building_Blueprint
extends Resource

@export var name: String
@export var button_texture: Texture2D
@export var description: String
@export var cost: Array[MaterialItem]
@export var build_time: float

@export var scene: PackedScene