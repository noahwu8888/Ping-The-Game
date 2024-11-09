extends Button

@onready var lockout_timer = $BeatLockoutTimer
@onready var late_timer = $LateTimer

# Define the leeway time within which a click will count as successful
@export var leeway: float = 0.1
@export var beat_length = 0.42

var success_window = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lockout_timer.wait_time = beat_length - leeway
	late_timer.wait_time = leeway

# Method called every time a beat is detected
func _on_beat_heard(beat: int) -> void:
	success_window = true
	lockout_timer.start()
	late_timer.start()


func _on_button_down() -> void:
	if success_window:
		print("Success")
	else:
		print("Fail")

func _on_late_timer_timeout() -> void:
	success_window = false


func _on_lockout_timer_timeout() -> void:
	success_window = true
