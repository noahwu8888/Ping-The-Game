extends Button

@onready var button_texture = $DiscordLogo

var ping_sfx = preload("res://Sounds/discord_ping_sound_effect.mp3")

@onready var discordo_sfx: AudioStreamPlayer = $DiscordDiscordo
@onready var leave_sfx: AudioStreamPlayer = $DiscordLeave


var discordo_count = 0
var reset_timer = null
var is_discordo = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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

func _on_button_up() -> void:
	button_texture.position.y -= 2
