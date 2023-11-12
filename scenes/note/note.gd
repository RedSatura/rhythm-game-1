extends Area2D

var distance_to_target = Vector2(0.0, 0.0)

var target_position = Vector2(0.0, 0.0)
var note_spawn_position = Vector2(0.0, 0.0)
var speed = Vector2(0.0, 0.0)

var hit = false

func _ready():
# warning-ignore:return_value_discarded
	HitSpotEventBus.connect("get_hit_spot_position", self, "update_hit_spot_position")
# warning-ignore:return_value_discarded
	HitSpotEventBus.connect("get_note_spawn_position", self, "update_note_spawn_position")
	self.global_position = note_spawn_position
	initialize()
	
func _physics_process(delta):
	if !hit:
		self.position.x += speed.x * delta
		self.position.y += speed.y * delta
		#prints(distance_to_target)
		
func initialize():
	distance_to_target = Vector2(target_position.x - note_spawn_position.x, target_position.y - note_spawn_position.y)
	speed.x = distance_to_target.x / 1.5
	speed.y = distance_to_target.y / 1.5
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
func update_hit_spot_position(pos):
	target_position = pos

func update_note_spawn_position(pos):
	note_spawn_position = pos

func update_target_position():
	distance_to_target = Vector2(target_position.x - self.global_position.x, target_position.y - self.global_position.y)
	speed.x = distance_to_target.x
	speed.y = distance_to_target.y
