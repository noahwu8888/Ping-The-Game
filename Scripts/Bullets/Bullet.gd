class_name Bullet extends RigidBody2D

@export var spawn_position = Vector2(0,0)
@export var initial_velocity = Vector2(0,100)
@export var despawn_time = 5

@onready var despawn_timer_obj = $DespawnTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = spawn_position
	linear_velocity = initial_velocity
	
	despawn_timer_obj.connect("timeout", _on_despawn_timer_timeout)
	despawn_timer_obj.wait_time = despawn_time
	despawn_timer_obj.start()

func initialize(spawn_pos:Vector2, init_velocity: Vector2, despawn_timer: float):
	spawn_position = spawn_pos
	initial_velocity = init_velocity
	despawn_time = despawn_timer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass

func _move():
	pass


func _on_despawn_timer_timeout():
	queue_free()
