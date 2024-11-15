extends Button

@onready var music_player = $"../../MusicPlayer"

@onready var lockout_timer = $BeatLockoutTimer
@onready var late_timer = $LateTimer
@onready var background = $"../TextureRect"

# Define the leeway time within which a click will count as successful
@export var leeway: float = 0.3
@export var beat_length = 0.839

var success_window = false
var success_count = -1
var has_started = false
var current_beat: int = 0

signal start_fight


@onready var button_texture = $DiscordLogo

var ping_sfx = preload("res://Sounds/discord_ping_sound_effect.mp3")

@onready var discordo_sfx: AudioStreamPlayer = $DiscordDiscordo
@onready var leave_sfx: AudioStreamPlayer = $DiscordLeave


var discordo_count = 0
var reset_timer = null
var is_discordo = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lockout_timer.wait_time = beat_length - leeway
	late_timer.wait_time = leeway
	
	var new_color = 1.0 - float(success_count) / 9
	#print(new_color)
	background.self_modulate = Color(new_color,new_color,new_color)
	connect("start_fight", get_tree().root.get_node("main")._start_fight)

func _on_beat_heard(beat: int) -> void:
	success_window = true
	_start_beat_check()
	current_beat = beat
	#print(current_beat)
	if(current_beat >= 2):
		music_player.volume_db = 0

func _start_beat_check():
	lockout_timer.start()
	late_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass


func _on_pressed():
	discordo_count += 1

	# Reset any existing timer
	if reset_timer:
		reset_timer.stop()
	
	if discordo_count >= 15:
		discordo_count = 0
		if not is_discordo:
			discordo_sfx.play()
		else:
			leave_sfx.play()
		is_discordo = !is_discordo
	else:
		if(success_count < 2):
		# Create a new AudioStreamPlayer instance to play the ping sound
			var ping_instance = AudioStreamPlayer.new()
			ping_instance.volume_db = -20
			ping_instance.stream = ping_sfx
			ping_instance.autoplay = true
			add_child(ping_instance)
			# Connect to the finished signal to remove the instance once it finishes playing
			ping_instance.connect("finished", ping_instance.queue_free)

	# Create and start a timer to reset discordo_count after 0.5 seconds if no more presses occur
	reset_timer = Timer.new()
	reset_timer.wait_time = 0.5
	reset_timer.one_shot = true
	reset_timer.timeout.connect(func():
		discordo_count = 0
	)
	add_child(reset_timer)
	reset_timer.start()


func _on_button_down() -> void:
	button_texture.position.y += 2
	
	_check_has_started()

func _on_button_up() -> void:
	button_texture.position.y -= 2


func _check_has_started():
	if(success_count == -1):
		music_player.play()
		success_count += 1
		_start_beat_check()
	elif success_window:
		#check for unwanted presses
		success_count += 1
		success_window = false
		late_timer.stop()
		var new_color = 1.0 - float(success_count) / 9
		if(success_count > 3):
			background.self_modulate = Color(new_color,new_color,new_color)
		if (success_count == 8):
			emit_signal("start_fight")
			self.visible = false
			
	else:
		_fail()

func _fail():
	success_count = -1
	current_beat = 0
	music_player.stop()
	music_player.volume_db = -80
	#print("Fail")
	var new_color = 1.0 - float(success_count) / 9
	#print(new_color)
	background.self_modulate = Color(new_color,new_color,new_color)

func _on_late_timer_timeout() -> void:
	if (success_count != current_beat) and (success_count < 8):
		_fail()
	success_window = false


func _on_lockout_timer_timeout() -> void:
	success_window = true
