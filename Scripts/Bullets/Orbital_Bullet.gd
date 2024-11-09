extends Bullet
@export_category("Bullet To Instantiate")
@export var bullet_prefab: PackedScene

@export_category("Count")
@export var bullet_count = 4

@export_category("Distance")
@export var orbit_distance = 100.0
@export var orbit_speed = 5.0

var bullets_arr = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(bullet_count):
		var bullet = bullet_prefab.instantiate()
		
		# Calculate the initial angle for each bullet
		var angle = i * TAU / bullet_count
		var bullet_position = Vector2(orbit_distance, 0).rotated(angle)
		
		# Initialize bullet with calculated position
		bullet.global_position = global_position + bullet_position
		bullet.initialize(bullet_position, Vector2(0,0), self.despawn_time + 1)
		
		add_child(bullet)
		bullets_arr.append({"bullet": bullet, "angle": angle})
	super()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update each bullet's orbit position based on the current position of OrbitalBullet
	for bullet_data in bullets_arr:
		var bullet = bullet_data["bullet"]
		bullet_data["angle"] += orbit_speed * delta  # Increment angle based on speed and delta
		
		# Calculate the new position around OrbitalBullet based on the updated angle
		var new_position = Vector2(orbit_distance, 0).rotated(bullet_data["angle"])
		
		# Set bullet's position relative to the OrbitalBullet's current global position
		bullet.global_position = global_position + new_position

func _initialize_orbital_bullet(orbital_distance: float, orbital_speed: float, bullet_num):
	orbit_distance = orbital_distance
	orbit_speed = orbital_speed
	bullet_count = bullet_num
