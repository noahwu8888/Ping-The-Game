extends Node2D

@export_category("Laser To Instantiate")
@export var laser_prefab: PackedScene

@export_category("Count")
@export var laser_count = 4

@export_category("Speed")
@export var orbit_speed = 1.0
@export var is_clockwise = true

@export_category("Laser Config")
@export var beat_length = 0.839
@export var despawn_time = 2
@export var warning_beats = 4
@export var orbit_offset = Vector2(10,0)
var beats = 0

@export var total_scale = Vector2(1, 1)
@export var extend_speed = 10
@export var extend_length = 100.0

@onready var despawn_timer = $DespawnTimer

var laser_arr = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	despawn_timer.wait_time = despawn_time
	despawn_timer.connect("timeout", _on_despawn_timer_timeout)
	get_tree().root.get_node("main").get_node("RhythmNotifier").connect("beat", _on_beat_heard)

	beats = warning_beats

	# Initialize lasers in a circular pattern
	for i in range(laser_count):
		var laser = laser_prefab.instantiate()
		
		# Calculate the angle and set initial position and rotation
		var angle = i * TAU / laser_count
		laser.rotation = angle + PI / 2  # Face outward
		
		# Initialize laser parameters
		laser.initialize(beat_length,global_position,total_scale,laser.rotation_degrees,despawn_time + 1,warning_beats)
		
		# Add laser to the scene and store its reference and angle for orbiting
		add_child(laser)
		laser_arr.append({"laser": laser, "angle": angle})

func _initialize_orbital_laser(this_laser_count: int = 4,this_orbit_speed: float = 1.0, this_beat_length: float = 0.839, this_despawn_time: float = 2, this_warning_beats: int = 4, this_total_scale: Vector2 = Vector2(1, 1),this_extend_speed: float = 10,this_extend_length: float = 100.0, this_is_clockwise: bool = true) -> void:
	# Set variables based on provided parameters
	laser_count = this_laser_count
	orbit_speed = this_orbit_speed
	is_clockwise = this_is_clockwise
	beat_length = this_beat_length
	despawn_time = this_despawn_time
	warning_beats = this_warning_beats
	total_scale = this_total_scale
	extend_speed = this_extend_speed
	extend_length = this_extend_length

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Orbit lasers around the center
	for laser_data in laser_arr:
		var laser = laser_data["laser"]
		
		# Update the angle based on the orbit direction
		var angle_offset = orbit_speed * delta * (1 if is_clockwise else -1)
		laser_data["angle"] += angle_offset
		
		# Update position to keep laser in orbit
		var new_position = orbit_offset.rotated(laser_data["angle"])  # Radius of 200 for orbit
		laser.global_position = global_position + new_position
		laser.rotation = laser_data["angle"] + PI / 2  # Maintain outward facing direction

func _on_beat_heard(beat: int):
	if beats > 1:
		beats -= 1
	elif despawn_timer.is_stopped():
		despawn_timer.start()

func _on_despawn_timer_timeout():
	queue_free()
