extends Node2D

func _ready():
	SongEventBus.auto_mode = false

func _on_ShowFileDialog_pressed():
	$CanvasLayer/FileDialog.popup()

func _on_FileDialog_file_selected(path):
	SongEventBus.song_path = path
	get_tree().change_scene("res://scenes/song_play_area.tscn")

func _on_AutoModeButton_pressed():
	SongEventBus.auto_mode = $CanvasLayer/AutoModeButton.pressed
