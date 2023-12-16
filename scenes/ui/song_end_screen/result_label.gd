extends Label

func _ready():
	self.text = "Perfect: " + str(SongEventBus.perfect) + "\nGood: " + str(SongEventBus.good) + "\nMiss: " + str(SongEventBus.miss)
