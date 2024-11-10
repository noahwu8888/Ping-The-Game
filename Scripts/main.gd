extends Node2D

@export var bullet_dict: Dictionary = {}

@export var beat_length = 0.839


@onready var main_menu = $MainMenu
@onready var boss = $Boss
@onready var boss_anim = $Boss/AnimationPlayer
@onready var anim_player = $AnimationPlayer
@onready var player = $Player

@onready var flash = $Flash

@onready var screen_center = $CenterOfScreen




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _start_fight():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	player.visible = true

func _on_beat_heard(beat:int):
	_beat_anim(beat)
	_beat_bullets(beat)
	print(beat)
			
func _beat_anim(beat:int):
	match beat:
		8:
			anim_player.play("8-12")
		9:
			flash.flash_screen()
		13:
			anim_player.play("13-24")
			boss_anim.play("shake")
		23:
			boss_anim.play("RESET")
		25:
			flash.flash_screen()
			anim_player.play("25-26")
			boss_anim.play("roar")
		26:
			boss.visible = false

func _beat_bullets(beat:int):
	match beat:
		14,15,16,17,18,19,20,21,22:
			var num_bullets = 10
			var radius_vector = Vector2(1, 0)
			var arc_length = .6
			var bullet_reference = bullet_dict.get("Base Bullet").instantiate()
			#bullet_reference._initialize_orbital_bullet(200, 2, 8)
			shoot_bullets_in_arc(bullet_reference, num_bullets, radius_vector, arc_length, boss.position, 600, 3)
		23:
			var bullet_instance = bullet_dict.get("Base Shockwave").instantiate()
			bullet_instance.initialize(.839, screen_center.position, Vector2(60,60),20, 0, 1, beat_length, 2)
			add_child.call(bullet_instance)
"""
10 - 22: Build-up
23 - 24: Drop nyoooom
25: DROP
26.5: ping
30: call

34.5: leave sound (quiet)
38: call

41: DROP 2 (lasers prolly)
42.5: ping
43: COME BACK SWINGING
46: call
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
		add_child(bullet_instance)

func _spawn(direction: Vector2):
	var bullet_instance = bullet_dict.get("Base Bullet").instantiate()
	bullet_instance.spawn_position = boss.position
	bullet_instance.initial_velocity = direction
	add_child.call(bullet_instance)

func _delay_shoot(function:Callable, bullet_instance, wait_for: float, args_array: Array) -> void:
	var timer = Timer.new()
	timer.wait_time = wait_for
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	function.callv(args_array)
	add_child(bullet_instance)

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
	add_child.call(bullet_instance)
	
	#Spawn Laser
	var bullet_instance = bullet_dict.get("Base Laser").instantiate()
	bullet_instance.initialize(.839, position,Vector2(1,1), 90, .5, 4)
	add_child.call(bullet_instance)
	
	
	#Orbital Laser
	var bullet_instance = bullet_dict.get("Orbital Laser").instantiate()
	bullet_instance.position = position
	add_child.call(bullet_instance)
	
	#Delayed shoot:
		var bullet_instance = bullet_dict.get("Base Shockwave").instantiate()
		_delay_shoot(bullet_instance.initialize, bullet_instance, beat_length/2, [.839, Vector2(200,200), Vector2(20,20),20, 0, 1, 2, 0])
		add_child.call(bullet_instance)
	"""
