extends Bullet

@export var bullet_drag: float = 1 # Adjust this value to control the drag force

# Called every frame to update physics
func _physics_process(delta: float) -> void:
	# Calculate the drag effect
	var drag_force = linear_velocity * bullet_drag * delta
	# Apply drag, reducing the linear velocity gradually
	linear_velocity -= drag_force
	
	# Ensure the bullet stops if the velocity gets very low to avoid perpetual movement due to tiny velocity values
	if linear_velocity.length() < 0.1:
		linear_velocity = Vector2.ZERO
