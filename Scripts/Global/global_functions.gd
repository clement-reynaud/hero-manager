extends Node

func blink_label(labels:Array[Label],  duration:float, color:Color, default_color = null) -> void:
	for label in labels:
		print(label)
		if default_color == null:
			label.set("theme_override_colors/font_color",default_color)

		label.set_meta("original_color",label.get("theme_override_colors/font_color")) # Store the original color
		label.set("theme_override_colors/font_color",color)			


	await get_tree().create_timer(duration).timeout

	for label in labels:
		print(label)
		# Create a coroutine to revert the color after a delay
		label.set("theme_override_colors/font_color",label.get_meta("original_color")) # Revert to the original color
