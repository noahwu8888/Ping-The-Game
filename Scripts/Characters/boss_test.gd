extends Node2D

@export var bullet_dict: Dictionary = {}

@export var beat_length = 0.839

func _ready() -> void:
	pass

func _spawn(direction: Vector2):
	var bullet_instance = bullet_dict.get("Base Bullet").instantiate()
	bullet_instance.spawn_position = position
	bullet_instance.initial_velocity = direction
	get_parent().add_child.call_deferred(bullet_instance)

func _on_beat_heard(beat: int):
	pass
	"""
	#Multishot
	var num_bullets = 20
	var radius_vector = Vector2(1, 0)
	var arc_length = 1
	var bullet_reference = bullet_dict.get("Base Bullet").instantiate()
	#bullet_reference._initialize_orbital_bullet(200, 2, 8)
	shoot_bullets_in_arc(bullet_reference, num_bullets, radius_vector, arc_length, position, 400, 3)
	
	
	var directions: Array = [[Vector2(200,-200)],[Vector2(200,200)],[Vector2(-200,200)],[Vector2(-200,-200)]]
	subdivide_beat(_spawn, 4, directions)
	
	#Spawn Shockwave
	var bullet_instance = bullet_dict.get("Base Shockwave").instantiate()
	bullet_instance.initialize(.839, Vector2(200,200), Vector2(20,20),20, 0, 1, 2, 4)
	get_parent().add_child.call_deferred(bullet_instance)
	
	#Spawn Laser
	var bullet_instance = bullet_dict.get("Base Laser").instantiate()
	bullet_instance.initialize(.839, position,Vector2(1,1), 90, .5, 4)
	get_parent().add_child.call_deferred(bullet_instance)
	
	
	#Orbital Laser
	var bullet_instance = bullet_dict.get("Orbital Laser").instantiate()
	bullet_instance.position = position
	get_parent().add_child.call_deferred(bullet_instance)
	"""

# bullet_reference should be a preconfigured bullet,
# start_direction will be where the first bullet is shot from
# arc_length should be what percentage of a circle. EX: .25 will shoot bullets 90 degrees clockwise from starting position
# position is global position
func shoot_bullets_in_arc(bullet_reference, num_bullets: int, start_direction: Vector2, arc_length: float, start_pos: Vector2, speed:float, bullet_life: float):
	for i in range(num_bullets):
		# Adjust rotation to fully span the arc across `num_bullets - 1` intervals
		var angle_step = TAU * arc_length * (i / float(num_bullets))
		var direction = start_direction.rotated(angle_step).normalized()
		
		# Duplicate the preconfigured bullet_reference
		var bullet_instance = bullet_reference.duplicate()
		
		# Initialize the duplicated bullet instance with specific parameters
		bullet_instance.initialize(start_pos, direction * speed, bullet_life)
		
		# Add bullet to the scene
		get_parent().add_child(bullet_instance)


func subdivide_beat(function: Callable, subdivide_times: int, args_array: Array) -> void:
	# Ensure the args_array has the correct length
	assert(args_array.size() == subdivide_times, "args_array must have the same number of elements as subdivide_times.")
	
	# Calculate the time interval for each subdivision
	var interval = beat_length / subdivide_times
	
	# Create a timer to handle the subdivisions
	var timer = Timer.new()
	timer.wait_time = interval
	timer.one_shot = true
	add_child(timer)  # Add timer to the scene to ensure it works correctly
	
	for i in range(subdivide_times):
		# Start the timer and await its timeout signal
		timer.start()
		await timer.timeout
		
		# Call the provided function with the specific arguments for this subdivision
		function.callv(args_array[i])

	# Remove the timer after completing all subdivisions
	timer.queue_free()
