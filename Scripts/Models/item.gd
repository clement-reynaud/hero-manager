class_name Item
extends Resource

enum ItemType {WEAPON, ARMOR, CONSUMABLE, MATERIAL}

@export var name: String
@export var description: String
@export var type: ItemType
@export var icon_sprite: Texture2D
