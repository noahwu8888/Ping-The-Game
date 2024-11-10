class_name Async_Shockwave
extends Node2D

@export var beat_length = 0.839
@export var spawn_position = Vector2(0,0)
@export var despawn_time = 1.5
@export var warning_beats = 4
@export var expand_speed = 10
@export var expand_init_scale = 1
@export var expand_final_scale = 1.5
@export var total_scale = 1.0

var beats = 0
var active = false
var time_elapsed = 0

@onready var shockwave = $Shockwave
@onready var despawn_timer = $DespawnTimer
@onready var anim_player = $AnimationPlayer
@onready var warning_sprite = $WarningSprite
@onready var collision_shape = $Shockwave/CollisionShape2D
@onready var warning_timer = $WarningTimer

func initialize(song_beat_length: float, spawn_pos: Vector2, this_scale: Vector2, this_expand_speed: float, this_init_scale: float, this_final_scale: float, despawn_time_set: float, warning_beat: float):
	beat_length = song_beat_length
	spawn_position = spawn_pos
	despawn_time = despawn_time_set
	warning_beats = warning_beat
	expand_init_scale = this_init_scale
	expand_speed = this_expand_speed
	expand_final_scale = this_final_scale
	total_scale = this_scale

func _ready() -> void:
	position = spawn_position
	despawn_timer.wait_time = despawn_time
	despawn_timer.connect("timeout", _on_despawn_timer_timeout)
	beats = warning_beats
	
	# Set initial scale of the collision shape for the shockwave
	collision_shape.scale = Vector2(expand_init_scale, expand_init_scale) * scale
	collision_shape.disabled = true  # Start as disabled until active
	
	anim_player.speed_scale = beat_length / warning_beats
	anim_player.play("warning")
	
	scale = total_scale
	if(warning_beats == 0):
		active = true
		warning_sprite.visible = false  # Hide the warning when activating
		shockwave.visible = true
		collision_shape.visible = true  # Show shockwave for visual effect
		collision_shape.disabled = false  # Enable collision
		despawn_timer.start()
	
	warning_timer.wait_time = warning_beats * beat_length
	warning_timer.start()

func _physics_process(delta: float) -> void:
	if active:
		# Increment time to control the scaling speed
		time_elapsed += delta * expand_speed
		
		# Calculate the current scale based on time_elapsed, clamping to final scale
		var current_scale = lerp(expand_init_scale, expand_final_scale, time_elapsed)
		current_scale = clamp(current_scale, expand_init_scale, expand_final_scale)
		
		# Apply the new scale to the collision shape (this drives the collision area)
		collision_shape.scale = Vector2(current_scale, current_scale) * total_scale
		
		# Optionally, synchronize the visual shockwave with the collision shape
		# shockwave.scale = collision_shape.scale

func _on_despawn_timer_timeout() -> void:
	anim_player.play("despawn")
	queue_free()


func _on_warning_timer_timeout() -> void:
	warning_sprite.visible = false  # Hide the warning when activating
	active = true
	shockwave.visible = true
	collision_shape.visible = true  # Show shockwave for visual effect
	collision_shape.disabled = false  # Enable collision
	despawn_timer.start()
