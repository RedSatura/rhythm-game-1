extends Node2D

export var input = ""
export var note_speed = 1.5
export var note_spawn_interval = 1.0

var note = load("res://scenes/note/note.tscn")
var instance

var distance_to_target = Vector2.ZERO
var target_pos = Vector2.ZERO
var note_spawn_pos = Vector2.ZERO

var good = false
var perfect = false
var current_note = null

var movement = true

var step = -1

signal add_score(score)
signal note_missed

onready var note_spawn_position = $NoteSpawnPosition
onready var hit_spot_position = $Pivot/HitSpotPosition
onready var pivot = $Pivot
onready var note_spawn_cooldown = $NoteSpawnCooldown
onready var timer = $Timer
onready var tween = $Tween

func _ready():
	timer.wait_time = note_spawn_interval
	
func _physics_process(_delta):
	pass

func spawn_note():
	instance = note.instance()
	instance.global_position = note_spawn_position.global_position
	instance.target_position = hit_spot_position.global_position
	instance.note_spawn_position = note_spawn_position.global_position
	instance.note_speed = note_speed
	add_child(instance)
	movement = false
	note_spawn_cooldown.start(note_speed)

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

func change_rotation_degrees(degrees: float, seconds: float):
	if movement:
		tween.interpolate_property(pivot, "rotation_degrees", pivot.rotation_degrees, degrees, seconds, Tween.TRANS_LINEAR)
		tween.start()
	
func add_rotation_degrees(degrees: float, seconds: float):
	if movement:
		tween.interpolate_property(pivot, "rotation_degrees", pivot.rotation_degrees, pivot.rotation_degrees + degrees, seconds, Tween.TRANS_LINEAR)
		tween.start()

func _on_Timer_timeout():
	spawn_note()
	timer.start()

func _on_NoteSpawnCooldown_timeout():
	movement = true

func _on_MissDetector_area_entered(area):
	emit_signal("note_missed")
	area.destroy_note()
