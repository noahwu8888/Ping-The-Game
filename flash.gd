extends ColorRect

# Declare the Tween node as a member variable
@onready var anim_player = $AnimationPlayer

func _ready():
	pass

func flash_screen():
	anim_player.play("flash")
