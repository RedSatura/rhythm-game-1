extends Node2D

func _ready():
	make_songs_folder()
	SongEventBus.auto_mode = false

func _on_ShowFileDialog_pressed():
	$CanvasLayer/FileDialog.popup()

func _on_FileDialog_file_selected(path):
	SongEventBus.song_path = path
	get_tree().change_scene("res://scenes/song_play_area.tscn")

func _on_AutoModeButton_pressed():
	SongEventBus.auto_mode = $CanvasLayer/AutoModeButton.pressed

func make_songs_folder():
	var dir = Directory.new()
	if !dir.dir_exists("user://songs"):
		dir.open("user://")
		dir.make_dir("songs")

