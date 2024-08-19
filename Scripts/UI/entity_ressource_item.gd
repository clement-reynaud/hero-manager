extends VBoxContainer

enum RessourceType {
	HEALTH,
	MANA
}

const player_color = Color.GREEN
const enemy_color = Color.RED

func init_with_entity(entity:Entity):
	_set_entity_name(entity.stats.name)
	_set_bar_max_value_from_stats(entity.stats)
	_set_ressource(RessourceType.HEALTH, entity.stats.health)
	_set_ressource(RessourceType.MANA, entity.stats.mana)

func init_with_dict(entity_stats_dict: Dictionary):
	_set_entity_name(entity_stats_dict["name"])
	_set_bar_color(entity_stats_dict["is_player"])
	
	_set_bar_max_value(RessourceType.HEALTH,entity_stats_dict["max_health"])
	_set_ressource(RessourceType.HEALTH, entity_stats_dict["health"])
	
	_set_bar_max_value(RessourceType.MANA,entity_stats_dict["max_mana"])
	_set_ressource(RessourceType.MANA, entity_stats_dict["mana"])

func _set_bar_max_value_from_stats(stat:Stats):
	$HPBar.max_value = stat.max_health
	$ManaBar.max_value = stat.max_mana

func _set_entity_name(entity_name: String):
	$EntityName.text = entity_name

func _set_bar_max_value(ressource_type: RessourceType, value: int):
	if ressource_type == RessourceType.HEALTH:
		$HPBar.max_value = value
	elif ressource_type == RessourceType.MANA:
		$ManaBar.max_value = value

func _set_ressource(ressource_type: RessourceType, value: int):
	if ressource_type == RessourceType.HEALTH:
		$HPBar.value = value
	elif ressource_type == RessourceType.MANA:
		$ManaBar.value = value

func _set_bar_color(is_player: bool):
	if is_player:
		$HPBar.tint_progress = player_color
	else:
		$HPBar.tint_progress = enemy_color

	#Color with this : #00324d
	$ManaBar.tint_progress = Color("#294999")
