extends Button

@onready var button_texture = $DiscordLogo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	pass

func _on_button_down() -> void:
	button_texture.position.y += 2

func _on_button_up() -> void:
	button_texture.position.y -= 2
