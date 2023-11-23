extends Node2D

export(String, FILE) var song_path = ""

var song_content_starter = "MagentaSongFormatStart"

var file_content = ""
var song_content = ""

func _ready():
	initialize_file()
	get_song_content()

func initialize_file():
	var file = File.new()
	if file.file_exists(song_path):
		file.open(song_path, File.READ)
		file_content = file.get_as_text()
		file.close()
	else:
		pass

func get_song_content():
	var song_content_position = file_content.find(song_content_starter) + song_content_starter.length()
	print(song_content_position)
