extends Node2D

onready var hitspots = [$HitSpot1, $HitSpot2, $HitSpot3, $HitSpot4]

func change_hitspot_note_speed(hitspot_number: int, new_speed: float):
	if hitspots[hitspot_number] != null:
		hitspots[hitspot_number].note_speed = new_speed
	else:
		pass

func change_hitspot_rotation_degrees(hitspot_number: int, new_degrees: float, seconds: float):
	if hitspots[hitspot_number] != null:
		hitspots[hitspot_number].change_rotation_degrees(new_degrees, seconds)
	else:
		pass
		
func add_hitspot_rotation_degrees(hitspot_number: int, new_degrees: float, seconds: float):
	if hitspots[hitspot_number] != null:
		hitspots[hitspot_number].add_rotation_degrees(new_degrees, seconds)
	else:
		pass

func hitspot_spawn_note(hitspot_number: int):
	if hitspots[hitspot_number] != null:
		hitspots[hitspot_number].spawn_note()
	else:
		pass
		
func change_hitspot_note_spawn_position(hitspot_number: int, new_position: Vector2):
	if hitspots[hitspot_number] != null:
		hitspots[hitspot_number].change_note_spawn_position(new_position)
	else:
		pass

func change_hitspot_note_spawn_interval(hitspot_number: int, new_interval: float):
	pass
