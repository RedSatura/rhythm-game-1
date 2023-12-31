extends Node2D

export(String, FILE) var song_path = ""

export var auto_mode: bool = false
export var in_editor: bool = false
export var start_immediately = false
export var play_from_quarter_beat = 0

export var song_content_starter = "MagentaSongFormatStart"
export var song_content_ender = "MagentaSongFormatEnd"

export var song_bpm: int = 120
export var song_offset: float = 0


var song_title = ""

var file_content = ""
var song_content = ""
var finished_chart = ""

onready var hitspots = $HitSpots
onready var conductor = $Conductor
onready var lyric_labels = [$CanvasLayer2/LyricsLabel, $CanvasLayer2/LyricsLabel2]
onready var auto_mode_label = $CanvasLayer2/AutoModeLabel
onready var video_player = $CanvasLayer/VideoPlayer
onready var video_timer = $CanvasLayer/VideoPlayer/VideoTimer
onready var song_title_label = $CanvasLayer2/SongTitleLabel
onready var song_start_timer = $SongStartTimer

func _ready():
# warning-ignore:return_value_discarded
	HitSpotEventBus.connect("report_beat", self, "beat_reported")
	if in_editor:
		pass
	else:
		song_path = SongEventBus.song_path
	get_file_content()
	get_song_content()
	process_song_content()
	get_song_info()
	initialize_conductor()
	initialize_video_player()
	
	conductor.bpm = song_bpm
	auto_mode = SongEventBus.auto_mode
	lyric_labels[0].text = ""
	auto_mode_label.visible = auto_mode
	hitspots.set_auto_mode(auto_mode)
	if start_immediately:
		start_song()
	else:
		song_start_timer.start()
		show_song_label_info()
	
func process_song_content():
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	var result = regex.search_all(song_content)
	if result:
		finished_chart = result
	else:
		pass
	
func start_song():
	if conductor.stream:
		if play_from_quarter_beat != 0:
			conductor.stream.loop = false
			conductor.play_from_beat(play_from_quarter_beat, 0)
		else:
			if video_player.stream:
				if song_offset > 0:
					video_timer.start(song_offset)
				else:
					video_player.play()
			conductor.stream.loop = false
			conductor.play_song()
	else:
		pass
	
func beat_reported(beat_number):
	var beat = beat_number - 1
	if finished_chart != null && finished_chart != []:
		if beat < finished_chart.size():
			if finished_chart[beat] != null:
				var beat_content = get_bracket_content(finished_chart[beat].get_string().strip_edges())
				if beat_content:
					var commands = RegEx.new()
					commands.compile("[^+]+")
					var result = commands.search_all(beat_content)
					for x in result:
						process_command(x.get_string().strip_edges())
			else:
				pass
		else:
			pass
	else:
		pass
		
func process_command(command):
	var function_getter = RegEx.new()
	var function = null
	function_getter.compile(".(?=\\/)")
	var result = function_getter.search(command)
	if result:
		function = result.get_string().strip_edges()
	else:
		pass
	if function:
		match function:
			"a": #spawn note
				var lane = get_lane_number(command)
				hitspots.hitspot_spawn_note(lane)
			"b": #change rotation degrees
				var lane = get_lane_number(command)
				var parameters = get_command_parameters(command)
				hitspots.change_hitspot_rotation_degrees(lane, float(parameters[0]), float(parameters[1]))
			"c": #add rotation degrees
				var lane = get_lane_number(command)
				var parameters = get_command_parameters(command)
				hitspots.add_hitspot_rotation_degrees(lane, float(parameters[0]), float(parameters[1]))
			"d": #change note spawn position - Soon!
				pass
			"e": #empty note
				pass
			"l": #lyric
				var parameters = get_command_parameters(command)
				if parameters:
					change_lyrics_label(parameters[0])
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
			parameters.push_back(result.get_string())
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
	if result:
		return result.get_string().strip_edges()
	else:
		pass

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
		
func initialize_video_player():
	var video_regex = RegEx.new()
	video_regex.compile("(?<=VIDEOSRC:).*")
	var result = video_regex.search(file_content)
	#load external file
	var ogv = VideoStreamTheora.new()
	ogv.set_file("user://" + str(result.get_string().strip_edges()))
	video_player.stream = ogv

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
		song_bpm = int(bpm_result.get_string().strip_edges())
	else:
		pass
		
	if offset_result:
		conductor.offset = int(offset_result.get_string().strip_edges())
		song_offset = float(offset_result.get_string().strip_edges()) / 1000.0
	else:
		pass
		
	if audio_result:
		#load external files
		var result = audio_result.get_string().strip_edges()
		var ogg = AudioStreamOGGVorbis.new()
		var file = File.new()
		file.open("user://" + str(result), File.READ)
		ogg.data = file.get_buffer(file.get_len())
		ogg.set_loop(false)
		conductor.stream = ogg
	else:
		pass

func _on_Button_pressed():
	$StartButton.visible = false
	start_song()
	
func change_lyrics_label(lyrics, lyric_number = 0):
	if lyrics:
		match lyric_number:
			0:
				lyric_labels[0].text = str(lyrics)
			1:
				lyric_labels[1].text = str(lyrics)
			_:
				lyric_labels[0].text = str(lyrics)
	else:
		pass

func _on_VideoPlayer_finished():
	video_player.stream = null

func _on_Conductor_finished():
	conductor.stop()
	
func end_song():
	SongEventBus.emit_signal("song_ended")
	
func get_song_info():
	var title_regex = RegEx.new()
	title_regex.compile("(?<=TITLE:).*")
	var title_result = title_regex.search(file_content)
	
	if title_result:
		song_title = str(title_result.get_string().strip_edges())
		SongEventBus.song_title = str(title_result.get_string().strip_edges())

func _on_VideoTimer_timeout():
	video_player.play()

func _on_SongStartTimer_timeout():
	song_title_label.hide()
	start_song()
	
func show_song_label_info():
	song_title_label.show()
	song_title_label.text = song_title
