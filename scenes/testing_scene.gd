extends Node2D

var perfect = 0
var good = 0

func _ready():
	$HitSpots/HitSpot.connect("add_score", self, "update_score")

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
	$ScoreLabel.text = "Perfect: " + str(perfect) + "\nGood: " + str(good)
