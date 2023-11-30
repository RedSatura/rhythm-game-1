extends Label

onready var visibility_timer = $VisibilityTimer

func _on_VisibilityTimer_timeout():
	self.visible = false
