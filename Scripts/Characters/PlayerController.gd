extends Node2D

@export var dodge_time = 1

@onready var hit_sound = $AudioStreamPlayer2D
@onready var dodge_timer = $InvincibilityTimer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position = get_global_mouse_position()


func _on_area_2d_body_entered(body: Node2D) -> void:
	_hit()


func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	_hit()

func _hit():
	hit_sound.play()
