extends Node2D

export(String, FILE) var song_path = ""

export var song_content_starter = "MagentaSongFormatStart"
export var song_content_ender = "MagentaSongFormatEnd"

export var song_offset: float = 0

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
	var song_info_extractor = RegEx.new()
	song_info_extractor.compile("(?<=" + str(song_content_starter) + ")((.|\n)*)(?=" + str(song_content_ender) + ")")
	var result = song_info_extractor.search(file_content)
	if result:
		print(result.get_string().strip_edges())
	else:
		pass
