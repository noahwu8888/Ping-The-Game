class_name Laser extends RigidBody2D

@export var beat_length = 0.839

@export var spawn_position = Vector2(0,0)
@export var initial_rotation = 0.0
@export var despawn_time = 1.5
##how many beats before it expands
@export var warning_beats = 4
var beats = 0

@export var total_scale = Vector2(1,1)
@export var extend_speed = 10
@export var extend_length = 100.0

@onready var despawn_timer = $DespawnTimer
@onready var anim_player = $AnimationPlayer
@onready var collision_shape = $CollisionShape2D
@onready var sprite = $CollisionShape2D/Sprite2D
@onready var warning_container = $WarningContainer

var active = false
var time_elapsed = 0

func initialize(song_beat_length: float, spawn_pos:Vector2, this_scale:Vector2, init_rotation: float, despawn_time_set: float, warning_beat: float):
	beat_length = song_beat_length
	spawn_position = spawn_pos
	initial_rotation = init_rotation
	despawn_time = despawn_time_set
	warning_beats = warning_beat
	
	total_scale = this_scale

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = spawn_position
	rotation_degrees = initial_rotation
	despawn_timer.wait_time = despawn_time
	despawn_timer.connect("timeout", _on_despawn_timer_timeout)
	beats = warning_beats
	
	scale = total_scale
	warning_container.scale = total_scale
	collision_shape.scale = total_scale
	
	anim_player.speed_scale = beat_length/warning_beats
	anim_player.play("warning")
	warning_container.visible = true
	#connect Rhythm notifier
	get_tree().root.get_node("main").get_node("RhythmNotifier").connect("beat", _on_beat_heard)


func _physics_process(delta: float) -> void:
	if active:
		
		time_elapsed += extend_speed * delta
		
		# Lerp the y scale towards extend_length
		var current_scale = lerp(1.0, extend_length, time_elapsed)
		
		# Apply the new scale to the CollisionShape2D
		collision_shape.scale.y = current_scale * total_scale.y


func _on_despawn_timer_timeout() -> void:
	queue_free()


func _on_beat_heard(beat: int):
	if beats > 1:
		beats -= 1
	elif not active:
		active = true
		warning_container.visible = false
		sprite.visible = true
		collision_shape.disabled = false
		despawn_timer.start()
	else:
		pass
