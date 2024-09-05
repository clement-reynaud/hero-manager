
extends Stats
class_name EnemyStats

@export var description: String
@export var sprite: Texture2D

@export var knowledge_reward: int
@export var loot_table: Array[Loot]

func process_loot() -> Array[Item]:
	var loots: Array[Item] = []

	for loot in loot_table:
		if randf_range(0, 1) * 100 < loot.chance:
			for i in randi_range(loot.min_amount, loot.max_amount):
				loots.append(loot.item)

	return loots
	

# func duplicate() -> EnemyStats:
# 	var new_stat = EnemyStats.new()

# 	new_stat.description = description
# 	new_stat.sprite = sprite

# 	new_stat.name = name
# 	new_stat.max_health = max_health
# 	new_stat.health = health
# 	new_stat.max_mana = max_mana
# 	new_stat.mana = mana
# 	new_stat.attack = attack
# 	new_stat.defence = defence
# 	new_stat.magic = magic
# 	new_stat.resistance = resistance
# 	new_stat.speed = speed
# 	new_stat.luck = luck
# 	new_stat.wisdom = wisdom
# 	new_stat.skills = skills

# 	return new_stat
