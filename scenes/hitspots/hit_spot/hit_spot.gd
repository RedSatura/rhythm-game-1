extends Node2D

export var input = ""
export var note_speed = 1.5
export var note_spawn_interval = 1.0

export var initial_rotation = 0

export var original_color = Color(0, 0, 0, 0)

var auto_mode = false

var note = load("res://scenes/note/note.tscn")
var instance

var distance_to_target = Vector2.ZERO
var target_pos = Vector2.ZERO
var note_spawn_pos = Vector2.ZERO

var good = false
var perfect = false
var missable = true
var current_note = null

var note_spawnable = true
var movement = true

var step = -1

onready var note_spawn_position = $Pivot/NoteSpawnPosition
onready var hit_spot_position = $Pivot/HitSpotPosition
onready var pivot = $Pivot
onready var note_spawn_cooldown = $NoteSpawnCooldown
onready var timer = $NoteSpawnInterval
onready var input_cooldown = $InputCooldown
onready var tween = $Tween
onready var note_hit_sound = $NoteHitSound
onready var note_miss_sound = $NoteMissSound
onready var particles = $Pivot/Particles2D

func _ready():
	pivot.rotation_degrees = initial_rotation
	timer.wait_time = note_spawn_interval
	
func _physics_process(_delta):
	pass

func spawn_note():
	if note_spawnable:
		instance = note.instance()
		instance.global_position = note_spawn_position.global_position
		instance.target_position = hit_spot_position.global_position
		instance.note_spawn_position = note_spawn_position.global_position
		instance.note_speed = note_speed
		add_child(instance)
		movement = false
		note_spawn_cooldown.start(note_speed)

func _on_GoodArea_area_entered(_area):
	good = true
	missable = false
	
func _on_PerfectArea_area_entered(_area):
	perfect = true
	if auto_mode:
		if current_note != null:
			current_note.destroy_note()
			HitSpotEventBus.emit_signal("update_score", "PERFECT")
			note_hit_sound.play()
			emit_particles()
			current_note = null

func _on_PerfectArea_area_exited(_area):
	perfect = false

func _on_GoodArea_area_exited(_area):
	good = false
	missable = true
	
func _unhandled_input(event):
	if !auto_mode:
		if event.is_action_pressed(input, false):
			self.modulate = Color(1, 1, 1, 1)
			input_cooldown.start()
			if current_note != null:
				if perfect:
					current_note.destroy_note()
					HitSpotEventBus.emit_signal("update_score", "PERFECT")
					note_hit_sound.play()
					emit_particles()
					current_note = null
				elif good:
					current_note.destroy_note()
					HitSpotEventBus.emit_signal("update_score", "GOOD")
					note_hit_sound.play()
					emit_particles()
					current_note = null
				elif missable:
					HitSpotEventBus.emit_signal("note_missed")
					current_note.destroy_note()
					note_miss_sound.play()
					current_note = null

func change_rotation_degrees(degrees: float, seconds: float):
	note_spawnable = false
	if movement:
		tween.interpolate_property(pivot, "rotation_degrees", pivot.rotation_degrees, degrees, seconds, Tween.TRANS_LINEAR)
		tween.start()
	else:
		print("Failed!")
	
func add_rotation_degrees(degrees: float, seconds: float):
	note_spawnable = false
	if movement:
		tween.interpolate_property(pivot, "rotation_degrees", pivot.rotation_degrees, pivot.rotation_degrees + degrees, seconds, Tween.TRANS_LINEAR)
		tween.start()

func _on_Timer_timeout():
	spawn_note()
	timer.start()

func _on_NoteSpawnCooldown_timeout():
	movement = true

func _on_MissDetector_area_entered(area):
	current_note = area
	missable = true

func _on_MissDetector_area_exited(_area):
	current_note = null

func _on_MissedNotesManager_area_entered(area):
	area.destroy_note()
	note_miss_sound.play()
	HitSpotEventBus.emit_signal("note_missed")
	
func change_note_spawn_position(new_position: Vector2):
	note_spawn_position.position = new_position

func _on_Tween_tween_all_completed():
	note_spawnable = true

func _on_InputCooldown_timeout():
	self.modulate = original_color
	
func emit_particles():
	particles.restart()
	particles.set_emitting(true)
