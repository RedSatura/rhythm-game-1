extends Node2D

var perfect = 0
var good = 0
var miss = 0

func _ready():
# warning-ignore:return_value_discarded
	HitSpotEventBus.connect("update_score", self, "update_score")
# warning-ignore:return_value_discarded
	HitSpotEventBus.connect("note_missed", self, "note_missed")

func update_score(score):
	if score == "PERFECT":
		perfect += 1
		update_label()
	elif score == "GOOD":
		good += 1
		update_label()
	else:
		pass

func update_label():
	$CanvasLayer/ScoreLabel.text = "Perfect: " + str(perfect) + "\nGood: " + str(good) + "\nMiss: " + str(miss)

func note_missed():
	miss += 1
	update_label()
