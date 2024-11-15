extends Camera2D

@export var randomStrength: float = 30.0
@export var shakeFade: float = 5.0
@export var shake_length: float = 0.5  # Duration of the shake in seconds

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var shake_timer: float = 0.0

func apply_shake(length):
	shake_strength = randomStrength
	shake_timer = shake_length  # Set the timer to the desired shake length
	shake_timer = length

func _process(delta):

	if shake_timer > 0:
		# Decrease the timer
		shake_timer -= delta
		
		# Calculate shake strength based on remaining time
		shake_strength = randomStrength * (shake_timer / shake_length)
		
		# Apply the shake offset
		offset = randomOffset()
	else:
		# Reset offset when the shake ends
		offset = Vector2()

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
