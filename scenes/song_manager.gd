extends Node2D

export(String, FILE) var song_path = ""

export var song_content_starter = "MagentaSongFormatStart"
export var song_content_ender = "MagentaSongFormatEnd"

export var song_offset: float = 0

var file_content = ""
var song_content = ""

onready var conductor = $Conductor

func _ready():
	get_file_content()
	get_song_content()
	initialize_conductor()

func get_file_content():
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
		pass
	else:
		pass

func initialize_conductor():
	var bpm_regex = RegEx.new()
	var offset_regex = RegEx.new()
	var audio_regex = RegEx.new()
	bpm_regex.compile("(?<=BPM:).*")
	offset_regex.compile("(?<=OFFSET:).*")
	audio_regex.compile("(?<=AUDIOSRC:).*")
	var bpm_result = bpm_regex.search(file_content)
	var offset_result = offset_regex.search(file_content)
	var audio_result = audio_regex.search(file_content)
	
	if bpm_result:
		conductor.bpm = int(bpm_result.get_string().strip_edges())
	else:
		pass
		
	if offset_result:
		conductor.offset = int(offset_result.get_string().strip_edges())
	else:
		pass
		
	if audio_result:
		var result = audio_result.get_string().strip_edges()
		var audio = load(result)
		conductor.stream = audio
		conductor.playing = true
	else:
		pass
