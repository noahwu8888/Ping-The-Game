extends Node2D

@export var bullet_dict: Dictionary = {}

@export var beat_length = 0.839
var screen_size: Vector2


@onready var music_player = $MusicPlayer
@onready var main_menu = $MainMenu
@onready var boss = $Boss
@onready var boss_anim = $Boss/AnimationPlayer
@onready var anim_player = $AnimationPlayer
@onready var player = $Player

@onready var flash = $Flash

@onready var screen_center = $CenterOfScreen




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	print("Screen size:", screen_size)


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
		32:
			boss.visible = true
			anim_player.play("32-34")
			boss_anim.play("loop_spin")
		33:
			boss_anim.play("RESET")
		34:
			boss_anim.play("spin")
func _beat_bullets(beat:int):
	match beat:
		14,15,16,17,18,19,20,21,22:
			var num_bullets = 40
			var radius_vector = Vector2(1, 0)
			var arc_length = 1
			var bullet_reference = bullet_dict.get("Base Bullet").instantiate()
			shoot_bullets_in_arc(bullet_reference, num_bullets, radius_vector, arc_length, boss.position, 600, 3)
		23:
			var bullet_instance = bullet_dict.get("Base Shockwave").instantiate()
			bullet_instance.initialize(.839, screen_center.position, Vector2(60,60),20, 0, 1, beat_length, 2)
			add_child.call(bullet_instance)
		26:
			var bullet_instance = bullet_dict.get("Base Laser").instantiate()
			var spawn_pos = Vector2(0,player.position.y)
			bullet_instance.initialize(.839, spawn_pos,Vector2(20,20), 90, .5, 1)
			add_child.call(bullet_instance)
			
			var num_bullets = 20
			var radius_vector = Vector2(1, 0)
			var arc_length = 1
			var bullet_reference = bullet_dict.get("Base Bullet").instantiate()
			bullet_reference.scale = Vector2(5,5)
			shoot_bullets_in_arc(bullet_reference, num_bullets, radius_vector, arc_length, boss.position, 600, 3)
		27:
			var bullet_instance = bullet_dict.get("Base Laser").instantiate()
			var spawn_pos = Vector2(player.position.x, 0)
			bullet_instance.initialize(.839, spawn_pos ,Vector2(20,20), 180, .5, 1)
			add_child.call(bullet_instance)
		28:
			var bullet_instance = bullet_dict.get("Base Laser").instantiate()
			var spawn_pos = Vector2(screen_size.x,player.position.y)
			bullet_instance.initialize(.839, spawn_pos,Vector2(20,20), 270, .5, 1)
			add_child.call(bullet_instance)
		29:
			var bullet_instance = bullet_dict.get("Async Shockwave").instantiate()
			var args_arr = [
				[beat_length, screen_center.position + Vector2(-500,-250), Vector2(20,20),.5, .5, 1.5, beat_length*2, 1],
				[beat_length, screen_center.position + Vector2(500,250), Vector2(20,20),.5, .75, 1.5, beat_length*1.75, 1],
				[beat_length, screen_center.position + Vector2(-500,250), Vector2(20,20),.5, 1.0, 1.5, beat_length*1.5, 1],
				[beat_length, screen_center.position + Vector2(500,-250), Vector2(20,20),.5, 1.25, 1.5, beat_length*1.25, 1]]
			_subdivide_beat("initialize",bullet_instance, 4, args_arr)
		31:
			var bullet_instance = bullet_dict.get("Orbital Bullet").instantiate()
			bullet_instance._initialize_orbital_bullet(200, 5, 4)
			bullet_instance.initialize(Vector2(200,0),Vector2(0,400),4)
			add_child(bullet_instance)
			var bullet_instance2 = bullet_dict.get("Orbital Bullet").instantiate()
			bullet_instance2._initialize_orbital_bullet(200, 5, 4)
			bullet_instance2.initialize(Vector2(screen_size.x - 200, screen_size.y),Vector2(0,-400),4)
			add_child(bullet_instance2)
			var bullet_instance3 = bullet_dict.get("Base Laser").instantiate()
			var spawn_pos = screen_center.position
			bullet_instance3.initialize(.839, spawn_pos,Vector2(20,2000), 90, 0.0001, 1)
			
			add_child.call(bullet_instance3)
		34:
			var bullet_instance = bullet_dict.get("Drag Bullet").instantiate()
			bullet_instance.bullet_drag = .25
			var args_arr = []
			var bullet_speed = 300  # Adjust this speed as needed
			for i in range(16):
				# Calculate the angle for each bullet (in radians)
				var angle = i * TAU / 16  # TAU is 2 * PI, so this divides the circle into 16 parts
				# Calculate the velocity vector for this angle
				var velocity = Vector2(cos(angle), sin(angle)) * bullet_speed
				# Add the position and velocity to the args array
				args_arr.append([boss.position, velocity, 4])
			_subdivide_beat("initialize", bullet_instance, 16, args_arr)
		
"""
10 - 22: Build-up
23 - 24: Drop nyoooom
25: DROP
26.5: ping
30: call
32: fly across the screen
33: stop

35.5: leave sound (quiet)
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


func _delay_shoot(function_name: String, bullet_instance, wait_for: float, args_array: Array) -> void:
	var timer = Timer.new()
	timer.wait_time = wait_for
	timer.one_shot = true
	add_child(timer)
	timer.start()
	await timer.timeout
	bullet_instance.callv(function_name, args_array)
	add_child(bullet_instance)

func _subdivide_beat(function_name: String, bullet, subdivide_times: int, args_array_of_arrays: Array) -> void:
	# Ensure the args_array_of_arrays has the correct length
	assert(args_array_of_arrays.size() == subdivide_times, "args_array_of_arrays must have the same number of elements as subdivide_times.")
	
	# Calculate the time interval for each subdivision
	var interval = beat_length / subdivide_times
	
	for i in range(subdivide_times):
		# Duplicate bullet instance for each subdivision
		var bullet_instance = bullet.duplicate()
		
		if i == 0:
			# Call the function immediately for the first beat with the given args
			bullet_instance.callv(function_name, args_array_of_arrays[i])
			add_child(bullet_instance)
		else:
			# Call _delay_shoot for subsequent beats with delay
			_delay_shoot(function_name, bullet_instance, interval * i, args_array_of_arrays[i])




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
	
	# Subdivide:
		var bullet_instance = bullet_dict.get("Base Bullet").instantiate()
		var args_arr = [[boss.position,Vector2(0,1000),4],[boss.position,Vector2(0,1000),4],[boss.position,Vector2(0,1000),4],[boss.position,Vector2(0,1000),4]]
		_subdivide_beat("initialize",bullet_instance,4, args_arr)
	"""

func _player_died():
	music_player.stop()
	get_tree().call_group("Bullet", "queue_free")
	anim_player.play("died")

func _restart():
	player._reset()
	anim_player.play("RESET")
	boss_anim.play("RESET")
	music_player.play(8*beat_length)
	anim_player.play("8-12")
