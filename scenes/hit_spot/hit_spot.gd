extends Node2D

export var input = ""

var note = load("res://scenes/note/note.tscn")
var instance

var distance_to_target = Vector2.ZERO
var target_pos = Vector2.ZERO
var note_spawn_pos = Vector2.ZERO

var good = false
var perfect = false
var current_note = null

var step = -1

signal add_score(score)

onready var note_spawn_position = $NoteSpawnPosition
onready var hit_spot_position = $Pivot/HitSpotPosition
onready var animation = $AnimationPlayer
onready var pivot = $Pivot
onready var timer = $Timer

func _ready():
	timer.wait_time = 1.5
	animation.play("test_track")
	
func _physics_process(_delta):
	pass

func spawn_note():
	instance = note.instance()
	instance.global_position = note_spawn_position.global_position
	instance.target_position = hit_spot_position.global_position
	instance.note_spawn_position = note_spawn_position.global_position
	add_child(instance)

func _on_GoodArea_area_entered(area):
	good = true
	current_note = area

func _on_PerfectArea_area_entered(_area):
	perfect = true

func _on_PerfectArea_area_exited(_area):
	perfect = false

func _on_GoodArea_area_exited(_area):
	good = false
	current_note = null
	
func _unhandled_input(event):
	if event.is_action_pressed(input, false):
		if current_note != null:
			if perfect:
				current_note.destroy_note()
				emit_signal("add_score", "PERFECT")
			elif good:
				current_note.destroy_note()
				emit_signal("add_score", "GOOD")
			else:
				pass

func _on_Timer_timeout():
	spawn_note()
	timer.start()
