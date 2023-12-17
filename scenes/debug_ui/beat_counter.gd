extends Label

func _ready():
# warning-ignore:return_value_discarded
	HitSpotEventBus.connect("report_beat", self, "update_label")
	self.text = ""
	
func update_label(beat):
	self.text = "Playing from quarter beat " + str(beat)
