extends AudioStreamPlayer

export var bpm = 100
export var measures = 4
export var offset = 0

var song_position = 0.0
var song_position_in_beats = 1
var seconds_per_quarter_beat = 60.0 / bpm / 4
var last_reported_beat = 0
var beats_before_start = 0  
var measure = 1

var closest = 0
var time_off_beat = 0.0

# warning-ignore:unused_signal
signal beat(position)
# warning-ignore:unused_signal
signal measure(position)

func _ready():
	seconds_per_quarter_beat = 60.0 / bpm / 4

func _process(_delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / seconds_per_quarter_beat)) + beats_before_start
		_report_beat()

func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if measure > measures:
			measure = 1
		emit_signal("beat", song_position_in_beats)
		emit_signal("measure", measure)
		HitSpotEventBus.emit_signal("report_beat", song_position_in_beats)
		last_reported_beat = song_position_in_beats
		measure += 1
		
func closest_beat(nth):
	closest = int(round((song_position / seconds_per_quarter_beat) / nth) * nth) 
	time_off_beat = abs(closest * seconds_per_quarter_beat - song_position)
	return Vector2(closest, time_off_beat)
		
func play_with_beat_offset(num):
	beats_before_start = num
	$StartTimer.wait_time = seconds_per_quarter_beat
	$StartTimer.start()
	
func play_from_beat(beat, offset_num):
	play_song()
	seek(beat * seconds_per_quarter_beat)
	beats_before_start = offset_num
	measure = beat % measures
	
func _on_StartTimer_timeout():
	song_position_in_beats += 1
	if song_position_in_beats < beats_before_start - 1:
		$StartTimer.start()
	elif song_position_in_beats == beats_before_start - 1:
		$StartTimer.wait_time = $StartTimer.wait_time - (AudioServer.get_time_to_next_mix()
		 + AudioServer.get_output_latency())
		$StartTimer.start()
	else:
		play_song()
		$StartTimer.stop()
	_report_beat()
	
func play_song():
	var effect = AudioServer.get_bus_effect(1, 0)
	if effect:
		effect.set_dry(0)
		effect.set_tap1_delay_ms(offset)
		effect.set_tap2_active(false)
	seconds_per_quarter_beat = 60.0 / bpm / 4
	play()
	
func _on_Conductor_finished():
	if get_parent():
		get_parent().end_song()
