extends Node2D

var perfect = 0
var good = 0
var miss = 0

onready var score_label = $ScoreLabel
onready var note_feedback_label = $NoteFeedbackLabel

func _ready():
# warning-ignore:return_value_discarded
	HitSpotEventBus.connect("update_score", self, "update_score")
# warning-ignore:return_value_discarded
	HitSpotEventBus.connect("note_missed", self, "note_missed")
	SongEventBus.connect("song_ended", self, "end_song")

func update_score(score):
	if score == "PERFECT":
		perfect += 1
		update_label()
		update_note_feedback_label("PERFECT")
	elif score == "GOOD":
		good += 1
		update_label()
		update_note_feedback_label("GOOD")
	else:
		pass

func update_label():
	score_label.text = "Perfect: " + str(perfect) + "\nGood: " + str(good) + "\nMiss: " + str(miss)
	
func update_note_feedback_label(score):
	match score:
		"PERFECT":
			note_feedback_label.visible = true
			note_feedback_label.visibility_timer.start()
			note_feedback_label.text = "PERFECT!"
			note_feedback_label.add_color_override("font_outline_modulate", Color(0, 1, 0, 1))
		"GOOD":
			note_feedback_label.text = "Good!"
			note_feedback_label.visible = true
			note_feedback_label.visibility_timer.start()
			note_feedback_label.add_color_override("font_outline_modulate", Color(1, 1, 0, 1))
		"MISS":
			note_feedback_label.text = "Miss"
			note_feedback_label.visible = true
			note_feedback_label.visibility_timer.start()
			note_feedback_label.add_color_override("font_outline_modulate", Color(1, 0, 0, 1))
		_:
			pass

func note_missed():
	miss += 1
	update_label()
	update_note_feedback_label("MISS")

func end_song():
	SongEventBus.perfect = perfect
	SongEventBus.good = good
	SongEventBus.miss = miss
	get_tree().change_scene("res://scenes/song_end_screen.tscn")
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("back_to_main_menu"):
		get_tree().change_scene("res://scenes/main_menu.tscn")
		
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
