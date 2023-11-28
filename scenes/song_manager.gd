extends Node2D

export(String, FILE) var song_path = ""

export var song_content_starter = "MagentaSongFormatStart"
export var song_content_ender = "MagentaSongFormatEnd"

export var song_offset: float = 0

var file_content = ""
var song_content = ""
var finished_chart = ""

onready var hitspots = $HitSpots
onready var conductor = $Conductor
onready var offset_timer = $OffsetTimer

func _ready():
# warning-ignore:return_value_discarded
	HitSpotEventBus.connect("report_beat", self, "beat_reported")
	get_file_content()
	get_song_content()
	process_song_content()
	initialize_conductor()
	start_song()
	
func process_song_content():
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	var result = regex.search_all(song_content)
	if result:
		finished_chart = result
	else:
		pass
	
func start_song():
	conductor.playing = true
	
func beat_reported(beat_number):
	var beat = beat_number - 1
	if beat < finished_chart.size():
		if finished_chart[beat] != null:
			var result = get_bracket_content(finished_chart[beat].get_string().strip_edges())
			process_command(result)
		else:
			pass
	else:
		pass
		
func process_command(command):
	var function_getter = RegEx.new()
	function_getter.compile(".(?=\\/)")
	var function = function_getter.search(command).get_string().strip_edges()
	if function:
		match function:
			"a": #spawn note
				var lane = get_lane_number(command)
				hitspots.hitspot_spawn_note(lane)
			"b": #change rotation degrees
				var lane = get_lane_number(command)
				var parameters = get_command_parameters(command)
				hitspots.change_hitspot_rotation_degrees(0, 90, 1)
				hitspots.change_hitspot_rotation_degrees(lane, parameters[0], parameters[1])
			"c": #change note speed - Soon!
				pass
			"d": #change note spawn position - Soon!
				pass
			"e": #empty note
				pass
			_:
				pass
	else:
		pass
		
func get_command_parameters(command):
	var regex = RegEx.new()
	regex.compile("(?<=#)(.*?)(?=#)")
	var parameters = []
	for result in regex.search_all(command):
		if result:
			parameters.push_back(float(result.get_string()))
		else:
			return
	return parameters
		
func get_lane_number(command):
	var lane = RegEx.new()
	lane.compile("(?<=\\/)\\d")
	var result = lane.search(command)
	if result:
		return int(result.get_string().strip_edges())
	else:
		pass
	
func get_bracket_content(content):
	var bracket_content = RegEx.new()
	bracket_content.compile("(?<=\\[)(.*?)(?=\\])")
	var result = bracket_content.search(content)
	return result.get_string().strip_edges()

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
		song_content = result.get_string().strip_edges()
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
