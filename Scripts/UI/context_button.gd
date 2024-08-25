extends TextureButton

var notified: bool:
	get:
		return notified
	set(value):
		notified = value
		if notified:
			$NotificationCircle.visible = true
		else:
			$NotificationCircle.visible = false
