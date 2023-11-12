extends Position2D

func _ready():
	pass

func _physics_process(_delta):
	HitSpotEventBus.emit_signal("get_hit_spot_position", self.global_position)
