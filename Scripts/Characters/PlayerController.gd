extends Node2D

@export var max_health = 6.0
@export var dodge_time = 1

@onready var sprite = $Sprite2D
@onready var hit_sound = $AudioStreamPlayer2D
@onready var dodge_timer = $InvincibilityTimer
@onready var anim_player = $AnimationPlayer

var health: float
var invulnerable = false

signal died

var healthy_modulate
@onready var unhealthy_modulate = $Sprite2D/Sprite2D.modulate

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	healthy_modulate = sprite.modulate

	print(healthy_modulate)
	dodge_timer.wait_time = dodge_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position = get_global_mouse_position()
	if invulnerable:
		anim_player.speed_scale = lerp(1,4,dodge_timer.time_left/dodge_time)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if !invulnerable:
		_hit()


func _on_area_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if !invulnerable:
		_hit()

func _hit():
	health -= 1
	hit_sound.play()
	anim_player.speed_scale = 1
	anim_player.play("invulnerable")
	invulnerable = true
	dodge_timer.start()
	
	sprite.modulate = lerp(unhealthy_modulate,healthy_modulate,health/max_health)
	if health == 0:
		emit_signal("died")


func _on_invincibility_timer_timeout() -> void:
	anim_player.stop()
	invulnerable = false

func _reset():
	sprite.modulate = healthy_modulate
	health = max_health
