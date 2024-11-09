extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position = get_global_mouse_position()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("ow")
