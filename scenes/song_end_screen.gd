extends Control

export var perfect = 0
export var good = 0
export var miss = 0

onready var title_label = $TitleLabel
onready var auto_mode_notice = $AutoModeNotice

onready var hit_rate_result = $VBoxContainer/HBoxContainer2/HitRateResult
onready var rating_result = $VBoxContainer/HBoxContainer2/RatingResult
onready var grade_result = $VBoxContainer/HBoxContainer2/GradeResult

func _ready():
	auto_mode_notice.set_visible(SongEventBus.auto_mode)
	title_label.text = SongEventBus.song_title
	hit_rate_result.text = "%.2f" % calculate_hit_rate() + "%"
	var rating = calculate_rating()
	rating_result.text = "%.2f" % rating + "%"
	grade_result.text = set_grade(rating)
	
func _physics_process(delta):
	pass

func calculate_hit_rate():
	var total_notes = SongEventBus.perfect + SongEventBus.good + SongEventBus.miss
	var result: float = ((SongEventBus.perfect + SongEventBus.good) / float(total_notes)) * 100 if total_notes != 0 else 0
	return result
	
func calculate_rating():
	var total_notes = SongEventBus.perfect + SongEventBus.good + SongEventBus.miss
	var result: float = (((SongEventBus.perfect * 2) + (SongEventBus.good)) / (float(total_notes) * 2)) * 100 if total_notes != 0 else 0
	return result

func set_grade(rating):
	if rating >= 100:
		return "S+"
	elif rating > 95:
		return "S"
	elif rating > 85:
		return "A"
	elif rating > 70:
		return "B"
	else:
		return "C"
