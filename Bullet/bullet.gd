extends RigidBody2D


var direction : Vector2
@export var speed : float = 100
@export var hitForce : float = 100

var hitparticles : Resource = preload("res://Bullet/hitParticles.tscn")

func setDirection() -> void:
	direction = Vector2.RIGHT.rotated(rotation)
	linear_velocity = direction * speed
	
func setColor(color:Color) -> void:
	modulate=color
	
func _ready() -> void:
	setDirection()

func _on_body_shape_entered(_body_rid:RID, body:Node, _body_shape_index:int, _local_shape_index:int) -> void:
	SoundManager.PlaySfx("hit")
	queue_free()
	var particles : Node2D = hitparticles.instantiate()
	get_tree().current_scene.add_child(particles)
	particles.global_position = global_position
	particles.rotation = (-direction).angle()
	if body.has_method("get_hit"):
		body.call("get_hit", direction)
		ScreenshakeManager.ShakeDir(direction)
		HitstopManager.hit_stop_tiny()
		SoundManager.PlaySfx("ball_hit")
