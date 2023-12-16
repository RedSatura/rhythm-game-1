extends Button

export(String, FILE) var scene = ""

func _on_SceneLinkButton_pressed():
	get_tree().change_scene(scene)
